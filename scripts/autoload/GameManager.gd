extends Node

## Global game state: current level, score, level configuration.
## Autoloaded as "GameManager".

signal level_started(level_number: int)
signal level_won(level_number: int)
signal level_lost(level_number: int)

const COLOR_PALETTE: Array[Color] = [
	Color("ac3232"), # 0 red
	Color("639bff"), # 1 blue
	Color("99e550"), # 2 green
	Color("fbf236"), # 3 yellow
	Color("d77bba"), # 4 purple
]

const COLOR_NAMES: Array[String] = [
	"red", "blue", "green", "yellow", "purple"
]

# Per-level config: [displayed_count, cut_count, time_limit]
const LEVEL_CONFIG: Array = [
	[1, 1, 10.0], # Level 1
	[2, 2, 10.0], # Level 2
	[3, 3, 10.0], # Level 3
	[4, 3, 10.0], # Level 4
	[4, 4, 10.0], # Level 5
	[5, 3, 9.0], # Level 6
	[5, 4, 8.0], # Level 7
	[5, 5, 8.0], # Level 8
	[5, 5, 5.0],  # Level 9 (last level, 5 seconds)
]

var current_level: int = 1
var score: int = 0
var last_time_taken: float = 0.0
var last_score_gained: int = 0
var last_cables_cut: int = 0


func reset_game() -> void:
	current_level = 1
	score = 0


func _get_config(level: int) -> Array:
	var idx := mini(level - 1, LEVEL_CONFIG.size() - 1)
	return LEVEL_CONFIG[idx]


func get_displayed_count(level: int) -> int:
	return _get_config(level)[0]


func get_cut_count(level: int) -> int:
	return _get_config(level)[1]


func get_time_limit(level: int) -> float:
	return _get_config(level)[2]


## Returns two arrays:
##   displayed: all cables shown to the player (shuffled)
##   to_cut:    the subset the player must cut, in order (subset of displayed)
func generate_level_colors(level: int) -> Dictionary:
	var displayed_count := get_displayed_count(level)
	var cut_count := get_cut_count(level)

	# Pick `displayed_count` unique colors from the palette
	var indices: Array[int] = []
	for i in range(COLOR_PALETTE.size()):
		indices.append(i)
	indices.shuffle()
	indices = indices.slice(0, displayed_count)

	# The first `cut_count` of those are the ones to cut (in a random order)
	var cut_indices: Array[int] = indices.slice(0, cut_count)
	cut_indices.shuffle()

	var displayed: Array[Dictionary] = []
	for idx in indices:
		displayed.append(_make_entry(idx))

	var to_cut: Array[Dictionary] = []
	for idx in cut_indices:
		to_cut.append(_make_entry(idx))

	return {"displayed": displayed, "to_cut": to_cut}


func _make_entry(idx: int) -> Dictionary:
	return {
		"color": COLOR_PALETTE[idx],
		"name": COLOR_NAMES[idx],
		"color_index": idx,
	}


func win_level(time_taken: float) -> void:
	last_time_taken = time_taken
	last_cables_cut = get_cut_count(current_level)
	last_score_gained = current_level * 100
	score += last_score_gained
	level_won.emit(current_level)


func advance_level() -> void:
	current_level += 1


func lose_level(time_taken: float, cables_cut: int) -> void:
	last_time_taken = time_taken
	last_cables_cut = cables_cut
	level_lost.emit(current_level)
