extends Control

@onready var _time_label: Label = $CenterContainer/VBoxContainer/TimeLabel
@onready var _score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var _next_button: Button = $CenterContainer/VBoxContainer/NextButton
@onready var _retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var _menu_button: Button = $CenterContainer/VBoxContainer/MenuButton


func _ready() -> void:
	_time_label.text = "Time to defuse: %.1fs" % GameManager.last_time_taken
	_score_label.text = "Score: %d (+%d)" % [GameManager.score, GameManager.last_score_gained]
	_next_button.pressed.connect(_on_next_pressed)
	_retry_button.pressed.connect(_on_retry_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_next_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	GameManager.advance_level()
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")


func _on_retry_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")


func _on_menu_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
