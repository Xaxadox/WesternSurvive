extends SceneTree

func _initialize():
	call_deferred("_run")

func _run():
	var failures = []
	var main_scene = load("res://scenes/main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var hud = main.hud
	var start_layer = hud.start_layer
	var panel = null
	for child in start_layer.get_children():
		if child is PanelContainer:
			panel = child
			break

	if panel == null:
		failures.append("start_panel_missing")
	else:
		var panel_rect = panel.get_global_rect()
		var start_button_rect = hud.start_button.get_global_rect()
		var stage_list_rect = hud.stage_list.get_global_rect()
		var character_list_rect = hud.character_list.get_global_rect()
		if start_button_rect.end.y > panel_rect.end.y:
			failures.append("start_button_overflows_panel")
		if stage_list_rect.end.y > panel_rect.end.y:
			failures.append("stage_list_overflows_panel")
		if character_list_rect.end.y > panel_rect.end.y:
			failures.append("character_list_overflows_panel")

	main.queue_free()
	await process_frame

	if failures.is_empty():
		print("review_layout: ok")
		quit(0)
	else:
		print("review_layout: " + ",".join(failures))
		quit(1)
