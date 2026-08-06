extends Control

@onready var _score_label: Label        = $Panel/ScoreLabel
@onready var _best_label: Label         = $Panel/BestLabel
@onready var _time_label: Label         = $Panel/TimeLabel
@onready var _cablecut_label: Label     = $Panel/CableCutLabel
@onready var _retry_button: TextureButton = $RetryButton
@onready var _menu_button: TextureButton  = $MenuButton
@onready var _panel: Node2D  = $Panel


func _ready() -> void:
	_time_label.text     = "%.1fs" % GameManager.last_time_taken
	_cablecut_label.text = "%d" % GameManager.last_cables_cut
	SoundManager.play_music("CutDown - Gameover", false)
	
	_retry_button.visible = false
	_menu_button.visible = false
	_score_label.text = ""
	_best_label.text  = ""
	
	var target_y := _panel.position.y
	_panel.position.y = -580
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", target_y, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	await tween.finished
	
	_retry_button.visible = true
	_menu_button.visible = true
	

	match GameManager.current_path:
		GameManager.PathType.STORY:
			_menu_button.texture_normal = load("res://assets/sprites/LevelSelect.png")
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
	await _animate_out()
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

func _animate_out() -> void: 
	_retry_button.visible = false
	_menu_button.visible = false
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", -580, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	await tween.finished
	await get_tree().process_frame
	
	
func _on_menu_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	await _animate_out()	
	
	match GameManager.current_path:
		GameManager.PathType.STORY:
			get_tree().change_scene_to_file("res://scenes/level_group_select/LevelGroupSelect.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
