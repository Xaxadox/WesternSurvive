extends Area2D

var velocity = Vector2.RIGHT * 720.0
var damage = 6
var pierce = 1
var lifetime = 1.6
var initial_lifetime = 1.6
var age = 0.0
var hit_targets = {}
var origin_position = Vector2.ZERO
var source_weapon = ""
var source_character_id = ""
var source_shooter = null
var damage_kind = ""
var visual = "bullet"
var color = Color("#ffe7a0")
var line_length = 20.0
var hit_radius = 5.0
var spin_speed = 0.0
var medium_range = 0.0
var far_range = 0.0
var medium_damage_mult = 1.0
var far_damage_mult = 1.0
var no_damage_past_far = false
var slow_factor = 1.0
var slow_duration = 0.0
var crit_range = 0.0
var crit_chance = 0.0
var crit_multiplier = 1.0
var crit_speed_bonus = 0.0
var crit_speed_duration = 0.0
var explode_radius = 0.0
var explode_on_hit = false
var explode_on_expire = false
var exploded = false
var ricochet_count = 0
var max_ricochets = 2
var ground_fire_on_hit = false
var ground_fire_on_expire = false
var ground_fire_active = false
var ground_fire_radius = 0.0
var ground_fire_duration = 0.0
var dot_interval = 0.45
var dot_timer = 0.0

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
	initial_lifetime = bullet_lifetime
	age = 0.0
	origin_position = global_position
	rotation = safe_direction.angle()
	source_weapon = str(options.get("source_weapon", ""))
	source_character_id = str(options.get("source_character_id", ""))
	source_shooter = options.get("source_shooter", null)
	damage_kind = str(options.get("damage_kind", ""))
	visual = options.get("visual", visual)
	color = options.get("color", color)
	line_length = float(options.get("line_length", line_length))
	hit_radius = float(options.get("hit_radius", hit_radius))
	spin_speed = float(options.get("spin", 0.0))
	medium_range = float(options.get("medium_range", 0.0))
	far_range = float(options.get("far_range", 0.0))
	medium_damage_mult = float(options.get("medium_damage_mult", 1.0))
	far_damage_mult = float(options.get("far_damage_mult", 1.0))
	no_damage_past_far = bool(options.get("no_damage_past_far", false))
	slow_factor = float(options.get("slow_factor", 1.0))
	slow_duration = float(options.get("slow_duration", 0.0))
	crit_range = float(options.get("crit_range", 0.0))
	crit_chance = float(options.get("crit_chance", 0.0))
	crit_multiplier = float(options.get("crit_multiplier", 1.0))
	crit_speed_bonus = float(options.get("crit_speed_bonus", 0.0))
	crit_speed_duration = float(options.get("crit_speed_duration", 0.0))
	explode_radius = float(options.get("explode_radius", 0.0))
	explode_on_hit = bool(options.get("explode_on_hit", false))
	explode_on_expire = bool(options.get("explode_on_expire", false))
	max_ricochets = int(options.get("max_ricochets", max_ricochets))
	ground_fire_on_hit = bool(options.get("ground_fire_on_hit", false))
	ground_fire_on_expire = bool(options.get("ground_fire_on_expire", false))
	ground_fire_radius = float(options.get("ground_fire_radius", 0.0))
	ground_fire_duration = float(options.get("ground_fire_duration", 0.0))
	dot_interval = float(options.get("dot_interval", dot_interval))
	dot_timer = 0.0
	_set_collision_radius(hit_radius)
	call_deferred("_damage_existing_overlaps")
	queue_redraw()

func _physics_process(delta):
	age += delta
	if ground_fire_active:
		_process_ground_fire(delta)
		return

	var next_global_position = global_position + velocity * delta
	if _handle_stage_wall(next_global_position):
		if is_queued_for_deletion():
			return
	else:
		global_position = next_global_position

	if spin_speed != 0.0:
		rotation += spin_speed * delta
	elif velocity.length() > 0.0:
		rotation = velocity.angle()

	lifetime -= delta
	if lifetime <= 0.0:
		if ground_fire_on_expire:
			_start_ground_fire()
		elif explode_on_expire:
			_explode()
		else:
			queue_free()

func _process_ground_fire(delta):
	lifetime -= delta
	dot_timer -= delta
	if dot_timer <= 0.0:
		dot_timer = maxf(dot_interval, 0.05)
		_damage_ground_fire()
	if lifetime <= 0.0:
		queue_free()
	queue_redraw()

func _set_collision_radius(radius):
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape

func _handle_stage_wall(next_global_position):
	var floor = _stage_floor()
	if floor == null or not floor.has_method("is_mine_walkable"):
		return false
	if floor.is_mine_walkable(next_global_position):
		return false

	if _can_ricochet():
		_apply_ricochet(floor, next_global_position)
		return true

	if ground_fire_on_hit or ground_fire_on_expire:
		_start_ground_fire()
	elif explode_on_hit or explode_on_expire:
		_explode()
	else:
		queue_free()
	return true

func _can_ricochet():
	return ricochet_count < max_ricochets and (visual == "bullet" or visual == "magnum" or visual == "rifle_round" or visual == "shotgun_pellet" or visual == "knife")

func _apply_ricochet(floor, next_global_position):
	var current = global_position
	var x_blocked = not floor.is_mine_walkable(Vector2(next_global_position.x, current.y))
	var y_blocked = not floor.is_mine_walkable(Vector2(current.x, next_global_position.y))

	if x_blocked:
		velocity.x = -velocity.x
	if y_blocked:
		velocity.y = -velocity.y
	if not x_blocked and not y_blocked:
		var normal = (current - next_global_position).normalized()
		if normal == Vector2.ZERO:
			normal = -velocity.normalized()
		velocity = velocity.bounce(normal)

	ricochet_count += 1
	rotation = velocity.angle()

func _stage_floor():
	var scene = get_tree().current_scene
	if scene == null:
		return null
	return scene.get_node_or_null("World/DesertFloor")

func _damage_existing_overlaps():
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body):
	if exploded or ground_fire_active or not body.is_in_group("enemies"):
		return
	if hit_targets.has(body):
		return

	if ground_fire_on_hit:
		_start_ground_fire()
		return

	if explode_on_hit:
		_explode()
		return

	hit_targets[body] = true
	var final_damage = _hit_damage(body)
	if final_damage > 0:
		_apply_damage_to_body(body, final_damage, true, global_position)
		_apply_slow_to_body(body)

	pierce -= 1
	if pierce <= 0:
		queue_free()

func _hit_damage(body):
	var final_damage = float(damage)
	var distance = origin_position.distance_to(body.global_position)
	if far_range > 0.0 and distance > far_range:
		if no_damage_past_far:
			return 0
		final_damage *= far_damage_mult
	elif medium_range > 0.0 and distance > medium_range:
		final_damage *= medium_damage_mult

	if crit_range > 0.0 and distance >= crit_range and randf() <= clampf(crit_chance, 0.0, 1.0):
		final_damage *= maxf(crit_multiplier, 1.0)
		_apply_crit_bonus()

	if final_damage <= 0.0:
		return 0
	return maxi(1, int(ceil(final_damage)))

func _apply_damage_to_body(body, amount, play_hit_sfx, hit_position):
	if play_hit_sfx:
		_play_combat_sfx("enemy_hit")
	if body.has_method("take_damage"):
		body.take_damage(amount, hit_position, _damage_source())
	elif body.has_method("hurt"):
		body.hurt(amount, hit_position)

func _apply_slow_to_body(body):
	if slow_duration <= 0.0 or slow_factor >= 1.0:
		return
	if body.has_method("apply_slow"):
		body.apply_slow(slow_factor, slow_duration)

func _apply_crit_bonus():
	if source_character_id != "bounty_hunter":
		return
	if crit_speed_bonus <= 0.0 or crit_speed_duration <= 0.0:
		return
	if is_instance_valid(source_shooter) and source_shooter.has_method("apply_temporary_speed_bonus"):
		source_shooter.apply_temporary_speed_bonus(crit_speed_bonus, crit_speed_duration)

func _damage_source():
	var source = {
		"weapon": source_weapon,
		"character_id": source_character_id,
		"damage_kind": damage_kind
	}
	if is_instance_valid(source_shooter):
		source["shooter"] = source_shooter
	return source

func _explode():
	if exploded:
		return

	exploded = true
	_play_combat_sfx("explosion")
	var radius = maxf(explode_radius, hit_radius)
	for enemy in _enemy_nodes():
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) <= radius:
			_apply_damage_to_body(enemy, damage, false, global_position)

	queue_free()

func _start_ground_fire():
	if ground_fire_active:
		return

	ground_fire_active = true
	exploded = false
	velocity = Vector2.ZERO
	rotation = 0.0
	hit_targets.clear()
	lifetime = maxf(ground_fire_duration, 0.1)
	initial_lifetime = lifetime
	age = 0.0
	hit_radius = maxf(ground_fire_radius, hit_radius)
	_set_collision_radius(hit_radius)
	_play_combat_sfx("explosion")
	dot_timer = 0.0
	queue_redraw()

func _damage_ground_fire():
	for enemy in _enemy_nodes():
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) <= hit_radius:
			_apply_damage_to_body(enemy, damage, false, enemy.global_position)

func _play_combat_sfx(effect_id):
	var scene = get_tree().current_scene
	if scene != null and scene.has_method("play_combat_sfx"):
		scene.play_combat_sfx(effect_id)

func _enemy_nodes():
	var scene = get_tree().current_scene
	if scene != null:
		var enemy_root = scene.get_node_or_null("World/Enemies")
		if enemy_root != null:
			return enemy_root.get_children()
	return get_tree().get_nodes_in_group("enemies")

func _draw():
	if ground_fire_active:
		_draw_fire()
		return

	match visual:
		"magnum":
			_draw_magnum_round()
		"shotgun_pellet":
			_draw_shotgun_pellet()
		"rifle_round":
			_draw_rifle_round()
		"molotov":
			_draw_molotov()
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

func _life_ratio():
	return clampf(lifetime / maxf(initial_lifetime, 0.001), 0.0, 1.0)

func _birth_flash():
	return clampf(1.0 - age / 0.14, 0.0, 1.0)

func _draw_magnum_round():
	var flash = _birth_flash()
	var trail_alpha = clampf(_life_ratio() * 0.58 + flash * 0.28, 0.0, 0.82)
	draw_line(Vector2(-line_length * 0.92, 0), Vector2(-line_length * 0.18, 0), Color(color.r, color.g, color.b, trail_alpha), 4.0)
	draw_line(Vector2(-line_length * 0.68, 0), Vector2(line_length * 0.22, 0), Color(1.0, 0.94, 0.62, 0.38), 2.0)
	if flash > 0.0:
		draw_polygon(PackedVector2Array([
			Vector2(-line_length * 0.92, 0),
			Vector2(-line_length * 0.52, -7.0 * flash),
			Vector2(-line_length * 0.32, 0),
			Vector2(-line_length * 0.52, 7.0 * flash)
		]), PackedColorArray([
			Color(1.0, 0.76, 0.28, flash * 0.70),
			Color(1.0, 0.88, 0.35, flash * 0.55),
			Color(1.0, 0.95, 0.70, flash * 0.45),
			Color(1.0, 0.48, 0.18, flash * 0.42)
		]))
		draw_circle(Vector2(-line_length * 0.76, -4.0), 4.0 * flash, Color(0.72, 0.68, 0.58, flash * 0.32))
	draw_polygon(PackedVector2Array([
		Vector2(line_length * 0.44, 0.0),
		Vector2(line_length * 0.16, -4.0),
		Vector2(-line_length * 0.04, -3.0),
		Vector2(-line_length * 0.12, 0.0),
		Vector2(-line_length * 0.04, 3.0),
		Vector2(line_length * 0.16, 4.0)
	]), PackedColorArray([
		Color("#fff1a6"),
		Color("#d7a849"),
		Color("#9c6b2c"),
		Color("#7a4a25"),
		Color("#b97d32"),
		Color("#efca68")
	]))

func _draw_shotgun_pellet():
	var flash = _birth_flash()
	draw_line(Vector2(-line_length * 0.92, 0), Vector2(-line_length * 0.18, 0), Color(0.82, 0.77, 0.65, 0.34 + flash * 0.26), 3.0)
	draw_circle(Vector2(-line_length * 0.55, sin(age * 37.0) * 1.2), 2.8 + flash * 2.2, Color(0.58, 0.54, 0.46, 0.22 + flash * 0.25))
	draw_circle(Vector2(line_length * 0.20, 0), 4.0, Color("#2b241f"))
	draw_circle(Vector2(line_length * 0.20, -1.0), 2.0, Color("#f6e0a4"))

func _draw_rifle_round():
	var flash = _birth_flash()
	draw_line(Vector2(-line_length * 1.12, 0), Vector2(line_length * 0.36, 0), Color(color.r, color.g, color.b, 0.46), 3.0)
	draw_line(Vector2(-line_length * 0.88, 0), Vector2(line_length * 0.48, 0), Color(0.86, 0.96, 1.0, 0.72), 1.5)
	if flash > 0.0:
		draw_line(Vector2(-line_length * 1.05, -3.0), Vector2(-line_length * 0.30, 3.0), Color(0.80, 0.92, 1.0, flash * 0.42), 2.0)
	draw_polygon(PackedVector2Array([
		Vector2(line_length * 0.58, 0),
		Vector2(line_length * 0.18, -3.5),
		Vector2(-line_length * 0.05, 0),
		Vector2(line_length * 0.18, 3.5)
	]), PackedColorArray([Color("#f3fbff"), color, Color("#667987"), color]))

func _draw_molotov():
	var flame = 0.72 + sin(age * 24.0) * 0.20
	draw_line(Vector2(-13, 0), Vector2(9, 0), Color("#4b2f20"), 8.0)
	draw_line(Vector2(-9, -2), Vector2(8, -2), Color("#8a5a36"), 3.0)
	draw_rect(Rect2(4, -4, 7, 8), Color("#2a211b"))
	draw_polygon(PackedVector2Array([
		Vector2(12, 0),
		Vector2(22, -7 * flame),
		Vector2(18, 0),
		Vector2(23, 7 * flame)
	]), PackedColorArray([
		Color(1.0, 0.90, 0.22, 0.84),
		Color(1.0, 0.28, 0.06, 0.64),
		Color(1.0, 0.72, 0.10, 0.72),
		Color(1.0, 0.18, 0.04, 0.52)
	]))
	draw_line(Vector2(-line_length * 0.90, 0), Vector2(-line_length * 0.25, 0), Color(1.0, 0.34, 0.08, 0.28), 3.0)

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
	if ground_fire_active:
		draw_circle(Vector2.ZERO, hit_radius, Color(1.0, 0.20, 0.05, 0.18))
		draw_circle(Vector2.ZERO, hit_radius * 0.58, Color(1.0, 0.48, 0.08, 0.30))
		draw_circle(Vector2(6, -4), maxf(hit_radius * 0.22, 8.0), Color(1.0, 0.84, 0.22, 0.52))
		return
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
