extends SceneTree

func _initialize():
	call_deferred("_run")

func _run():
	var main_scene = load("res://scenes/main.tscn")
	var combos = [
		["ghost_town", "gunslinger"],
		["broken_fort", "sheriff"],
		["canyon", "bounty_hunter"],
		["mine", "shaman"]
	]

	for combo in combos:
		var main = main_scene.instantiate()
		root.add_child(main)
		await process_frame
		main.progress["unlocked_weapons"] = main.SECRET_WEAPONS.duplicate()
		main.progress["unlocked_stages"] = ["ghost_town", "broken_fort", "canyon", "mine", "bonus"]
		main._start_run(combo[0], combo[1], 4)

		for weapon_id in main.BASE_WEAPONS + main.SECRET_WEAPONS:
			if not main.weapon_levels.has(weapon_id):
				main._add_weapon(weapon_id, true)
			main.weapon_levels[weapon_id] = main.MAX_WEAPON_LEVEL
			main.weapon_evolved[weapon_id] = true
			main.weapon_timers[weapon_id] = 0.01

		for i in range(90):
			await process_frame

		main.queue_free()
		await process_frame

	quit(0)
