extends Control

## Challenge path: shows all unlocked game modes.
## Player picks one and plays it until death.

@onready var _modes_container: VBoxContainer = $ModesContainer
@onready var _back_button: Button = $BackButton
@onready var _title_label: Label = $TitleLabel


func _ready() -> void:
	SoundManager.play_music("CutDown - Menu music", true)
	_back_button.pressed.connect(_on_back_pressed)
	_build_mode_list()


func _build_mode_list() -> void:
	for child in _modes_container.get_children():
		child.queue_free()

	var unlocked := GameManager.get_unlocked_modes()

	for mode in unlocked:
		var mode_name := GameManager.get_mode_name(mode)
		var best := SaveManager.get_challenge_best(mode_name)

		var btn := Button.new()
		btn.text = "%s    (Best: %d)" % [mode_name, best]
		btn.custom_minimum_size = Vector2(600, 70)

		var captured_mode := mode
		btn.pressed.connect(func(): _on_mode_selected(captured_mode))
		_modes_container.add_child(btn)


func _on_mode_selected(mode: GameManager.GameMode) -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	GameManager.start_challenge(mode)
	var scene := GameManager.get_scene_for_mode(mode)
	get_tree().change_scene_to_file(scene)


func _on_back_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
