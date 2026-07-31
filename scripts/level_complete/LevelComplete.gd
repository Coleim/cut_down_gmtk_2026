extends Control

@onready var _time_label: Label        = $TimeLabel
@onready var _score_label: Label       = $ScoreLabel
@onready var _cablecut_label: Label    = $CableCutLabel
@onready var _next_button: TextureButton  = $NextButton
@onready var _retry_button: TextureButton = $RetryButton
@onready var _menu_button: TextureButton  = $MenuButton


func _ready() -> void:
	_time_label.text     = "%.1fs" % GameManager.last_time_taken
	_cablecut_label.text = "%d" % GameManager.last_cables_cut
	SoundManager.play_music("CutDown - WinMusic", false)

	match GameManager.current_path:
		GameManager.PathType.STORY:
			_score_label.text = ""  # no score in story
			_next_button.visible = not GameManager.is_group_complete()
		GameManager.PathType.ENDLESS, GameManager.PathType.CHALLENGE:
			_score_label.text = "%d (+%d)" % [GameManager.session_score, GameManager.last_score_gained]
			_next_button.visible = true  # "Continue" in endless/challenge

	_next_button.pressed.connect(_on_next_pressed)
	_retry_button.pressed.connect(_on_retry_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_next_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()

	match GameManager.current_path:
		GameManager.PathType.STORY:
			if GameManager.is_group_complete():
				# Shouldn't reach here (button hidden), but safe fallback
				get_tree().change_scene_to_file("res://scenes/level_group_select/LevelGroupSelect.tscn")
			else:
				var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
				get_tree().change_scene_to_file(scene)
		GameManager.PathType.ENDLESS:
			# Mode was already advanced in GameManager.advance_level()
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)
		GameManager.PathType.CHALLENGE:
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)


func _on_retry_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	match GameManager.current_path:
		GameManager.PathType.STORY:
			# Replay the current level (level_in_group unchanged)
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)
		_:
			# Endless/Challenge retry restarts the whole run
			GameManager.reset_game()
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)


func _on_menu_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
