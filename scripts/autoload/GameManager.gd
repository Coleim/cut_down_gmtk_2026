extends Node

## Global game state: current level, score, level configuration.
## Autoloaded as "GameManager".

signal level_started(level_number: int)
signal level_won(level_number: int)
signal level_lost(level_number: int)

const COLOR_PALETTE: Array[Color] = [
	Color("e74c3c"), # red
	Color("2ecc71"), # green
	Color("3498db"), # blue
	Color("f1c40f"), # yellow
	Color("9b59b6"), # purple
	Color("e67e22"), # orange
	Color("ecf0f1"), # white
	Color("1abc9c"), # teal
]

const COLOR_NAMES: Array[String] = [
	"red", "green", "blue", "yellow", "purple", "orange", "white", "teal"
]

const BASE_CABLE_COUNT: int = 3
const BASE_TIME_LIMIT: float = 30.0
const TIME_PER_EXTRA_CABLE: float = 6.0

var current_level: int = 1
var score: int = 0


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
		})
	return result


func win_level() -> void:
	score += current_level * 100
	level_won.emit(current_level)
	current_level += 1


func lose_level() -> void:
	level_lost.emit(current_level)
