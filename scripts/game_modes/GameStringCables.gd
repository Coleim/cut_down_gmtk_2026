extends GameBase

## Strong Cables mode — each cable must be clicked TWICE to cut.
## First click "strains" the cable (visual feedback); second click cuts it.

# Tracks which cables have been clicked once already
var _strained_cables: Array[Cable] = []


func _handle_cable_cut(cable: Cable) -> void:
	if _level_ended:
		return

	if _strained_cables.has(cable):
		# Second click — actually cut
		_strained_cables.erase(cable)
		SoundManager.play_sfx("cable_cut")
		var expected: String = _cable_order[_cut_index]["name"]
		if cable.color_name == expected:
			SoundManager.play_sfx("correct_cut")
			_cut_index += 1
			if _cut_index >= _cable_order.size():
				_win_level()
		else:
			SoundManager.play_sfx("wrong_cut")
			_explode()
	else:
		# First click — strain the cable (visual hint, no cut yet)
		_strained_cables.append(cable)
		SoundManager.play_sfx("CutDown - Electricity sound")
		# Reset is_cut so the cable sprite doesn't show as cut yet,
		# and mark a "strained" state via modulate
		cable.is_cut = false
		cable.modulate = Color(1.5, 1.2, 0.5)  # yellowish tint as placeholder
