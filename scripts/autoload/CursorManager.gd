extends Node

const SPRITE_SCALE_MENU := Vector2(0.32, 0.32)
const SPRITE_SCALE_GAME := Vector2(1.0, 1.0)

var _cursor: AnimatedSprite2D
var _in_game: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	_cursor = AnimatedSprite2D.new()
	_cursor.z_index = 100
	_cursor.visible = true
	_cursor.scale = SPRITE_SCALE_MENU
	get_tree().root.add_child.call_deferred(_cursor)
	get_tree().root.child_entered_tree.connect(_on_scene_changed)


func _setup_frames() -> void:
	if _cursor.sprite_frames != null:
		return

	var texture := load("res://assets/sprites/cutter-sprite.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	var frame0 := AtlasTexture.new()
	frame0.atlas = texture
	frame0.region = Rect2(0, 0, 99, 99)

	var frame1 := AtlasTexture.new()
	frame1.atlas = texture
	frame1.region = Rect2(0, 101, 100, 100)

	frames.add_animation("default")
	frames.set_animation_loop("default", false)
	frames.add_frame("default", frame0)
	frames.add_frame("default", frame1)

	_cursor.sprite_frames = frames
	_cursor.animation = "default"
	_cursor.frame = 1  # open


func _on_scene_changed(_node: Node) -> void:
	await get_tree().process_frame
	_apply_scene_settings()


func _apply_scene_settings() -> void:
	var scene_path: String = get_tree().current_scene.scene_file_path \
		if get_tree().current_scene else ""
	_in_game = "game_modes" in scene_path
	if _in_game:
		_cursor.scale = SPRITE_SCALE_GAME
	else:
		_cursor.scale = SPRITE_SCALE_MENU
	# Custom sprite always visible, system cursor always hidden
	_cursor.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta: float) -> void:
	if _cursor == null:
		return
	if _cursor.sprite_frames == null:
		_setup_frames()

	var mouse_pos := get_viewport().get_mouse_position()
	var in_window := get_viewport().get_visible_rect().has_point(mouse_pos)

	if in_window:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_cursor.visible = true
		_cursor.global_position = mouse_pos
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_cursor.visible = false


func _input(event: InputEvent) -> void:
	if _cursor == null or _cursor.sprite_frames == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_cursor.frame = 0  # closed
			var under_mouse := get_viewport().gui_get_hovered_control()
			if not (under_mouse is BaseButton):
				SoundManager.play_sfx("CutDown - Cut sound")
		else:
			_cursor.frame = 1  # open
