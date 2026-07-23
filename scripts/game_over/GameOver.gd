extends Control

@onready var _score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var _retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var _menu_button: Button = $CenterContainer/VBoxContainer/MenuButton


func _ready() -> void:
	_score_label.text = "Score: %d" % GameManager.score
	_retry_button.pressed.connect(_on_retry_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_retry_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")


func _on_menu_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
