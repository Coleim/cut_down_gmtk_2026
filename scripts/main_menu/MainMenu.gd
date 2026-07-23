extends Control

@onready var _start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var _quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	GameManager.reset_game()
	_start_button.pressed.connect(_on_start_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")


func _on_quit_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().quit()
