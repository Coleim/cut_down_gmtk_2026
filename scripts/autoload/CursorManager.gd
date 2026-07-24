extends Node

const GAME_SCENE := "res://scenes/game/Game.tscn"
const SPRITE_SCALE_MENU := Vector2(0.32, 0.32)   # ~32px cursor on a 100px sprite
const SPRITE_SCALE_GAME := Vector2(1.0, 1.0)

var _cursor: AnimatedSprite2D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	_cursor = AnimatedSprite2D.new()
	_cursor.z_index = 100
	_cursor.scale = SPRITE_SCALE_MENU
	get_tree().root.add_child.call_deferred(_cursor)

	get_tree().root.child_entered_tree.connect(_on_scene_changed)


func _setup_frames() -> void:
	# Only build frames once; sprite_frames is already set if we already ran
	if _cursor.sprite_frames != null:
		return

	var texture := load("res://assets/sprites/cutter-sprite.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	var frame0 := AtlasTexture.new()
	frame0.atlas = texture
	frame0.region = Rect2(0, 0, 100, 100)   # frame 1 = closed

	var frame1 := AtlasTexture.new()
	frame1.atlas = texture
	frame1.region = Rect2(0, 100, 100, 100) # frame 2 = open

	frames.add_animation("default")
	frames.set_animation_loop("default", false)
	frames.add_frame("default", frame0)
	frames.add_frame("default", frame1)

	_cursor.sprite_frames = frames
	_cursor.animation = "default"
	_cursor.frame = 1  # start open


func _on_scene_changed(node: Node) -> void:
	# Wait a frame so the scene tree is fully ready
	await get_tree().process_frame
	_apply_scene_scale()


func _apply_scene_scale() -> void:
	var scene_path: String = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	if scene_path == GAME_SCENE:
		_cursor.scale = SPRITE_SCALE_GAME
	else:
		_cursor.scale = SPRITE_SCALE_MENU


func _process(_delta: float) -> void:
	if _cursor == null:
		return
	if _cursor.sprite_frames == null:
		_setup_frames()
	_cursor.global_position = get_viewport().get_mouse_position()


func _input(event: InputEvent) -> void:
	if _cursor == null or _cursor.sprite_frames == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_cursor.frame = 0 if event.pressed else 1  # 0=closed, 1=open
