extends Control

@onready var _score_label: Label = $ScoreLabel
@onready var _time_label: Label = $TimeLabel
@onready var _cablecut_label: Label = $CableCutLabel
@onready var _retry_button: TextureButton = $RetryButton
@onready var _menu_button: TextureButton = $MenuButton


func _ready() -> void:
	_score_label.text = "%d" % GameManager.score
	_time_label.text = "%.1fs" % GameManager.last_time_taken
	_cablecut_label.text = "%d" % GameManager.last_cables_cut
	_retry_button.pressed.connect(_on_retry_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_retry_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")


func _on_menu_pressed() -> void:
	SoundManager.play_sfx("menu_click")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
