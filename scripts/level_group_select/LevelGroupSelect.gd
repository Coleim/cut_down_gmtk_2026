extends Control

## Story path: shows all 10 groups as sprite cards arranged in a grid.
## Locked groups are dimmed. Clicking an unlocked group starts it.
## For each completed group, a "LevelCompleteN" Sprite2D node (N = group number)
## must exist as a direct child of this scene — it will be shown when complete.

@onready var _back_button:    TextureButton = $BackButton
@onready var _panel: Node2D = $Panel
@onready var _progress_label: Label         = $Panel/ProgressLabel
@onready var _group_1_5:      TextureButton = $Panel/"1-5"
@onready var _group_6_10:    TextureButton = $Panel/"6-10"
@onready var _group_11_15:   TextureButton = $Panel/"11-15"
@onready var _group_16_20:   TextureButton = $Panel/"16-20"
@onready var _group_21_25:   TextureButton = $Panel/"21-25"
@onready var _group_26_30:   TextureButton = $Panel/"26-30"
@onready var _group_31_35:   TextureButton = $Panel/"31-35"
@onready var _group_36_40:   TextureButton = $Panel/"36-40"
@onready var _group_41_45:   TextureButton = $Panel/"41-45"
@onready var _group_46_50:   TextureButton = $Panel/"46-50"

var _groups: Array[TextureButton]


func _ready() -> void:	
	SoundManager.play_music("CutDown - Menu music", true)
	_back_button.visible = false
	_update_progress()
	
	_groups = [
		_group_1_5, _group_6_10, _group_11_15, _group_16_20, _group_21_25,
		_group_26_30, _group_31_35, _group_36_40, _group_41_45, _group_46_50,
	]

	for i in _groups.size():
		var group_number := i + 1
		var button: TextureButton = _groups[i]

		var complete_node := get_node_or_null("Panel/LevelComplete%d" % group_number)
		if complete_node:
			complete_node.visible = SaveManager.is_group_completed(group_number)

		if SaveManager.is_group_unlocked(group_number):
			_apply_click_mask(button)
			button.pressed.connect(_on_group_selected.bind(group_number))
		else:
			button.modulate = Color(0.4, 0.4, 0.4, 1.0)
			button.disabled = true
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var target_y := _panel.position.y
	_panel.position.y = -580
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", target_y, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		
	await tween.finished
	
	_back_button.visible = true
	_back_button.pressed.connect(_on_back_pressed)


func _update_progress() -> void:
	var completed_groups := 0
	for g in range(1, GameManager.TOTAL_GROUPS + 1):
		if SaveManager.is_group_completed(g):
			completed_groups += 1
	var levels_done := completed_groups * GameManager.LEVELS_PER_GROUP
	var levels_total := GameManager.TOTAL_GROUPS * GameManager.LEVELS_PER_GROUP
	_progress_label.text = "%d/%d" % [levels_done, levels_total]


func _apply_click_mask(button: TextureButton) -> void:
	var image := button.texture_normal.get_image()
	var mask := BitMap.new()
	mask.create_from_image_alpha(image)
	button.texture_click_mask = mask


func _on_group_selected(group: int) -> void:
	await _animate_out()
	GameManager.start_story_group(group)
	var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
	get_tree().change_scene_to_file(scene)

func _animate_out() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")	
	_back_button.visible = false
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", -580, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	await tween.finished
	await get_tree().process_frame

func _on_back_pressed() -> void:
	await _animate_out()
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
	
