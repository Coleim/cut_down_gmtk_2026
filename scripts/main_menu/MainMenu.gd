extends Control

@onready var _start_button: TextureButton = $StartButton
@onready var _quit_button: TextureButton = $QuitButton
@onready var _credits: RichTextLabel = $Credits
@onready var _main_title: Sprite2D = $MainTitle


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
