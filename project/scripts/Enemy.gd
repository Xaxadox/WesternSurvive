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
var sprite_path = ""
var sprite_texture: Texture2D = null
var sprite_walk_textures = []
var sprite_animations = {}
var sprite_height = 0.0
var sprite_offset = Vector2.ZERO
var sprite_anim_time = 0.0
var sprite_idle_time = 0.0
var sprite_facing = Vector2.DOWN
var sprite_direction_key = "down"
var sprite_animation_fps = 8.5
var sprite_flip_h = false

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
	sprite_path = str(data.get("sprite", ""))
	sprite_texture = _load_sprite(sprite_path)
	sprite_walk_textures = _load_sprite_list(data.get("walk_sprites", []))
	sprite_animations = _load_animation_map(data.get("animations", {}))
	sprite_animation_fps = float(data.get("animation_fps", 8.5))
	sprite_height = float(data.get("sprite_height", 0.0))
	sprite_offset = data.get("sprite_offset", Vector2.ZERO)
	sprite_anim_time = 0.0
	sprite_idle_time = 0.0
	sprite_facing = Vector2.DOWN
	sprite_direction_key = "down"
	sprite_flip_h = false
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
	_update_sprite_animation(delta, direction)
	_apply_player_soft_collision(target)
	if sprite_texture != null:
		queue_redraw()

func _update_sprite_animation(delta, direction):
	sprite_idle_time += delta
	if direction.length() > 0.01:
		sprite_facing = direction.normalized()
		sprite_direction_key = _direction_key(sprite_facing)
		if sprite_direction_key == "side" or absf(sprite_facing.x) > 0.2:
			sprite_flip_h = sprite_facing.x < 0.0
	if velocity.length() <= 1.0:
		sprite_anim_time = 0.0
		return
	sprite_anim_time += delta * clampf(velocity.length() / maxf(speed, 1.0), 0.75, 1.65)

func _direction_key(direction):
	if direction.length() <= 0.01:
		return sprite_direction_key
	var horizontal = absf(direction.x)
	var vertical = absf(direction.y)
	if horizontal >= vertical * 0.75:
		return "side"
	return "up" if direction.y < 0.0 else "down"

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
	var active_sprite = _current_sprite_texture()
	if active_sprite != null and sprite_height > 0.0:
		_draw_sprite(active_sprite, sprite_height, sprite_offset, Color.WHITE)
	else:
		draw_circle(Vector2.ZERO, 15, body_color)
		draw_circle(Vector2(0, -8), 9, Color("#d38c62"))
		draw_rect(Rect2(-15, -17, 30, 5), hat_color)
		draw_rect(Rect2(-8, -23, 16, 8), hat_color)
		draw_line(Vector2(-7, 4), Vector2(9, 8), Color("#c6a05a"), 3)

	if hp_ratio < 1.0:
		var bar_y = 20.0
		if sprite_texture != null and sprite_height > 0.0:
			bar_y = maxf(20.0, sprite_offset.y + sprite_height * 0.5 + 6.0)
		draw_rect(Rect2(-16, bar_y, 32, 4), Color(0, 0, 0, 0.35))
		draw_rect(Rect2(-16, bar_y, 32 * hp_ratio, 4), Color("#f2d36b"))

func _load_sprite(path):
	if path == "":
		return null

	if ResourceLoader.exists(path):
		var loaded = load(path)
		if loaded is Texture2D:
			return loaded

	var file_path = ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	var image = Image.new()
	if image.load(file_path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_sprite_list(paths):
	var result = []
	if typeof(paths) != TYPE_ARRAY:
		return result
	for path_value in paths:
		var texture = _load_sprite(str(path_value))
		if texture != null:
			result.append(texture)
	return result

func _load_animation_map(animations):
	var result = {}
	if typeof(animations) != TYPE_DICTIONARY:
		return result
	for key in animations.keys():
		var frames = _load_sprite_list(animations[key])
		if not frames.is_empty():
			result[str(key)] = frames
	return result

func _current_sprite_texture():
	var moving = velocity.length() > 1.0
	if not sprite_animations.is_empty():
		var prefix = "walk" if moving else "idle"
		var active = _animation_frame("%s_%s" % [prefix, sprite_direction_key], moving)
		if active != null:
			return active
		active = _animation_frame("%s_down" % prefix, moving)
		if active != null:
			return active
		active = _animation_frame("idle_down", false)
		if active != null:
			return active
	if moving and not sprite_walk_textures.is_empty():
		var index = int(sprite_anim_time * sprite_animation_fps) % sprite_walk_textures.size()
		return sprite_walk_textures[index]
	return sprite_texture

func _animation_frame(key, moving):
	var frames = sprite_animations.get(key, [])
	if typeof(frames) != TYPE_ARRAY or frames.is_empty():
		return null
	var time = sprite_anim_time if moving else sprite_idle_time
	var fps = sprite_animation_fps if moving else 1.5
	var index = int(time * fps) % frames.size()
	return frames[index]

func _draw_sprite(texture, height, offset, modulate):
	var aspect = float(texture.get_width()) / float(maxi(texture.get_height(), 1))
	var size = Vector2(height * aspect, height)
	var moving = velocity.length() > 1.0
	var phase = sprite_anim_time * TAU * 3.2
	var idle_phase = sprite_idle_time * TAU * 0.45
	var bob = sin(phase) * 0.35 if moving else sin(idle_phase) * 0.16
	var rotation = 0.0
	var draw_scale = Vector2.ONE
	if sprite_animations.is_empty():
		var lean_sign = -1.0 if sprite_facing.x < 0.0 else 1.0
		rotation = sin(phase) * 0.022 * lean_sign if moving else sin(idle_phase) * 0.008
		var pulse = absf(sin(phase)) if moving else 0.0
		draw_scale = Vector2(1.0 + pulse * 0.012, 1.0 - pulse * 0.008)
	if sprite_flip_h:
		draw_scale.x *= -1.0
	draw_set_transform(offset + Vector2(0, bob), rotation, draw_scale)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
