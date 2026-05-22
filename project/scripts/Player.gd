extends CharacterBody2D

signal health_changed(current, maximum)
signal died

var move_speed = 235.0
var max_health = 100
var health = 100
var pickup_radius = 95.0
var damage_reduction = 0.0
var aim_direction = Vector2.RIGHT
var alive = true
var player_index = 0
var coat_color = Color("#37514a")
var hat_color = Color("#4a2c1d")
var scarf_color = Color("#b33b2e")
var skin_color = Color("#f0b77d")
var outline_color = Color("#f2d36b")
var badge_color = Color("#f2d36b")
var weapon_visual = "revolver"
var silhouette = "gunslinger"
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
var sprite_animation_fps = 8.0
var sprite_flip_h = false

var invulnerable_time = 0.0
var player_marker_colors = [
	Color("#fff1a6"),
	Color("#8fd3ff"),
	Color("#f59be7"),
	Color("#9be8d4")
]

func _ready():
	add_to_group("player")
	health = max_health
	health_changed.emit(health, max_health)

func configure(data, index = 0):
	player_index = index
	move_speed = float(data.get("speed", 235.0))
	max_health = int(data.get("health", 100))
	health = max_health
	pickup_radius = float(data.get("pickup", 95.0))
	damage_reduction = 0.0
	coat_color = data.get("coat", coat_color)
	hat_color = data.get("hat", hat_color)
	scarf_color = data.get("scarf", scarf_color)
	skin_color = data.get("skin", skin_color)
	outline_color = data.get("outline", outline_color)
	badge_color = data.get("badge", badge_color)
	weapon_visual = str(data.get("visual_weapon", weapon_visual))
	silhouette = str(data.get("silhouette", silhouette))
	sprite_path = str(data.get("sprite", ""))
	sprite_texture = _load_sprite(sprite_path)
	sprite_walk_textures = _load_sprite_list(data.get("walk_sprites", []))
	sprite_animations = _load_animation_map(data.get("animations", {}))
	sprite_animation_fps = float(data.get("animation_fps", 8.0))
	sprite_height = float(data.get("sprite_height", 0.0))
	sprite_offset = data.get("sprite_offset", Vector2.ZERO)
	sprite_anim_time = 0.0
	sprite_idle_time = 0.0
	sprite_facing = Vector2.DOWN
	sprite_direction_key = "down"
	sprite_flip_h = false
	alive = true
	invulnerable_time = 0.0
	velocity = Vector2.ZERO
	health_changed.emit(health, max_health)
	queue_redraw()

func _physics_process(delta):
	if not alive:
		velocity = Vector2.ZERO
		return

	invulnerable_time = maxf(invulnerable_time - delta, 0.0)

	var input_vector = _read_movement()
	_update_aim_direction(input_vector)
	if input_vector.length() > 0.0:
		velocity = input_vector.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	_update_sprite_animation(delta, input_vector)
	move_and_slide()
	queue_redraw()

func _update_sprite_animation(delta, input_vector):
	sprite_idle_time += delta
	if input_vector.length() <= 0.01:
		sprite_anim_time = 0.0
		return

	sprite_facing = input_vector.normalized()
	sprite_direction_key = _direction_key(sprite_facing)
	if sprite_direction_key == "side" and absf(sprite_facing.x) > 0.08:
		sprite_flip_h = sprite_facing.x < 0.0
	var speed_factor = clampf(velocity.length() / maxf(move_speed, 1.0), 0.65, 1.35)
	sprite_anim_time += delta * speed_factor

func _direction_key(direction):
	if direction.length() <= 0.01:
		return sprite_direction_key
	var horizontal = absf(direction.x)
	var vertical = absf(direction.y)
	var vertical_key = "up" if direction.y < 0.0 else "down"
	if horizontal >= vertical * 1.20:
		return "side"
	if vertical >= horizontal * 1.20:
		return vertical_key
	if sprite_direction_key == "side" and horizontal > 0.05:
		return "side"
	if (sprite_direction_key == "up" or sprite_direction_key == "down") and vertical > 0.05:
		return sprite_direction_key if sprite_direction_key == vertical_key else vertical_key
	return vertical_key if vertical >= horizontal else "side"

func _update_aim_direction(input_vector):
	if player_index == 0:
		var mouse_direction = get_global_mouse_position() - global_position
		if mouse_direction.length() > 4.0:
			aim_direction = mouse_direction.normalized()
			return

	if input_vector.length() > 0.0:
		aim_direction = input_vector.normalized()

func _read_movement():
	var direction = Vector2.ZERO
	if _left_pressed():
		direction.x -= 1.0
	if _right_pressed():
		direction.x += 1.0
	if _up_pressed():
		direction.y -= 1.0
	if _down_pressed():
		direction.y += 1.0
	direction += _joy_direction()
	return direction.normalized()

func _left_pressed():
	match player_index:
		0:
			return Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
		1:
			return Input.is_key_pressed(KEY_J)
		2:
			return Input.is_key_pressed(KEY_F)
		_:
			return Input.is_key_pressed(KEY_KP_4)

func _right_pressed():
	match player_index:
		0:
			return Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
		1:
			return Input.is_key_pressed(KEY_L)
		2:
			return Input.is_key_pressed(KEY_H)
		_:
			return Input.is_key_pressed(KEY_KP_6)

func _up_pressed():
	match player_index:
		0:
			return Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
		1:
			return Input.is_key_pressed(KEY_I)
		2:
			return Input.is_key_pressed(KEY_T)
		_:
			return Input.is_key_pressed(KEY_KP_8)

func _down_pressed():
	match player_index:
		0:
			return Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
		1:
			return Input.is_key_pressed(KEY_K)
		2:
			return Input.is_key_pressed(KEY_G)
		_:
			return Input.is_key_pressed(KEY_KP_5)

func _joy_direction():
	var connected = Input.get_connected_joypads()
	if player_index >= connected.size():
		return Vector2.ZERO

	var joy_id = connected[player_index]
	var direction = Vector2(
		Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_Y)
	)
	if direction.length() < 0.22:
		return Vector2.ZERO
	return direction

func damage(amount):
	take_damage(amount)

func take_damage(amount, _source_position = null):
	if not alive or invulnerable_time > 0.0:
		return

	var final_amount = maxi(1, int(ceil(float(amount) * (1.0 - clampf(damage_reduction, 0.0, 0.85)))))
	health = maxi(health - final_amount, 0)
	invulnerable_time = 0.35
	health_changed.emit(health, max_health)

	if health <= 0:
		alive = false
		died.emit()

	queue_redraw()

func heal(amount):
	if not alive:
		return

	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)

func increase_max_health(amount):
	max_health += amount
	health += amount
	health_changed.emit(health, max_health)

func _draw():
	var blink = invulnerable_time > 0.0 and int(Time.get_ticks_msec() / 80) % 2 == 0
	var coat = coat_color if not blink else Color("#f6e3a1")
	var hat = hat_color
	var scarf = scarf_color
	var marker = player_marker_colors[player_index % player_marker_colors.size()]

	draw_circle(Vector2(4, 8), 18, Color(0, 0, 0, 0.24))
	draw_circle(Vector2.ZERO, 21, Color(outline_color.r, outline_color.g, outline_color.b, 0.26))
	draw_arc(Vector2.ZERO, 22, -PI * 0.5, PI * 1.5, 40, marker, 3.0)
	var active_sprite = _current_sprite_texture()
	if active_sprite != null and sprite_height > 0.0:
		_draw_sprite(active_sprite, sprite_height, sprite_offset, Color(1.25, 1.12, 0.72, 1.0) if blink else Color.WHITE)
	else:
		_draw_body(coat, hat, scarf)
		_draw_weapon(aim_direction.normalized())

	var marker_position = _marker_position()
	draw_circle(marker_position, 5, marker)
	draw_circle(marker_position, 2, Color("#20140e"))

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
	var phase = sprite_anim_time * TAU * 3.0
	var idle_phase = sprite_idle_time * TAU * 0.55
	var bob = sin(phase) * 0.45 if moving else sin(idle_phase) * 0.18
	var rotation = 0.0
	var draw_scale = Vector2.ONE
	if sprite_animations.is_empty():
		var lean_source = sprite_facing.x if absf(sprite_facing.x) > 0.08 else aim_direction.x
		var lean_sign = -1.0 if lean_source < 0.0 else 1.0
		rotation = sin(phase) * 0.025 * lean_sign if moving else sin(idle_phase) * 0.006
		var pulse = absf(sin(phase)) if moving else 0.0
		draw_scale = Vector2(1.0 + pulse * 0.014, 1.0 - pulse * 0.010)
	if sprite_direction_key == "side" and sprite_flip_h:
		draw_scale.x *= -1.0
	draw_set_transform(offset + Vector2(0, bob), rotation, draw_scale)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _marker_position():
	if sprite_texture == null or sprite_height <= 0.0:
		return Vector2(-15, -29)
	var side = 1.0 if sprite_direction_key == "side" and sprite_flip_h else -1.0
	return sprite_offset + Vector2(side * sprite_height * 0.24, -sprite_height * 0.48)

func _draw_body(coat, hat, scarf):
	match silhouette:
		"sheriff":
			draw_polygon(PackedVector2Array([Vector2(-15, -4), Vector2(15, -4), Vector2(18, 17), Vector2(-18, 17)]), PackedColorArray([coat, coat, coat, coat]))
			draw_circle(Vector2(0, -9), 10, skin_color)
			draw_rect(Rect2(-20, -18, 40, 5), hat)
			draw_rect(Rect2(-12, -27, 24, 10), hat)
			_draw_star(Vector2(7, 4), 5.0, badge_color)
			draw_line(Vector2(-10, 5), Vector2(8, 9), scarf, 4)
		"hunter":
			draw_polygon(PackedVector2Array([Vector2(-10, -7), Vector2(12, -7), Vector2(19, 18), Vector2(-14, 18)]), PackedColorArray([coat, coat, coat, coat]))
			draw_circle(Vector2(0, -10), 9, skin_color)
			draw_rect(Rect2(-18, -18, 36, 4), hat)
			draw_rect(Rect2(-9, -26, 18, 9), hat)
			draw_line(Vector2(-11, -2), Vector2(10, 5), scarf, 5)
			draw_line(Vector2(-13, 9), Vector2(14, 15), Color(0, 0, 0, 0.18), 3)
		"healer":
			draw_polygon(PackedVector2Array([Vector2(0, -14), Vector2(17, 8), Vector2(11, 20), Vector2(-11, 20), Vector2(-17, 8)]), PackedColorArray([coat, coat, coat, coat, coat]))
			draw_circle(Vector2(0, -11), 9, skin_color)
			draw_rect(Rect2(-16, -19, 32, 4), hat)
			draw_rect(Rect2(-8, -26, 16, 8), hat)
			draw_line(Vector2(-8, 1), Vector2(9, 6), scarf, 4)
			draw_circle(Vector2(8, 11), 4, Color(scarf.r, scarf.g, scarf.b, 0.65))
		_:
			draw_circle(Vector2.ZERO, 17, coat)
			draw_circle(Vector2(0, -9), 10, skin_color)
			draw_rect(Rect2(-18, -18, 36, 5), hat)
			draw_rect(Rect2(-10, -26, 20, 10), hat)
			draw_line(Vector2(-10, 4), Vector2(11, 8), scarf, 4)
			draw_rect(Rect2(-5, 2, 10, 12), Color(0, 0, 0, 0.16))

func _draw_weapon(direction):
	var dir = direction
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	var side = Vector2(-dir.y, dir.x)

	match weapon_visual:
		"shotgun":
			var start = dir * 9.0 - side * 3.0
			var end = dir * 36.0 - side * 3.0
			draw_line(start, end, Color("#24160e"), 6)
			draw_line(start + side * 3.0, end + side * 3.0, Color("#6e4a2d"), 3)
			draw_line(start - dir * 5.0, start - side * 8.0, Color("#3a2416"), 5)
			draw_circle(end, 3, Color("#f0c95a"))
		"rifle":
			var start = dir * 8.0 + side * 2.0
			var end = dir * 41.0 + side * 2.0
			draw_line(start, end, Color("#2b1b13"), 4)
			draw_line(start + side * 3.0, end + side * 3.0, Color("#a46d38"), 2)
			draw_line(start - dir * 4.0, start - side * 7.0, Color("#3a2416"), 4)
			draw_circle(end, 2.5, Color("#d8e4ff"))
		"lantern":
			var staff_start = -dir * 3.0 - side * 10.0
			var staff_end = dir * 22.0 - side * 10.0
			var lamp = dir * 27.0 - side * 4.0
			draw_line(staff_start, staff_end, Color("#3a2618"), 4)
			draw_line(staff_end, lamp, Color("#3a2618"), 3)
			draw_circle(lamp, 9, Color(0.61, 0.91, 0.83, 0.25))
			draw_circle(lamp, 5, Color("#9be8d4"))
			draw_rect(Rect2(lamp.x - 4, lamp.y - 8, 8, 4), Color("#2a332d"))
		_:
			var gun_start = dir * 10.0
			var gun_end = dir * 28.0
			draw_line(gun_start, gun_end, Color("#21160f"), 4)
			draw_line(gun_start - side * 2.0, gun_start - side * 7.0, Color("#3a2416"), 3)
			draw_circle(gun_end, 3, Color("#d7b46a"))

func _draw_star(center, radius, color):
	var points = PackedVector2Array()
	for i in range(10):
		var angle = -PI * 0.5 + float(i) * PI / 5.0
		var point_radius = radius if i % 2 == 0 else radius * 0.45
		points.append(center + Vector2(cos(angle), sin(angle)) * point_radius)
	draw_polygon(points, PackedColorArray([color, color, color, color, color, color, color, color, color, color]))
