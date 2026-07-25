extends Node

## Global game state: current level, score, level configuration.
## Autoloaded as "GameManager".

signal level_started(level_number: int)
signal level_won(level_number: int)
signal level_lost(level_number: int)

const COLOR_PALETTE: Array[Color] = [
	Color("ac3232"), # red
	Color("639bff"), # blue
	Color("99e550"), # green
	Color("fbf236"), # yellow
	Color("d77bba"), # purple
]

const COLOR_NAMES: Array[String] = [
	"red", "blue", "green", "yellow", "purple"
]

const BASE_CABLE_COUNT: int = 3
const BASE_TIME_LIMIT: float = 30.0
const TIME_PER_EXTRA_CABLE: float = 6.0

var current_level: int = 1
var score: int = 0
var last_time_taken: float = 0.0
var last_score_gained: int = 0


func reset_game() -> void:
	current_level = 1
	score = 0


func get_cable_count(level: int) -> int:
	return min(BASE_CABLE_COUNT + (level - 1), COLOR_PALETTE.size())


func get_time_limit(level: int) -> float:
	var extra_cables: int = get_cable_count(level) - BASE_CABLE_COUNT
	return BASE_TIME_LIMIT + (extra_cables * TIME_PER_EXTRA_CABLE)


## Returns an array of dictionaries: [{color: Color, name: String}, ...]
## picked randomly (without repeats) from the palette, sized for this level.
func generate_level_colors(level: int) -> Array[Dictionary]:
	var count: int = get_cable_count(level)
	var indices: Array[int] = []
	for i in range(COLOR_PALETTE.size()):
		indices.append(i)
	indices.shuffle()

	var result: Array[Dictionary] = []
	for i in range(count):
		var idx: int = indices[i]
		result.append({
			"color": COLOR_PALETTE[idx],
			"name": COLOR_NAMES[idx],
			"color_index": idx,
		})
	return result


func win_level(time_taken: float) -> void:
	last_time_taken = time_taken
	last_score_gained = current_level * 100
	score += last_score_gained
	level_won.emit(current_level)


func advance_level() -> void:
	current_level += 1


func lose_level() -> void:
	level_lost.emit(current_level)
