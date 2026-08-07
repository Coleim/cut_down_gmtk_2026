extends Cable

var is_half_cut: bool = false



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_cut or not interactable:
			return
		if is_half_cut:
			is_cut = true
			_sprite.animation = "cut"
			SoundManager.play_sfx("CutDown - Electricity sound")
			cut.emit(self)
		else: 
			is_half_cut = true
			_sprite.animation = "halfcut"
		_sprite.stop()
		_sprite.frame = color_index
