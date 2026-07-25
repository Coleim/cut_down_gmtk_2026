extends Node2D

const CABLE_SCENE: PackedScene = preload("res://scenes/game/Cable.tscn")

@onready var _cables_container: HBoxContainer = $UI/CablesContainer
@onready var _bomb_rect: ColorRect = $UI/BombRect
@onready var _countdown_timer: Timer = $CountdownTimer
@onready var _level_sprite: AnimatedSprite2D = $LevelSprite
@onready var _show_color: AnimatedSprite2D = $ShowColor
@onready var _cut_text: Sprite2D = $ColorSelector/CutText

var _cable_order: Array[Dictionary] = []   # colors the player must cut, in order
var _displayed_cables: Array[Dictionary] = []  # all cables shown on screen
var _cut_index: int = 0
var _time_left: float = 0.0
var _level_ended: bool = false


func _ready() -> void:
	_setup_level_sprite()

	var level_data: Dictionary = GameManager.generate_level_colors(GameManager.current_level)
	_cable_order = level_data["to_cut"]
	_displayed_cables = level_data["displayed"]
	_time_left = GameManager.get_time_limit(GameManager.current_level)
	_cut_index = 0
	_level_ended = false

	# Hide cables and cut text during color preview
	_cables_container.visible = false
	_cut_text.visible = false

	# Show each color to cut, 1 second each
	for entry in _cable_order:
		_show_color.frame = entry["color_index"]
		await get_tree().create_timer(1.0).timeout

	# Preview done — show cables and cut prompt
	_show_color.visible = false
	_cut_text.visible = true
	_cables_container.visible = true
	_spawn_cables()

	_countdown_timer.wait_time = 1.0
	_countdown_timer.timeout.connect(_on_countdown_tick)
	_countdown_timer.start()

	SoundManager.play_music("bomb_ambience")


func _setup_level_sprite() -> void:
	_level_sprite.animation = "default"
	_level_sprite.frame = clampi(GameManager.current_level - 1, 0, 8)


func _spawn_cables() -> void:
	for child in _cables_container.get_children():
		child.queue_free()

	var shuffled := _displayed_cables.duplicate()
	shuffled.shuffle()

	for entry in shuffled:
		var cable: Cable = CABLE_SCENE.instantiate()
		_cables_container.add_child(cable)
		cable.cable_color = entry["color"]
		cable.color_name = entry["name"]
		cable.cut.connect(_on_cable_cut)


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


func _on_countdown_tick() -> void:
	if _level_ended:
		return

	_time_left -= 1.0

	if _time_left <= 0:
		_explode()


func _win_level() -> void:
	_level_ended = true
	_countdown_timer.stop()
	SoundManager.play_sfx("win")
	var time_limit: float = GameManager.get_time_limit(GameManager.current_level)
	var time_taken: float = time_limit - _time_left
	GameManager.win_level(time_taken)
	get_tree().change_scene_to_file("res://scenes/level_complete/LevelComplete.tscn")


func _explode() -> void:
	_level_ended = true
	_countdown_timer.stop()
	SoundManager.play_sfx("explosion")
	_bomb_rect.color = Color.BLACK
	GameManager.lose_level()
	get_tree().change_scene_to_file("res://scenes/game_over/GameOver.tscn")
