extends Node2D

const SpatialUtils = preload("res://scripts/SpatialUtils.gd")

var kind = "food"
var players = []
var heal_amount = 24
var damage_amount = 36
var explosion_radius = 118.0
var fuse_time = 2.35
var trigger_radius = 68.0
var armed = false
var exploded = false
var fuse_left = 0.0
var explosion_left = 0.0

func setup(data, target_players):
	kind = str(data.get("kind", "food"))
	players = target_players
	heal_amount = int(data.get("heal", heal_amount))
	damage_amount = int(data.get("damage", damage_amount))
	explosion_radius = float(data.get("radius", explosion_radius))
	fuse_time = float(data.get("fuse", fuse_time))
	fuse_left = fuse_time
	queue_redraw()

func _physics_process(delta):
	if exploded:
		explosion_left -= delta
		if explosion_left <= 0.0:
			queue_free()
		queue_redraw()
		return

	if kind == "food":
		_process_food()
		return

	_process_bomb(delta)

func _process_food():
	for current_player in players:
		if not SpatialUtils.is_alive(current_player):
			continue
		if global_position.distance_to(current_player.global_position) <= 28.0:
			if int(current_player.health) >= int(current_player.max_health):
				return
			current_player.heal(heal_amount)
			queue_free()
			return

func _process_bomb(delta):
	if not armed and _near_actor(trigger_radius):
		armed = true
		fuse_left = fuse_time

	if not armed:
		return

	fuse_left -= delta
	if fuse_left <= 0.0:
		_explode()
	else:
		queue_redraw()

func _near_actor(radius):
	return (
		SpatialUtils.has_alive_in_radius(global_position, players, radius)
		or SpatialUtils.has_valid_in_radius(global_position, _enemy_nodes(), radius)
	)

func _explode():
	if exploded:
		return

	exploded = true
	explosion_left = 0.18

	for current_player in SpatialUtils.alive_in_radius(global_position, players, explosion_radius):
		if current_player.has_method("take_damage"):
			current_player.take_damage(damage_amount, global_position)
		else:
			current_player.damage(damage_amount)

	for enemy in SpatialUtils.valid_in_radius(global_position, _enemy_nodes(), explosion_radius):
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage_amount, global_position)
		elif enemy.has_method("hurt"):
			enemy.hurt(damage_amount, global_position)

	queue_redraw()

func _enemy_nodes():
	var scene = get_tree().current_scene
	if scene != null:
		var enemy_root = scene.get_node_or_null("World/Enemies")
		if enemy_root != null:
			return enemy_root.get_children()
	return get_tree().get_nodes_in_group("enemies")

func _draw():
	if exploded:
		draw_circle(Vector2.ZERO, explosion_radius, Color(1.0, 0.30, 0.08, 0.22))
		draw_circle(Vector2.ZERO, explosion_radius * 0.52, Color(1.0, 0.78, 0.22, 0.38))
		return

	if kind == "food":
		_draw_food()
	else:
		_draw_bomb()

func _draw_food():
	draw_circle(Vector2(3, 8), 15, Color(0, 0, 0, 0.22))
	draw_rect(Rect2(-12, -8, 24, 20), Color("#d8b551"))
	draw_rect(Rect2(-10, -12, 20, 5), Color("#f0d684"))
	draw_circle(Vector2(0, 1), 6, Color("#a73c2d"))
	draw_line(Vector2(0, -5), Vector2(5, -11), Color("#3f6f36"), 3)

func _draw_bomb():
	var blink = armed and int(Time.get_ticks_msec() / 130) % 2 == 0
	var shell = Color("#2a211d") if not blink else Color("#b33b2e")
	var fuse_ratio = clampf(fuse_left / maxf(fuse_time, 0.01), 0.0, 1.0)

	draw_circle(Vector2(3, 8), 16, Color(0, 0, 0, 0.24))
	draw_circle(Vector2.ZERO, 16, shell)
	draw_rect(Rect2(-5, -20, 10, 8), Color("#5b3a24"))
	draw_line(Vector2(0, -20), Vector2(10, -31), Color("#e2c15f"), 2)
	draw_circle(Vector2(12, -33), 4, Color("#ffcf5a") if armed else Color("#8a6a3e"))

	if armed:
		draw_arc(Vector2.ZERO, 23, -PI * 0.5, -PI * 0.5 + TAU * fuse_ratio, 30, Color("#ffcf5a"), 3)
