extends SceneTree
func _init():
	change_scene_to_file("res://scenes/game/Game.tscn")

func _process(delta: float) -> bool:
	var inst = current_scene
	if inst == null:
		return false
	var ui = inst.get_node_or_null("UI")
	if ui == null:
		return false
	print("UI size: ", ui.size, " global_pos: ", ui.global_position)
	var bg = ui.get_node("Background")
	print("BG color: ", bg.color, " size: ", bg.size, " global_pos: ", bg.global_position, " visible: ", bg.visible)
	quit()
	return true
