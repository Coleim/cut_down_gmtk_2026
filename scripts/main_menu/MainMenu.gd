extends Control

@onready var _start_button: TextureButton = $StartButton
@onready var _quit_button: TextureButton = $QuitButton


func _ready() -> void:
	#GameManager.reset_game() # TODO: re-enable before shipping
	_start_button.pressed.connect(_on_start_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")


func _on_quit_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().quit()
