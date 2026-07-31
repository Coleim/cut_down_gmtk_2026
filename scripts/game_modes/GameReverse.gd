extends GameBase

## Reverse mode — the sequence is shown left-to-right but must be cut
## in the reverse order (last shown → first shown).

func _get_preview_sequence() -> Array:
	# Show the sequence in normal order so the player can memorise it,
	# but the _cable_order (what we actually check against) is reversed.
	var reversed := _cable_order.duplicate()
	reversed.reverse()
	_cable_order = reversed   # overwrite so _handle_cable_cut uses reversed order
	return _cable_order       # preview also shows reversed order (player must cut last→first)
