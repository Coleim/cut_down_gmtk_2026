extends Node2D
class_name GameBase

## Base scene script for all game modes.
## Subclasses override virtual methods to change behaviour.

const CABLE_SCENE: PackedScene = preload("res://scenes/game/Cable.tscn")

# ---------------------------------------------------------------------------
# Node references — must exist in every inherited scene
# ---------------------------------------------------------------------------

@onready var _cables_container: HBoxContainer = $UI/CablesContainer
@onready var _level_panel: Sprite2D            = $LevelPanel
@onready var _level_numbers:  AnimatedSprite2D = $LevelPanel/LevelNumbers
@onready var _level_numbers2: AnimatedSprite2D = $LevelPanel/LevelNumbers2
@onready var _level_text_sprite: Sprite2D      = $LevelPanel/LevelText
@onready var _die_text: Sprite2D               = $LevelPanel/DieText
@onready var _mode_panel: Sprite2D             = $ModePanel
@onready var _mode_text: AnimatedSprite2D      = $ModePanel/ModeText

@onready var _color_selector: Sprite2D         = $ColorSelector
@onready var _show_color: AnimatedSprite2D     = $ColorSelector/ShowColor
@onready var _cut_text: Sprite2D               = $ColorSelector/CutText

@onready var _sec_tens:  AnimatedSprite2D = $UI/TimerContainerSeconds/Number1
@onready var _sec_units: AnimatedSprite2D = $UI/TimerContainerSeconds/Number0
@onready var _ms_tens:   AnimatedSprite2D = $UI/TimerContainerMs/Number1
@onready var _ms_units:  AnimatedSprite2D = $UI/TimerContainerMs/Number0

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

var _cable_order: Array = []
var _displayed_cables: Array = []
var _cut_index: int = 0
var _time_left: float = 0.0
var _level_ended: bool = false
var _timer_running: bool = false
var _mode_panel_end_pos: Vector2

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_mode_panel_end_pos    = _mode_panel.position
	_mode_panel.visible    = false
	_color_selector.modulate.a = 0

	# Set time before panel animates so the display is correct from frame 1
	_time_left     = GameManager.get_time_limit()
	_cut_index     = 0
	_level_ended   = false
	_timer_running = false
	_update_timer_display()

	await _setup_panel()

	var level_data: Dictionary = GameManager.generate_level_colors()
	_cable_order      = level_data["to_cut"]
	_displayed_cables = level_data["displayed"]

	_cut_text.visible  = false
	_show_color.visible = false
	await _setup_color_selector()
	_spawn_cables(false)

	# Show each color in the cut sequence
	_show_color.visible = true
	for entry in _get_preview_sequence():
		_show_color.frame = entry["color_index"]
		SoundManager.play_oneshot(entry["name"].capitalize())
		await get_tree().create_timer(1.0).timeout

	_show_color.visible = false
	_cut_text.visible   = true
	_enable_cables()
	_timer_running = true
	SoundManager.play_music("CutDown - Defuse Bomb music", true)


func _process(delta: float) -> void:
	if not _timer_running or _level_ended:
		return
	_time_left -= delta
	_update_timer_display()
	if _time_left <= 0.0:
		_time_left = 0.0
		_update_timer_display()
		_explode()


# ---------------------------------------------------------------------------
# Virtual methods — override in subclasses
# ---------------------------------------------------------------------------

## Which sequence to preview to the player.
## Reverse mode overrides this to show the reversed order.
func _get_preview_sequence() -> Array:
	return _cable_order


## Called when a cable is clicked.
## Override for StringCables (double-click required).
func _handle_cable_cut(cable: Cable) -> void:
	if _level_ended:
		return
	SoundManager.play_sfx("cable_cut")
	var expected: String = _cable_order[_cut_index]["name"]
	if cable.color_name == expected:
		SoundManager.play_sfx("correct_cut")
		_cut_index += 1
		if _cut_index >= _cable_order.size():
			_win_level()
	else:
		SoundManager.play_sfx("wrong_cut")
		_explode()


## Override to hide or modify the timer display.
func _setup_timer_display() -> void:
	pass  # base: timer shown normally


# ---------------------------------------------------------------------------
# Panel setup
# ---------------------------------------------------------------------------

func _setup_panel() -> void:
	# --- Content ---
	match GameManager.current_path:
		GameManager.PathType.STORY:
			_level_text_sprite.visible = true
			_level_numbers.visible     = true
			_level_numbers2.visible    = true
			_die_text.visible          = false
			_level_numbers.stop()
			_level_numbers2.stop()
			_level_numbers.frame  = GameManager.current_level % 10
			_level_numbers2.frame = GameManager.current_level / 10
		_:  # ENDLESS
			var lvl := GameManager.endless_level
			if lvl >= 100:
				_level_numbers.visible     = false
				_level_numbers2.visible    = false
				_level_text_sprite.visible = false
				_die_text.visible          = true
			else:
				_die_text.visible          = false
				_level_text_sprite.visible = true
				_level_numbers.visible     = true
				_level_numbers2.visible    = true
				_level_numbers.stop()
				_level_numbers2.stop()
				_level_numbers.frame  = lvl % 10
				_level_numbers2.frame = lvl / 10

	var show_mode_panel := false
	match GameManager.current_mode:
		GameManager.GameMode.REVERSE:
			show_mode_panel = true
			_mode_text.frame = 0
		GameManager.GameMode.STRONG_CABLES:
			show_mode_panel = true
			_mode_text.frame = 1

	# --- 1. LevelPanel slides down ---
	var level_target_y := _level_panel.position.y
	_level_panel.position.y = -200
	var tween := create_tween()
	tween.tween_property(_level_panel, "position:y", level_target_y, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	await tween.finished

	_setup_timer_display()

	# --- 2. ModePanel slides down after LevelPanel lands ---
	if show_mode_panel:
		_mode_panel.position = Vector2(157.0, 131.0)
		_mode_panel.visible  = true
		var mode_tween := create_tween()
		mode_tween.tween_property(_mode_panel, "position", _mode_panel_end_pos, 1.0) \
				  .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		await mode_tween.finished


func _setup_color_selector() -> void:
	var target_y := _color_selector.position.y
	_color_selector.position.y = -200
	_color_selector.modulate.a = 1
	var tween := create_tween()
	tween.tween_property(_color_selector, "position:y", target_y, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	await tween.finished


# ---------------------------------------------------------------------------
# Cable management
# ---------------------------------------------------------------------------

func _spawn_cables(interactable: bool = true) -> void:
	for child in _cables_container.get_children():
		if child is Cable:
			child.queue_free()

	var shuffled := _displayed_cables.duplicate()
	shuffled.shuffle()

	for entry in shuffled:
		var cable: Cable = CABLE_SCENE.instantiate()
		cable.cable_color  = entry["color"]
		cable.color_name   = entry["name"]
		cable.color_index  = entry["color_index"]
		cable.interactable = interactable
		_cables_container.add_child(cable)
		cable.set_frame(entry["color_index"])
		cable.cut.connect(_handle_cable_cut)


func _enable_cables() -> void:
	for child in _cables_container.get_children():
		if child is Cable:
			child.interactable = true


# ---------------------------------------------------------------------------
# Timer display
# ---------------------------------------------------------------------------

func _update_timer_display() -> void:
	var t   := maxf(_time_left, 0.0)
	var secs := int(t)
	var ms   := int(roundf(fmod(t, 1.0) * 100.0))
	if ms >= 100:
		ms = 0

	_sec_tens.stop();  _sec_tens.frame  = clampi(secs / 10, 0, 9)
	_sec_units.stop(); _sec_units.frame = secs % 10
	_ms_tens.stop();   _ms_tens.frame   = ms / 10
	_ms_units.stop();  _ms_units.frame  = ms % 10


# ---------------------------------------------------------------------------
# Win / Lose
# ---------------------------------------------------------------------------

func _win_level() -> void:
	_level_ended   = true
	_timer_running = false
	SoundManager.stop_music()
	SoundManager.play_sfx("win")
	var time_taken: float = GameManager.get_time_limit() - _time_left
	GameManager.win_level(time_taken)
	GameManager.advance_level()

	if GameManager.is_group_complete():
		GameManager.complete_group()

	get_tree().change_scene_to_file("res://scenes/level_complete/LevelComplete.tscn")


func _explode() -> void:
	_level_ended   = true
	_timer_running = false
	SoundManager.stop_music()
	SoundManager.play_sfx("CutDown - Explosion")
	var time_taken: float = GameManager.get_time_limit() - _time_left
	GameManager.lose_level(time_taken, _cut_index)
	get_tree().change_scene_to_file("res://scenes/game_over/GameOver.tscn")
