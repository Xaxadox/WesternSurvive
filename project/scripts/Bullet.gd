extends Area2D

var velocity = Vector2.RIGHT * 720.0
var damage = 6
var pierce = 1
var lifetime = 1.6
var hit_targets = {}
var visual = "bullet"
var color = Color("#ffe7a0")
var line_length = 20.0
var hit_radius = 5.0
var spin_speed = 0.0
var explode_radius = 0.0
var explode_on_hit = false
var explode_on_expire = false
var exploded = false

func _ready():
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func setup(direction, amount, bullet_speed, bullet_pierce, bullet_lifetime, options = {}):
	var safe_direction = direction.normalized()
	if safe_direction == Vector2.ZERO:
		safe_direction = Vector2.RIGHT

	velocity = safe_direction * bullet_speed
	damage = amount
	pierce = bullet_pierce
	lifetime = bullet_lifetime
	rotation = safe_direction.angle()
	visual = options.get("visual", visual)
	color = options.get("color", color)
	line_length = float(options.get("line_length", line_length))
	hit_radius = float(options.get("hit_radius", hit_radius))
	spin_speed = float(options.get("spin", 0.0))
	explode_radius = float(options.get("explode_radius", 0.0))
	explode_on_hit = bool(options.get("explode_on_hit", false))
	explode_on_expire = bool(options.get("explode_on_expire", false))
	_set_collision_radius(hit_radius)
	call_deferred("_damage_existing_overlaps")
	queue_redraw()

func _physics_process(delta):
	position += velocity * delta
	if spin_speed != 0.0:
		rotation += spin_speed * delta
	elif velocity.length() > 0.0:
		rotation = velocity.angle()

	lifetime -= delta
	if lifetime <= 0.0:
		if explode_on_expire:
			_explode()
		else:
			queue_free()

func _set_collision_radius(radius):
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape

func _damage_existing_overlaps():
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body):
	if exploded or not body.is_in_group("enemies"):
		return
	if hit_targets.has(body):
		return

	if explode_on_hit:
		_explode()
		return

	hit_targets[body] = true
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
	elif body.has_method("hurt"):
		body.hurt(damage, global_position)

	pierce -= 1
	if pierce <= 0:
		queue_free()

func _explode():
	if exploded:
		return

	exploded = true
	var radius = maxf(explode_radius, hit_radius)
	for enemy in _enemy_nodes():
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) <= radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage, global_position)
			elif enemy.has_method("hurt"):
				enemy.hurt(damage, global_position)

	queue_free()

func _enemy_nodes():
	var scene = get_tree().current_scene
	if scene != null:
		var enemy_root = scene.get_node_or_null("World/Enemies")
		if enemy_root != null:
			return enemy_root.get_children()
	return get_tree().get_nodes_in_group("enemies")

func _draw():
	match visual:
		"knife":
			_draw_knife()
		"lasso":
			_draw_lasso()
		"dynamite":
			_draw_dynamite()
		"fire":
			_draw_fire()
		"horseshoe":
			_draw_horseshoe()
		"rail":
			_draw_rail()
		"rail_spike":
			_draw_rail_spike()
		"lantern":
			_draw_lantern()
		"shard":
			_draw_shard()
		_:
			_draw_bullet()

func _draw_bullet():
	draw_line(Vector2(-line_length * 0.45, 0), Vector2(line_length * 0.45, 0), color, 4)
	draw_circle(Vector2(line_length * 0.45, 0), 4, Color("#fff6cf"))

func _draw_knife():
	draw_polygon(PackedVector2Array([
		Vector2(line_length * 0.55, 0),
		Vector2(-line_length * 0.35, -4),
		Vector2(-line_length * 0.50, 0),
		Vector2(-line_length * 0.35, 4)
	]), PackedColorArray([color, color, color, color]))
	draw_line(Vector2(-line_length * 0.55, 0), Vector2(-line_length * 0.30, 0), Color("#5b3a24"), 4)

func _draw_lasso():
	draw_arc(Vector2.ZERO, hit_radius, 0.0, TAU, 28, color, 3.0)
	draw_line(Vector2(-line_length * 0.5, 0), Vector2(line_length * 0.5, 0), color, 2.0)

func _draw_dynamite():
	draw_rect(Rect2(-8, -5, 16, 10), Color("#7e2a1f"))
	draw_line(Vector2(7, -4), Vector2(13, -10), Color("#e2c15f"), 2.0)
	draw_circle(Vector2(14, -11), 3, Color("#ffcf5a"))

func _draw_fire():
	draw_circle(Vector2.ZERO, maxf(hit_radius * 0.65, 7.0), Color(1.0, 0.26, 0.08, 0.55))
	draw_circle(Vector2(3, -2), maxf(hit_radius * 0.35, 5.0), Color(1.0, 0.82, 0.22, 0.75))

func _draw_horseshoe():
	draw_arc(Vector2.ZERO, hit_radius, 0.25 * PI, 1.75 * PI, 18, color, 4.0)
	draw_circle(Vector2(-hit_radius * 0.55, hit_radius * 0.68), 2.5, color)
	draw_circle(Vector2(hit_radius * 0.55, hit_radius * 0.68), 2.5, color)

func _draw_rail():
	draw_line(Vector2(-line_length * 0.55, -2), Vector2(line_length * 0.55, -2), color, 3.0)
	draw_line(Vector2(-line_length * 0.55, 2), Vector2(line_length * 0.55, 2), Color("#52616d"), 3.0)

func _draw_rail_spike():
	draw_polygon(PackedVector2Array([
		Vector2(line_length * 0.58, 0),
		Vector2(-line_length * 0.38, -5),
		Vector2(-line_length * 0.55, 0),
		Vector2(-line_length * 0.38, 5)
	]), PackedColorArray([color, Color("#7b8f99"), Color("#52616d"), Color("#7b8f99")]))

func _draw_lantern():
	draw_circle(Vector2.ZERO, maxf(hit_radius * 0.45, 7.0), Color(color.r, color.g, color.b, 0.28))
	draw_rect(Rect2(-5, -8, 10, 16), Color("#3c2a1d"))
	draw_circle(Vector2.ZERO, 5, color)

func _draw_shard():
	draw_line(Vector2(-line_length * 0.5, 0), Vector2(line_length * 0.5, 0), color, 3.0)
