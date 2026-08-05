extends Node

## Global game state and level configuration.
## Autoloaded as "GameManager".

signal level_won(level_number: int)
signal level_lost(level_number: int)

# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

enum PathType { STORY, ENDLESS, CHALLENGE }

enum GameMode {
	STANDARD,
	TIMER_GONE,
	REVERSE,
	STRONG_CABLES,
}

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

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

# 50 story levels: [displayed_count, cut_count, time_limit]
const STORY_LEVELS: Array = [
	# --- Group 1: STANDARD (levels 1-5) ---
	[1, 1, 10.0],
	[2, 2, 10.0],
	[3, 3, 10.0],
	[4, 3, 10.0],
	[5, 4, 10.0],
	# --- Group 2: STRONG (levels 6-10) ---
	[2, 2, 10.0],
	[3, 2, 10.0],
	[3, 3, 10.0],
	[4, 3, 10.0],
	[4, 4, 10.0],
	# --- Group 3: NO TIMER (levels 11-15) ---
	[2, 2, 10.0],
	[3, 2, 10.0],
	[3, 3, 10.0],
	[4, 3, 10.0],
	[5, 4, 10.0],
	# --- Group 4: ARMOURED (levels 16-20) ---
	[2, 2, 10.0],
	[3, 2, 10.0],
	[3, 3, 9.0],
	[4, 3, 9.0],
	[4, 4, 8.0],
	# --- Group 5: SMOKE (levels 21-25) ---
	[3, 3, 10.0],
	[4, 3, 10.0],
	[4, 4,  9.0],
	[5, 4,  9.0],
	[5, 5,  8.0],
	# --- Group 6: Sparkling (levels 26-30) ---
	[3, 3,  10.0],
	[4, 3,  10.0],
	[4, 4,  9.0],
	[5, 4,  9.0],
	[5, 5,  8.0],
	# --- Group 7: Moving (levels 31-35) ---
	[3, 3,  10.0],
	[4, 4,  10.0],
	[5, 4,  9.0],
	[5, 5,  8.0],
	[5, 5,  8.0],
	# --- Group 8: Light Flickers (levels 36-40) ---
	[4, 4,  10.0],
	[5, 4,  10.0],
	[5, 5,  9.0],
	[5, 5,  8.5],
	[5, 5,  8.0],
	# --- Group 9: Left/Right (levels 41-45) ---
	[4, 4,  10.0],
	[5, 5,  10.0],
	[5, 5,  9.0],
	[5, 5,  8.0],
	[5, 5,  7.0],
	# --- Group 10: Reversed (levels 46-50) ---
	[5, 4,  10.0],
	[5, 5,  9.0],
	[5, 5,  8.0],
	[5, 5,  7.0],
	[5, 5,  7.0],
]

const TOTAL_GROUPS: int = 10
const LEVELS_PER_GROUP: int = 5

# ---------------------------------------------------------------------------
# Session state (not persisted)
# ---------------------------------------------------------------------------

var current_path: PathType = PathType.STORY
var current_mode: GameMode = GameMode.STANDARD
var current_group: int = 1
var current_level_in_group: int = 1
var endless_level: int = 1
var session_score: int = 0
var last_time_taken: float = 0.0
var last_score_gained: int = 0
var last_cables_cut: int = 0
var _endless_config: Array = [3, 3, 10.0]

# Legacy shim so old code referencing current_level still works
var current_level: int:
	get:
		return (current_group - 1) * LEVELS_PER_GROUP + current_level_in_group
	set(v):
		current_group = int((v - 1) / float(LEVELS_PER_GROUP)) + 1
		current_level_in_group = (v - 1) % LEVELS_PER_GROUP + 1

# Legacy shim for score
var score: int:
	get: return session_score
	set(v): session_score = v

# ---------------------------------------------------------------------------
# Group → Mode mapping (plain func, avoids const-dict-with-enum-key issues)
# ---------------------------------------------------------------------------

func get_mode_for_group(group: int) -> GameMode:
	match group:
		1: return GameMode.STANDARD
		2: return GameMode.STRONG_CABLES
		3: return GameMode.TIMER_GONE
		4: return GameMode.REVERSE
		_: return GameMode.STANDARD


func get_mode_name(mode: GameMode) -> String:
	match mode:
		GameMode.STANDARD:      return "STANDARD"
		GameMode.TIMER_GONE:    return "TIMER GONE"
		GameMode.REVERSE:       return "REVERSED"
		GameMode.STRONG_CABLES: return "STRONG CABLES"
	return "STANDARD"


func get_scene_for_mode(mode: GameMode) -> String:
	match mode:
		GameMode.STANDARD:      return "res://scenes/game_modes/GameStandard.tscn"
		GameMode.TIMER_GONE:    return "res://scenes/game_modes/GameTimerGone.tscn"
		GameMode.REVERSE:       return "res://scenes/game_modes/GameReverse.tscn"
		GameMode.STRONG_CABLES: return "res://scenes/game_modes/GameStrongCables.tscn"
	return "res://scenes/game_modes/GameStandard.tscn"


func pick_random_unlocked_mode() -> GameMode:
	var available: Array = []
	for group in SaveManager.unlocked_groups:
		var m: GameMode = get_mode_for_group(int(group))
		if not available.has(m):
			available.append(m)
	if available.is_empty():
		return GameMode.STANDARD
	available.shuffle()
	return available[0] as GameMode


func get_unlocked_modes() -> Array:
	var modes: Array = []
	for group in SaveManager.unlocked_groups:
		var m: GameMode = get_mode_for_group(int(group))
		if not modes.has(m):
			modes.append(m)
	return modes

# ---------------------------------------------------------------------------
# Story level config
# ---------------------------------------------------------------------------

func _story_level_index() -> int:
	return (current_group - 1) * LEVELS_PER_GROUP + (current_level_in_group - 1)


func _get_story_config() -> Array:
	var idx := clampi(_story_level_index(), 0, STORY_LEVELS.size() - 1)
	return STORY_LEVELS[idx]


func _compute_endless_config() -> void:
	var displayed: int
	var cut: int
	match endless_level:
		1: displayed = 3; cut = 3
		2: displayed = 4; cut = 3
		3: displayed = 5; cut = 4
		_: displayed = 5; cut = randi_range(4, 5)
	var time := maxf(5.0, 10.0 - floor((endless_level - 1) / 10.0))
	_endless_config = [displayed, cut, time]


func _get_endless_config() -> Array:
	return _endless_config


func get_displayed_count(level: int = -1) -> int:
	if current_path == PathType.STORY:
		return _get_story_config()[0]
	return _get_endless_config()[0]


func get_cut_count(level: int = -1) -> int:
	if current_path == PathType.STORY:
		return _get_story_config()[1]
	return _get_endless_config()[1]


func get_time_limit(level: int = -1) -> float:
	if current_path == PathType.STORY:
		return _get_story_config()[2]
	return _get_endless_config()[2]

# ---------------------------------------------------------------------------
# Color generation
# ---------------------------------------------------------------------------

func generate_level_colors(level: int = -1) -> Dictionary:
	var displayed_count := get_displayed_count(level)
	var cut_count := get_cut_count(level)

	var indices: Array = []
	for i in range(COLOR_PALETTE.size()):
		indices.append(i)
	indices.shuffle()
	indices = indices.slice(0, displayed_count)

	var cut_indices: Array = indices.slice(0, cut_count)
	cut_indices.shuffle()

	var displayed: Array = []
	for idx in indices:
		displayed.append(_make_entry(int(idx)))

	var to_cut: Array = []
	for idx in cut_indices:
		to_cut.append(_make_entry(int(idx)))

	return {"displayed": displayed, "to_cut": to_cut}


func _make_entry(idx: int) -> Dictionary:
	return {
		"color": COLOR_PALETTE[idx],
		"name": COLOR_NAMES[idx],
		"color_index": idx,
	}

# ---------------------------------------------------------------------------
# Level outcome
# ---------------------------------------------------------------------------

func win_level(time_taken: float) -> void:
	last_time_taken = time_taken
	last_cables_cut = get_cut_count()

	match current_path:
		PathType.STORY:
			last_score_gained = 0
			level_won.emit(current_level_in_group)
		PathType.ENDLESS, PathType.CHALLENGE:
			last_score_gained = (session_score / 100 + 1) * 100
			session_score += last_score_gained
			level_won.emit(0)


func advance_level() -> void:
	match current_path:
		PathType.STORY:
			current_level_in_group += 1
		PathType.ENDLESS:
			endless_level += 1
			current_mode = pick_random_unlocked_mode()
			_compute_endless_config()
		PathType.CHALLENGE:
			pass


func is_group_complete() -> bool:
	return current_path == PathType.STORY and current_level_in_group > LEVELS_PER_GROUP


func complete_group() -> void:
	SaveManager.unlock_group(current_group + 1)


func lose_level(time_taken: float, cables_cut: int) -> void:
	last_time_taken = time_taken
	last_cables_cut = cables_cut

	match current_path:
		PathType.ENDLESS:
			SaveManager.update_endless_best(session_score)
		PathType.CHALLENGE:
			SaveManager.update_challenge_best(get_mode_name(current_mode), session_score)
		PathType.STORY:
			pass

	if current_path == PathType.STORY:
		level_lost.emit(current_level_in_group)
	else:
		level_lost.emit(0)


func reset_game() -> void:
	session_score = 0
	current_level_in_group = 1
	endless_level = 1

# ---------------------------------------------------------------------------
# Path start helpers
# ---------------------------------------------------------------------------

func start_story_group(group: int) -> void:
	current_path = PathType.STORY
	current_group = group
	current_level_in_group = 1
	current_mode = get_mode_for_group(group)
	session_score = 0


func start_endless() -> void:
	current_path = PathType.ENDLESS
	current_mode = pick_random_unlocked_mode()
	session_score = 0
	endless_level = 1
	_compute_endless_config()


func start_challenge(mode: GameMode) -> void:
	current_path = PathType.CHALLENGE
	current_mode = mode
	session_score = 0
