extends Control

@onready var _start_button: TextureButton = $StartButton
@onready var _quit_button: TextureButton = $QuitButton
@onready var _credits: RichTextLabel = $Credits
@onready var _main_title: Sprite2D = $MainTitle
@onready var _wheel: Sprite2D = $Wheel
@onready var _wheel2: Sprite2D = $Wheel2

var _wheel_spinning: bool = false
var _wheel2_spinning: bool = false


func _ready() -> void:
	#GameManager.reset_game() # TODO: re-enable before shipping
	SoundManager.play_music("CutDown - Menu music", true)

	_start_button.visible = false
	_quit_button.visible = false
	_credits.visible = false
	
	# Move title offscreen above
	var target_y = _main_title.position.y
	_main_title.position.y = -200
	# Slide title down
	var tween = create_tween()
	tween.tween_property(_main_title, "position:y", target_y, 1)\
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Fade in buttons/credits after title lands
	tween.tween_callback(func():
		var fade = create_tween().set_parallel(true)
		fade.tween_property(_start_button, "visible", true, 0.4)
		fade.tween_property(_quit_button, "visible", true, 0.4)
		fade.tween_property(_credits, "visible", true, 0.4)
	)
	
	_start_button.pressed.connect(_on_start_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	


func _on_start_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	SoundManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")


func _on_quit_pressed() -> void:
	SoundManager.play_sfx("CutDown - Button sound1")
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position
		if _is_over_sprite(_wheel, mouse_pos) and not _wheel_spinning:
			_spin_wheel(_wheel, "_wheel_spinning")
		elif _is_over_sprite(_wheel2, mouse_pos) and not _wheel2_spinning:
			_spin_wheel(_wheel2, "_wheel2_spinning")


func _is_over_sprite(sprite: Sprite2D, pos: Vector2) -> bool:
	if sprite.texture == null:
		return false
	var tex_size = sprite.texture.get_size() * sprite.scale
	var rect = Rect2(sprite.global_position - tex_size / 2.0, tex_size)
	return rect.has_point(pos)


func _spin_wheel(wheel: Sprite2D, spinning_var: String) -> void:
	set(spinning_var, true)
	var tween = create_tween()
	tween.tween_property(wheel, "rotation", wheel.rotation + TAU, 0.6)\
		 .set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		wheel.rotation = fmod(wheel.rotation, TAU)
		set(spinning_var, false)
	)
