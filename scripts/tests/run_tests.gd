extends SceneTree

## Headless smoke-test runner.
## Run with: godot --headless --script res://scripts/tests/run_tests.gd
## Exits with code 0 if all checks pass, 1 otherwise.

var _failures: Array[String] = []
var GameManager: Node


func _initialize() -> void:
	await process_frame
	GameManager = root.get_node("/root/GameManager")
	_test_game_manager_logic()
	await process_frame
	await _test_scenes_load()
	_report_and_quit()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("FAIL: %s" % message)
	else:
		print("PASS: %s" % message)


func _test_game_manager_logic() -> void:
	print("--- Testing GameManager logic ---")

	GameManager.reset_game()
	_expect(GameManager.current_level == 1, "current_level resets to 1")
	_expect(GameManager.score == 0, "score resets to 0")

	_expect(GameManager.get_cable_count(1) == GameManager.BASE_CABLE_COUNT,
		"level 1 has base cable count")
	_expect(GameManager.get_cable_count(5) > GameManager.get_cable_count(1),
		"cable count increases with level")
	_expect(GameManager.get_cable_count(100) <= GameManager.COLOR_PALETTE.size(),
		"cable count never exceeds palette size")

	_expect(GameManager.get_time_limit(5) > GameManager.get_time_limit(1),
		"time limit increases with level")

	var colors_1: Array[Dictionary] = GameManager.generate_level_colors(1)
	_expect(colors_1.size() == GameManager.get_cable_count(1),
		"generate_level_colors returns correct count for level 1")

	var names: Array = []
	for entry in colors_1:
		names.append(entry["name"])
	var unique_names: Array = []
	for n in names:
		if not unique_names.has(n):
			unique_names.append(n)
	_expect(unique_names.size() == names.size(),
		"generate_level_colors returns unique colors")

	var level_before: int = GameManager.current_level
	var score_before: int = GameManager.score
	GameManager.win_level()
	_expect(GameManager.current_level == level_before + 1,
		"win_level increments current_level")
	_expect(GameManager.score > score_before,
		"win_level increases score")


func _test_scenes_load() -> void:
	print("--- Testing scenes load and instantiate ---")

	var scene_paths: Array[String] = [
		"res://scenes/main_menu/MainMenu.tscn",
		"res://scenes/game/Game.tscn",
		"res://scenes/game/Cable.tscn",
		"res://scenes/game_over/GameOver.tscn",
	]

	for path in scene_paths:
		var packed: PackedScene = load(path)
		_expect(packed != null, "scene loads: %s" % path)
		if packed == null:
			continue

		var instance: Node = packed.instantiate()
		_expect(instance != null, "scene instantiates: %s" % path)
		if instance == null:
			continue

		root.add_child(instance)
		await process_frame

		instance.queue_free()
		await process_frame


func _report_and_quit() -> void:
	print("")
	if _failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		print("%d TEST(S) FAILED:" % _failures.size())
		for f in _failures:
			print(" - %s" % f)
		quit(1)
