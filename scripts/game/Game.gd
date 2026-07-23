extends Node2D

const CABLE_SCENE: PackedScene = preload("res://scenes/game/Cable.tscn")

@onready var _cables_container: HBoxContainer = $UI/CablesContainer
@onready var _order_container: HBoxContainer = $UI/OrderContainer
@onready var _timer_label: Label = $UI/TopBar/TimerLabel
@onready var _level_label: Label = $UI/TopBar/LevelLabel
@onready var _bomb_rect: ColorRect = $UI/BombRect
@onready var _countdown_timer: Timer = $CountdownTimer

var _cable_order: Array[Dictionary] = []
var _cut_index: int = 0
var _time_left: float = 0.0
var _level_ended: bool = false


func _ready() -> void:
	_level_label.text = "Level %d" % GameManager.current_level
	_cable_order = GameManager.generate_level_colors(GameManager.current_level)
	_time_left = GameManager.get_time_limit(GameManager.current_level)
	_cut_index = 0
	_level_ended = false

	_spawn_order_display()
	print("please wait")
	await get_tree().create_timer(3).timeout
	print("end wait")
	
	_hide_order_display()
	
	#_spawn_bomb()
	_spawn_cables()

	_countdown_timer.wait_time = 1.0
	_countdown_timer.timeout.connect(_on_countdown_tick)
	_countdown_timer.start()
	_update_timer_label()

	SoundManager.play_music("bomb_ambience")


func _hide_order_display() -> void: 
	for child in _order_container.get_children():
		child.queue_free()


func _spawn_order_display() -> void:
	for child in _order_container.get_children():
		child.queue_free()

	for entry in _cable_order:
		var swatch := ColorRect.new()
		swatch.custom_minimum_size = Vector2(50, 50)
		swatch.color = entry["color"]
		_order_container.add_child(swatch)


func _spawn_cables() -> void:
	for child in _cables_container.get_children():
		child.queue_free()

	var shuffled: Array[Dictionary] = _cable_order.duplicate()
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
	_update_timer_label()

	if _time_left <= 0:
		_explode()


func _update_timer_label() -> void:
	_timer_label.text = "Time: %d" % max(0, ceil(_time_left))
	# TODO: Update the actual timer image


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
