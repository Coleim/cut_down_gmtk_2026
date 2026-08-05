extends Control

@onready var _story_button: TextureButton     = $StoryButton
@onready var _endless_button: TextureButton   = $EndlessButton
@onready var _challenge_button: TextureButton = $ChallengeButton
@onready var _quit_button: TextureButton      = $QuitButton
@onready var _credits: RichTextLabel          = $Credits
@onready var _main_title: Sprite2D            = $MainTitle
@onready var _smoke: AnimatedSprite2D         = $MainTitle/SmokeAnimation
@onready var _wheel: Sprite2D                 = $Wheel
@onready var _wheel2: Sprite2D                = $Wheel2

var _wheel_spinning: bool  = false
var _wheel2_spinning: bool = false


func _ready() -> void:
	GameManager.reset_game()
	SoundManager.play_music("CutDown - Menu music", true)

	_story_button.visible     = false
	_smoke.visible            = false
	_endless_button.visible   = false
	_challenge_button.visible = false
	_quit_button.visible      = false
	_credits.visible          = false
	_smoke.stop()

	# Slide title in
	var target_y := _main_title.position.y
	_main_title.position.y = -200
	var tween := create_tween()
	tween.tween_property(_main_title, "position:y", target_y, 1.0) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

	tween.tween_callback(func():
		# Start smoke loop once the panel has landed
		_smoke.play("default")

		_story_button.visible     = true
		_smoke.visible            = true
		_endless_button.visible   = true
		_challenge_button.visible = true
		_quit_button.visible      = true
		_credits.visible          = true
		_refresh_lock_states()
	)

	_story_button.pressed.connect(_on_story_pressed)
	_endless_button.pressed.connect(_on_endless_pressed)
	_challenge_button.pressed.connect(_on_challenge_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _refresh_lock_states() -> void:
	var extra_unlocked := SaveManager.are_extra_paths_unlocked()
	_endless_button.disabled   = not extra_unlocked
	_challenge_button.disabled = not extra_unlocked
	var locked_color := Color(1, 1, 1, 0.35)
	_endless_button.modulate   = Color.WHITE if extra_unlocked else locked_color
	_challenge_button.modulate = Color.WHITE if extra_unlocked else locked_color


func _on_story_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/level_group_select/LevelGroupSelect.tscn")


func _on_endless_pressed() -> void:
	if not SaveManager.are_extra_paths_unlocked():
		return
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	GameManager.start_endless()
	var scene := GameManager.get_scene_for_mode(GameManager.current_mode)
	get_tree().change_scene_to_file(scene)


func _on_challenge_pressed() -> void:
	if not SaveManager.are_extra_paths_unlocked():
		return
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/mode_select/ModeSelect.tscn")


func _on_quit_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = event.position
		if _is_over_sprite(_wheel, mouse_pos) and not _wheel_spinning:
			_spin_wheel(_wheel, "_wheel_spinning")
		elif _is_over_sprite(_wheel2, mouse_pos) and not _wheel2_spinning:
			_spin_wheel(_wheel2, "_wheel2_spinning")


func _is_over_sprite(sprite: Sprite2D, pos: Vector2) -> bool:
	if sprite.texture == null:
		return false
	var tex_size := sprite.texture.get_size() * sprite.scale
	var rect := Rect2(sprite.global_position - tex_size / 2.0, tex_size)
	return rect.has_point(pos)


func _spin_wheel(wheel: Sprite2D, spinning_var: String) -> void:
	set(spinning_var, true)
	var tween := create_tween()
	tween.tween_property(wheel, "rotation", wheel.rotation + TAU, 0.6) \
		 .set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		wheel.rotation = fmod(wheel.rotation, TAU)
		set(spinning_var, false)
	)
