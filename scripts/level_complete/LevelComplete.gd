extends Control

@onready var _time_label: Label           = $Panel/TimeLabel
@onready var _score_label: Label          = $Panel/ScoreLabel
@onready var _cablecut_label: Label       = $Panel/CableCutLabel
@onready var _next_button: TextureButton  = $NextButton
@onready var _menu_button: TextureButton  = $MenuButton
@onready var _panel: Node2D = $Panel


func _ready() -> void:
	_time_label.text     = "%.1fs" % GameManager.last_time_taken
	_cablecut_label.text = "%d" % GameManager.last_cables_cut
	SoundManager.play_music("CutDown - WinMusic", false)
	
	_next_button.visible = false
	_menu_button.visible = false
	_score_label.text = ""


	var target_y := _panel.position.y
	_panel.position.y = -580
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", target_y, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	await tween.finished
	
	
	match GameManager.current_path:
		GameManager.PathType.STORY:
			_next_button.visible = true
			if GameManager.is_group_complete():
				_next_button.texture_normal = load("res://assets/sprites/LevelSelect.png")
			else:
				_menu_button.texture_normal = load("res://assets/sprites/LevelSelect.png")
		GameManager.PathType.ENDLESS, GameManager.PathType.CHALLENGE:
			_score_label.text = "%d (+%d)" % [GameManager.session_score, GameManager.last_score_gained]
			_next_button.visible = true  # "Continue" in endless/challenge
	
	
	
	_menu_button.visible = true
	_next_button.pressed.connect(_on_next_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _on_next_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	await _animate_out()

	match GameManager.current_path:
		GameManager.PathType.STORY:
			if GameManager.is_group_complete():
				get_tree().change_scene_to_file("res://scenes/level_group_select/LevelGroupSelect.tscn")
			else:
				var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
				get_tree().change_scene_to_file(scene)
		GameManager.PathType.ENDLESS:
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)
		GameManager.PathType.CHALLENGE:
			var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
			get_tree().change_scene_to_file(scene)

func _animate_out() -> void: 
	_next_button.visible = false
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
			if GameManager.is_group_complete():
				get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/level_group_select/LevelGroupSelect.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
