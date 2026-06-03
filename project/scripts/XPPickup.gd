extends Area2D

const SpatialUtils = preload("res://scripts/SpatialUtils.gd")

var value = 1
var player = null
var players = []
var magnet_speed = 310.0

func setup(amount, target):
	value = amount
	if typeof(target) == TYPE_ARRAY:
		players = target
		player = null
	else:
		player = target
		players = [target]

func _physics_process(delta):
	player = _nearest_player()
	if not is_instance_valid(player):
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance < player.pickup_radius:
		global_position += to_player.normalized() * magnet_speed * delta

	if distance < 18.0:
		var main = get_tree().current_scene
		if main != null and main.has_method("add_xp"):
			if main.has_method("play_combat_sfx"):
				main.play_combat_sfx("xp_pickup")
			main.add_xp(value)
		queue_free()

func _nearest_player():
	return SpatialUtils.nearest_alive(global_position, players)

func _draw():
	var points = PackedVector2Array([
		Vector2(0, -9),
		Vector2(3, -3),
		Vector2(9, -3),
		Vector2(4, 2),
		Vector2(6, 9),
		Vector2(0, 5),
		Vector2(-6, 9),
		Vector2(-4, 2),
		Vector2(-9, -3),
		Vector2(-3, -3)
	])
	draw_colored_polygon(points, Color("#f4c34f"))
	draw_polyline(points, Color("#7a4a18"), 2.0, true)
