extends Control

@onready var _score_label: Label        = $ScoreLabel
@onready var _best_label: Label         = $BestLabel
@onready var _time_label: Label         = $TimeLabel
@onready var _cablecut_label: Label     = $CableCutLabel
@onready var _retry_button: TextureButton = $RetryButton
@onready var _menu_button: TextureButton  = $MenuButton


func _ready() -> void:
	_time_label.text     = "%.1fs" % GameManager.last_time_taken
	_cablecut_label.text = "%d" % GameManager.last_cables_cut
	SoundManager.play_music("CutDown - Gameover", false)

	match GameManager.current_path:
		GameManager.PathType.STORY:
			_score_label.text = ""
			_best_label.text  = ""
		GameManager.PathType.ENDLESS:
			_score_label.text = "Score: %d" % GameManager.session_score
			_best_label.text  = "Best: %d" % SaveManager.endless_best
		GameManager.PathType.CHALLENGE:
			var mode_name := GameManager.get_mode_name(GameManager.current_mode)
			_score_label.text = "Score: %d" % GameManager.session_score
			_best_label.text  = "Best: %d" % SaveManager.get_challenge_best(mode_name)

	_retry_button.pressed.connect(_on_retry_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_retry_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	GameManager.reset_game()

	match GameManager.current_path:
		GameManager.PathType.STORY:
			# Restart the whole group from level 1
			GameManager.current_level_in_group = 1
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)
		GameManager.PathType.ENDLESS:
			GameManager.start_endless()
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)
		GameManager.PathType.CHALLENGE:
			GameManager.start_challenge(GameManager.current_mode)
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)


func _on_menu_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
