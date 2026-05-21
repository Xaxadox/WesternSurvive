extends CharacterBody2D

signal died(enemy)

const SpatialUtils = preload("res://scripts/SpatialUtils.gd")

var target = null
var targets = []
var max_health = 12
var health = 12
var speed = 105.0
var contact_damage = 8
var xp_value = 1
var body_color = Color("#7b2f28")
var hat_color = Color("#2d1c16")
var attack_range = 34.0
var stand_off_range = 27.0
var body_radius = 15.0
var target_radius = 17.0
var attack_delay = 0.55
var knockback = 10.0

var attack_cooldown = 0.0

func _ready():
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 0

func set_targets(new_targets):
	targets = new_targets

func setup(data):
	var scale_value = float(data.get("scale", 1.0))
	max_health = data.get("health", max_health)
	health = max_health
	speed = data.get("speed", speed)
	contact_damage = data.get("damage", contact_damage)
	xp_value = data.get("xp", xp_value)
	body_color = data.get("color", body_color)
	hat_color = data.get("hat", hat_color)
	scale = Vector2.ONE * scale_value
	body_radius = 15.0 * scale_value
	stand_off_range = body_radius + target_radius
	attack_range = maxf(float(data.get("attack_range", attack_range)), stand_off_range + 4.0)
	attack_delay = data.get("attack_delay", attack_delay)
	knockback = data.get("knockback", knockback)
	queue_redraw()

func _physics_process(delta):
	target = _nearest_target()
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	var to_target = target.global_position - global_position
	var distance = to_target.length()
	var direction = to_target / distance if distance > 0.001 else Vector2.RIGHT

	if distance > attack_range:
		velocity = direction * speed
		global_position += velocity * delta
	else:
		velocity = Vector2.ZERO
		if distance < stand_off_range:
			var retreat = minf(speed * delta * 0.55, stand_off_range - distance)
			global_position -= direction * retreat
		if attack_cooldown <= 0.0 and target.has_method("damage"):
			target.damage(contact_damage)
			attack_cooldown = attack_delay
	_apply_player_soft_collision(target)

func hurt(amount, source_position):
	take_damage(amount, source_position)

func take_damage(amount, source_position = null):
	health -= amount
	var hit_position = global_position if source_position == null else source_position
	if hit_position != global_position:
		global_position += (global_position - hit_position).normalized() * knockback

	if health <= 0:
		died.emit(self)
		call_deferred("queue_free")
	else:
		queue_redraw()

func _apply_player_soft_collision(current_target):
	if not is_instance_valid(current_target):
		return

	var away = global_position - current_target.global_position
	var distance = away.length()
	var minimum_distance = body_radius + target_radius
	if distance >= minimum_distance:
		return

	var direction = away / distance if distance > 0.001 else -current_target.aim_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	global_position += direction * (minimum_distance - distance)

func _nearest_target():
	return SpatialUtils.nearest_alive(global_position, targets, target)

func _draw():
	var hp_ratio = clamp(float(health) / float(max_health), 0.0, 1.0)

	draw_circle(Vector2(3, 8), 14, Color(0, 0, 0, 0.24))
	draw_circle(Vector2.ZERO, 15, body_color)
	draw_circle(Vector2(0, -8), 9, Color("#d38c62"))
	draw_rect(Rect2(-15, -17, 30, 5), hat_color)
	draw_rect(Rect2(-8, -23, 16, 8), hat_color)
	draw_line(Vector2(-7, 4), Vector2(9, 8), Color("#c6a05a"), 3)

	if hp_ratio < 1.0:
		draw_rect(Rect2(-16, 20, 32, 4), Color(0, 0, 0, 0.35))
		draw_rect(Rect2(-16, 20, 32 * hp_ratio, 4), Color("#f2d36b"))
