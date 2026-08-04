extends Node

## Persists player progression to user://save.json
## Autoloaded as "SaveManager"

const SAVE_PATH := "user://save.json"

## Set to 1-10 to mark groups 1..N as complete in debug builds (0 = disabled).
## Has no effect in release exports.
const DEBUG_COMPLETE_UP_TO := 1

# Groups unlocked by the player (group numbers, 1-based)
# Group 1 is always unlocked by default.
var unlocked_groups: Array[int] = [1]

# Best scores
var endless_best: int = 0
var challenge_best: Dictionary = {}  # { "STANDARD": 0, "REVERSE": 0, ... }


func _ready() -> void:
	load_data()
	if OS.is_debug_build() and DEBUG_COMPLETE_UP_TO > 0:
		for g in range(1, DEBUG_COMPLETE_UP_TO + 2):  # +2: unlock N+1 so group N counts as completed
			if not unlocked_groups.has(g):
				unlocked_groups.append(g)


func is_group_unlocked(group: int) -> bool:
	return group == 1 or unlocked_groups.has(group)


## A group is completed when the next one has been unlocked.
## Works for group 10 too: completing it calls unlock_group(11),
## so is_group_unlocked(11) returns true.
func is_group_completed(group: int) -> bool:
	return is_group_unlocked(group + 1)


func unlock_group(group: int) -> void:
	if not unlocked_groups.has(group):
		unlocked_groups.append(group)
		save_data()


## Endless and Challenge paths unlock once group 1 is cleared (i.e. group 2 is unlocked).
func are_extra_paths_unlocked() -> bool:
	return is_group_unlocked(2)


func update_endless_best(score: int) -> void:
	if score > endless_best:
		endless_best = score
		save_data()


func update_challenge_best(mode_name: String, score: int) -> void:
	var current: int = challenge_best.get(mode_name, 0)
	if score > current:
		challenge_best[mode_name] = score
		save_data()


func get_challenge_best(mode_name: String) -> int:
	return challenge_best.get(mode_name, 0)


func save_data() -> void:
	var data := {
		"unlocked_groups": unlocked_groups,
		"endless_best": endless_best,
		"challenge_best": challenge_best,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		return

	if parsed.has("unlocked_groups"):
		unlocked_groups.clear()
		for g in parsed["unlocked_groups"]:
			unlocked_groups.append(int(g))
		# Always ensure group 1 is in the list
		if not unlocked_groups.has(1):
			unlocked_groups.append(1)

	if parsed.has("endless_best"):
		endless_best = int(parsed["endless_best"])

	if parsed.has("challenge_best"):
		challenge_best = parsed["challenge_best"]
