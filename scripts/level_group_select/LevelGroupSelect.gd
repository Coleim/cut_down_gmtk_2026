extends Control

## Story path: shows all 10 groups as sprite cards arranged in a grid.
## Locked groups are dimmed. Clicking an unlocked group starts it.
## For each completed group, a "LevelCompleteN" Sprite2D node (N = group number)
## must exist as a direct child of this scene — it will be shown when complete.

@onready var _back_button:    TextureButton = $BackButton
@onready var _progress_label: Label         = $ProgressLabel
@onready var _progress_sub:   Label         = $ProgressSubLabel
@onready var _group_1_5:      TextureButton = $"1-5"
@onready var _group_6_10:    TextureButton = $"6-10"
@onready var _group_11_15:   TextureButton = $"11-15"
@onready var _group_16_20:   TextureButton = $"16-20"
@onready var _group_21_25:   TextureButton = $"21-25"
@onready var _group_26_30:   TextureButton = $"26-30"
@onready var _group_31_35:   TextureButton = $"31-35"
@onready var _group_36_40:   TextureButton = $"36-40"
@onready var _group_41_45:   TextureButton = $"41-45"
@onready var _group_46_50:   TextureButton = $"46-50"

var _debug_complete_up_to: int = 0
var _groups: Array[TextureButton]


func _ready() -> void:
	SoundManager.play_music("CutDown - Menu music", true)
	_back_button.pressed.connect(_on_back_pressed)
	_update_progress()

	_groups = [
		_group_1_5, _group_6_10, _group_11_15, _group_16_20, _group_21_25,
		_group_26_30, _group_31_35, _group_36_40, _group_41_45, _group_46_50,
	]

	for i in _groups.size():
		var group_number := i + 1
		var button: TextureButton = _groups[i]

		var complete_node := get_node_or_null("LevelComplete%d" % group_number)
		if complete_node:
			complete_node.visible = SaveManager.is_group_completed(group_number)

		if SaveManager.is_group_unlocked(group_number):
			_apply_click_mask(button)
			button.pressed.connect(_on_group_selected.bind(group_number))
		else:
			button.modulate = Color(0.4, 0.4, 0.4, 1.0)
			button.disabled = true
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if OS.is_debug_build():
		_debug_complete_up_to = SaveManager.DEBUG_COMPLETE_UP_TO
		_debug_refresh_badges()


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_RIGHT:
		_debug_complete_up_to = mini(_debug_complete_up_to + 1, GameManager.TOTAL_GROUPS)
		_debug_refresh_badges()
	elif event.keycode == KEY_LEFT:
		_debug_complete_up_to = maxi(_debug_complete_up_to - 1, 0)
		_debug_refresh_badges()


func _debug_refresh_badges() -> void:
	for i in GameManager.TOTAL_GROUPS:
		var g := i + 1
		var node := get_node_or_null("LevelComplete%d" % g)
		if node:
			node.visible = _debug_complete_up_to >= g
		# A group is unlocked when the previous one is completed (g <= completed + 1)
		var unlocked := g <= _debug_complete_up_to + 1
		_groups[i].modulate = Color(1, 1, 1, 1) if unlocked else Color(0.4, 0.4, 0.4, 1.0)
		_groups[i].disabled = not unlocked
	var levels_done := _debug_complete_up_to * GameManager.LEVELS_PER_GROUP
	_progress_label.text = "%d/%d" % [levels_done, GameManager.TOTAL_GROUPS * GameManager.LEVELS_PER_GROUP]
	print("[DEBUG] LevelComplete badges shown: 1 to %d" % _debug_complete_up_to)


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
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	GameManager.start_story_group(group)
	var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
	get_tree().change_scene_to_file(scene)


func _on_back_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
