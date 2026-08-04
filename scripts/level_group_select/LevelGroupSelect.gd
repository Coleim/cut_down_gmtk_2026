extends Control

## Story path: shows all 10 groups as sprite cards arranged in a grid.
## Locked groups are dimmed. Clicking an unlocked group starts it.

const CHECKMARK_PATH := "res://assets/sprites/Checkmark.png"

@onready var _back_button:   Button        = $BackButton
@onready var _group_1_5:     TextureButton = $"1-5"
@onready var _group_6_10:    TextureButton = $"6-10"
@onready var _group_11_15:   TextureButton = $"11-15"
@onready var _group_16_20:   TextureButton = $"16-20"
@onready var _group_21_25:   TextureButton = $"21-25"
@onready var _group_26_30:   TextureButton = $"26-30"
@onready var _group_31_35:   TextureButton = $"31-35"
@onready var _group_36_40:   TextureButton = $"36-40"
@onready var _group_41_45:   TextureButton = $"41-45"
@onready var _group_46_50:   TextureButton = $"46-50"


func _ready() -> void:
	SoundManager.play_music("CutDown - Menu music", true)
	_back_button.pressed.connect(_on_back_pressed)

	var groups: Array[TextureButton] = [
		_group_1_5, _group_6_10, _group_11_15, _group_16_20, _group_21_25,
		_group_26_30, _group_31_35, _group_36_40, _group_41_45, _group_46_50,
	]

	for i in groups.size():
		var group_number := i + 1
		var button: TextureButton = groups[i]

		if SaveManager.is_group_unlocked(group_number):
			_apply_click_mask(button)
			button.pressed.connect(_on_group_selected.bind(group_number))
			if SaveManager.is_group_completed(group_number):
				_add_checkmark(button)
		else:
			button.modulate = Color(0.4, 0.4, 0.4, 1.0)
			button.disabled = true
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _apply_click_mask(button: TextureButton) -> void:
	var image := button.texture_normal.get_image()
	var mask := BitMap.new()
	mask.create_from_image_alpha(image)
	button.texture_click_mask = mask


func _add_checkmark(button: TextureButton) -> void:
	if not ResourceLoader.exists(CHECKMARK_PATH):
		return
	var checkmark := TextureRect.new()
	checkmark.texture = load(CHECKMARK_PATH)
	checkmark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	checkmark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(checkmark)


func _on_group_selected(group: int) -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	GameManager.start_story_group(group)
	var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
	get_tree().change_scene_to_file(scene)


func _on_back_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
