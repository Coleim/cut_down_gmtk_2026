extends Node2D

const CABLE_SCENE: PackedScene = preload("res://scenes/game/Cable.tscn")

@onready var _cables_container: HBoxContainer = $UI/CablesContainer
@onready var _countdown_timer: Timer = $CountdownTimer
@onready var _level_sprite: AnimatedSprite2D = $LevelSprite
@onready var _show_color: AnimatedSprite2D = $ColorSelector/ShowColor
@onready var _cut_text: Sprite2D = $ColorSelector/CutText
@onready var _sec_tens: AnimatedSprite2D = $UI/TimerContainerSeconds/Number1
@onready var _sec_units: AnimatedSprite2D = $UI/TimerContainerSeconds/Number0
@onready var _ms_tens: AnimatedSprite2D = $UI/TimerContainerMs/Number1
@onready var _ms_units: AnimatedSprite2D = $UI/TimerContainerMs/Number0

var _cable_order: Array[Dictionary] = []
var _displayed_cables: Array[Dictionary] = []
var _cut_index: int = 0
var _time_left: float = 0.0
var _level_ended: bool = false
var _timer_running: bool = false


func _ready() -> void:
	_setup_level_sprite()

	var level_data: Dictionary = GameManager.generate_level_colors(GameManager.current_level)
	_cable_order = level_data["to_cut"]
	_displayed_cables = level_data["displayed"]
	_time_left = GameManager.get_time_limit(GameManager.current_level)
	_cut_index = 0
	_level_ended = false
	_timer_running = false

	# Show initial time before anything starts
	call_deferred("_update_timer_display")

	# Hide only cut text during color preview
	_cut_text.visible = false
	_spawn_cables(false)

	# Show each color to cut, 1 second each
	for entry in _cable_order:
		_show_color.frame = entry["color_index"]
		SoundManager.play_oneshot(entry["name"].capitalize())
		await get_tree().create_timer(1.0).timeout

	# Preview done — enable cutting, show cut prompt, start timer
	_show_color.visible = false
	_cut_text.visible = true
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


func _update_timer_display() -> void:
	var t := maxf(_time_left, 0.0)
	var secs := int(t)
	var ms := int(roundf(fmod(t, 1.0) * 100.0))
	if ms >= 100:
		ms = 0

	_sec_tens.stop()
	_sec_tens.frame = clampi(secs / 10, 0, 9)

	_sec_units.stop()
	_sec_units.frame = secs % 10

	_ms_tens.stop()
	_ms_tens.frame = ms / 10

	_ms_units.stop()
	_ms_units.frame = ms % 10


func _setup_level_sprite() -> void:
	_level_sprite.animation = "default"
	_level_sprite.frame = clampi(GameManager.current_level - 1, 0, 8) if GameManager.current_level <= 9 else 9


func _spawn_cables(interactable: bool = true) -> void:
	for child in _cables_container.get_children():
		if child is Cable:
			child.queue_free()

	var shuffled := _displayed_cables.duplicate()
	shuffled.shuffle()

	for entry in shuffled:
		var cable: Cable = CABLE_SCENE.instantiate()
		cable.cable_color = entry["color"]
		cable.color_name = entry["name"]
		cable.color_index = entry["color_index"]
		cable.interactable = interactable
		_cables_container.add_child(cable)
		cable.set_frame(entry["color_index"])
		cable.cut.connect(_on_cable_cut)


func _enable_cables() -> void:
	for child in _cables_container.get_children():
		if child is Cable:
			child.interactable = true


func _on_cable_cut(cable: Cable) -> void:
	if _level_ended:
		return

	SoundManager.play_sfx("cable_cut")

	var expected_name: String = _cable_order[_cut_index]["name"]
	if cable.color_name == expected_name:
		SoundManager.play_sfx("correct_cut")
		_cut_index += 1
		if _cut_index >= _cable_order.size():
			_win_level()
	else:
		SoundManager.play_sfx("wrong_cut")
		_explode()


func _win_level() -> void:
	_level_ended = true
	_timer_running = false
	SoundManager.stop_music()
	SoundManager.play_sfx("win")
	var time_limit: float = GameManager.get_time_limit(GameManager.current_level)
	var time_taken: float = time_limit - _time_left
	GameManager.win_level(time_taken)
	get_tree().change_scene_to_file("res://scenes/level_complete/LevelComplete.tscn")


func _explode() -> void:
	_level_ended = true
	_timer_running = false
	SoundManager.stop_music()
	SoundManager.play_sfx("CutDown - Explosion")
	var time_limit: float = GameManager.get_time_limit(GameManager.current_level)
	var time_taken: float = time_limit - _time_left
	GameManager.lose_level(time_taken, _cut_index)
	get_tree().change_scene_to_file("res://scenes/game_over/GameOver.tscn")
