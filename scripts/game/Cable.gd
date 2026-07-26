extends Control
class_name Cable

signal cut(cable: Cable)

@export var cable_color: Color = Color.WHITE
var color_name: String = ""
var color_index: int = 0
var interactable: bool = true
var is_cut: bool = false

@onready var _sprite: AnimatedSprite2D = $Cables


func _ready() -> void:
	_sprite.animation = "full"
	_sprite.stop()


func set_frame(idx: int) -> void:
	color_index = idx
	_sprite.frame = idx


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_cut or not interactable:
			return
		is_cut = true
		_sprite.animation = "cut"
		_sprite.stop()
		_sprite.frame = color_index
		SoundManager.play_sfx("CutDown - Electricity sound")
		cut.emit(self)
