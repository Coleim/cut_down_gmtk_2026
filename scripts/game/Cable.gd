extends Control
class_name Cable

## A single cuttable cable. Emits `cut` when clicked (only once).

signal cut(cable: Cable)

@export var cable_color: Color = Color.WHITE:
	set(value):
		cable_color = value
		if is_node_ready():
			_update_visual()

var color_name: String = ""
var is_cut: bool = false

@onready var _rect: ColorRect = $ColorRect
@onready var _button: Button = $Button


func _ready() -> void:
	_update_visual()
	_button.pressed.connect(_on_pressed)


func _update_visual() -> void:
	if _rect:
		_rect.color = cable_color


func _on_pressed() -> void:
	if is_cut:
		return
	is_cut = true
	_rect.color = Color.WHITE
	_button.disabled = true
	cut.emit(self)
