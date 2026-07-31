extends GameBase

## Timer Gone mode — timer runs internally but the display is hidden.

func _setup_timer_display() -> void:
	# Hide both timer containers
	$UI/TimerContainerSeconds.visible = false
	$UI/TimerContainerMs.visible      = false
	# Also hide the dot separator sprite if present
	if has_node("UI/Sprite2D"):
		$UI/Sprite2D.visible = false
