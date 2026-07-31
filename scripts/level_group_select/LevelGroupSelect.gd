extends Control

## Story path: shows all 10 groups as sprite cards arranged in a grid.
## Locked groups are dimmed. Clicking an unlocked group starts it.

const GROUPS_PER_ROW := 5
const CARD_SPACING := Vector2(20, 20)

# Card size matches LevelPanel sprite (300x200) scaled down to fit nicely
const CARD_SCALE := 0.55

@onready var _back_button: Button  = $BackButton
@onready var _cards_root: Control  = $CardsRoot
@onready var _title_label: Label   = $TitleLabel


func _ready() -> void:
	SoundManager.play_music("CutDown - Menu music", true)
	_back_button.pressed.connect(_on_back_pressed)
	# Defer so CardsRoot has its final layout size
	call_deferred("_build_cards")


func _build_cards() -> void:
	for child in _cards_root.get_children():
		child.queue_free()

	var card_w := 300.0 * CARD_SCALE
	var card_h := 200.0 * CARD_SCALE

	# Centre the grid horizontally
	var total_w := GROUPS_PER_ROW * card_w + (GROUPS_PER_ROW - 1) * CARD_SPACING.x
	var start_x := (_cards_root.size.x - total_w) / 2.0
	var start_y := 10.0

	for g in range(1, GameManager.TOTAL_GROUPS + 1):
		var col := (g - 1) % GROUPS_PER_ROW
		var row := (g - 1) / GROUPS_PER_ROW

		var pos := Vector2(
			start_x + col * (card_w + CARD_SPACING.x),
			start_y + row * (card_h + CARD_SPACING.y)
		)

		_spawn_card(g, pos, card_w, card_h)


func _spawn_card(group: int, pos: Vector2, w: float, h: float) -> void:
	var unlocked := SaveManager.is_group_unlocked(group)
	var mode := GameManager.get_mode_for_group(group)
	var mode_name := GameManager.get_mode_name(mode)

	# Container acts as the clickable hit area
	var card := TextureButton.new()
	card.position = pos
	card.custom_minimum_size = Vector2(w, h)
	card.ignore_texture_size = true
	card.stretch_mode = TextureButton.STRETCH_SCALE

	# Panel background sprite
	var panel_tex := load("res://assets/sprites/LevelPanel.png") as Texture2D
	card.texture_normal = panel_tex
	if not unlocked:
		card.modulate = Color(0.35, 0.35, 0.35, 1.0)
	card.disabled = not unlocked

	_cards_root.add_child(card)

	# Group number label (placeholder until a dedicated sprite exists)
	var num_label := Label.new()
	num_label.text = "G%d" % group
	num_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	num_label.position = Vector2(w * 0.5 - 20, 10)
	num_label.add_theme_font_size_override("font_size", 20)
	card.add_child(num_label)

	# Mode name label
	var mode_label := Label.new()
	mode_label.text = mode_name
	mode_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	mode_label.position = Vector2(w * 0.5 - 50, h * 0.5 - 10)
	mode_label.custom_minimum_size = Vector2(100, 20)
	mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_label.add_theme_font_size_override("font_size", 13)
	card.add_child(mode_label)

	# Lock icon label
	if not unlocked:
		var lock_label := Label.new()
		lock_label.text = "LOCKED"
		lock_label.position = Vector2(w * 0.5 - 28, h - 30)
		lock_label.add_theme_font_size_override("font_size", 14)
		card.add_child(lock_label)

	var captured_group := group
	card.pressed.connect(func(): _on_group_selected(captured_group))


func _on_group_selected(group: int) -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	GameManager.start_story_group(group)
	var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
	get_tree().change_scene_to_file(scene)


func _on_back_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")
