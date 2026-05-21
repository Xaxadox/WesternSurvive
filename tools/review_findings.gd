extends SceneTree

const PROGRESS_PATH = "F:/WesternSurvive/cache/progress.json"

func _initialize():
	call_deferred("_run")

func _run():
	var progress_existed = FileAccess.file_exists(PROGRESS_PATH)
	var original_progress = ""
	if progress_existed:
		var progress_file = FileAccess.open(PROGRESS_PATH, FileAccess.READ)
		if progress_file != null:
			original_progress = progress_file.get_as_text()

	var failures = []
	var main_scene = load("res://scenes/main.tscn")
	for count in range(1, 5):
		var main = main_scene.instantiate()
		root.add_child(main)
		await process_frame
		main._start_run("ghost_town", "gunslinger", count)
		await process_frame
		if main.players.size() != count:
			failures.append("player_count_%d_created_%d" % [count, main.players.size()])
		main.queue_free()
		await process_frame

	var co_op = main_scene.instantiate()
	root.add_child(co_op)
	await process_frame
	co_op._start_run("ghost_town", "gunslinger", 4)
	await process_frame

	var p1 = co_op.players[0]
	var p2 = co_op.players[1]
	p2.global_position = Vector2(2400, 0)
	p1.damage(9999)
	await process_frame
	if co_op.is_game_over:
		failures.append("game_over_after_only_p1_died")
	if p1.get_node("Camera2D").enabled and not p2.get_node("Camera2D").enabled:
		failures.append("camera_remains_on_dead_p1")

	var before = co_op.enemies.get_child_count()
	co_op._spawn_enemy(false)
	await process_frame
	var spawned = co_op.enemies.get_child(co_op.enemies.get_child_count() - 1)
	var dist_p1 = spawned.global_position.distance_to(p1.global_position)
	var dist_p2 = spawned.global_position.distance_to(p2.global_position)
	if dist_p1 < 900.0 and dist_p2 > 1200.0:
		failures.append("spawn_still_anchors_to_dead_p1")

	co_op.queue_free()
	await process_frame

	var unlock_main = main_scene.instantiate()
	root.add_child(unlock_main)
	await process_frame
	unlock_main.progress["unlocked_weapons"] = []
	unlock_main.progress["unlocked_stages"] = ["ghost_town", "broken_fort", "canyon", "mine"]
	var unlock_cases = [
		["ghost_town", "gunslinger", "revolver", "golden_revolver"],
		["broken_fort", "sheriff", "shotgun", "coach_gun"],
		["canyon", "bounty_hunter", "rifle", "rail_spike"],
		["mine", "shaman", "fire_bottle", "ghost_lantern"]
	]
	for unlock_case in unlock_cases:
		unlock_main._start_run(unlock_case[0], unlock_case[1], 1)
		unlock_main.weapon_levels[unlock_case[2]] = 4
		unlock_main.weapon_evolved[unlock_case[2]] = false
		unlock_main._upgrade_weapon(unlock_case[2])
		if not unlock_main.progress["unlocked_weapons"].has(unlock_case[3]):
			failures.append("unlock_failed_" + unlock_case[3])

	if not unlock_main.progress["unlocked_stages"].has("bonus"):
		failures.append("bonus_not_unlocked_after_4_secret_weapons")

	unlock_main.queue_free()
	await process_frame
	_restore_progress(progress_existed, original_progress)

	if failures.is_empty():
		print("review_findings: ok")
		quit(0)
	else:
		print("review_findings: " + ",".join(failures))
		quit(1)

func _restore_progress(progress_existed, original_progress):
	if progress_existed:
		var file = FileAccess.open(PROGRESS_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(original_progress)
	elif FileAccess.file_exists(PROGRESS_PATH):
		DirAccess.remove_absolute(PROGRESS_PATH)
