extends Control

const DARKNESS_SHADER = preload("res://shaders/mine_darkness.gdshader")
const MINE_CELL_SIZE = 288
const MAX_LIGHTS = 8

var active = false
var players = []
var focus_position = Vector2.ZERO
var shader_material: ShaderMaterial

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	shader_material = ShaderMaterial.new()
	shader_material.shader = DARKNESS_SHADER
	material = shader_material
	visible = false
	_sync_rect()

func set_active(value):
	active = value
	visible = value
	_update_lights()
	queue_redraw()

func set_players(value):
	players = value
	_update_lights()
	queue_redraw()

func set_focus_position(value):
	focus_position = value
	if active:
		_update_lights()
		queue_redraw()

func _process(_delta):
	if not active:
		return
	_sync_rect()
	_update_lights()
	queue_redraw()

func _draw():
	if active:
		draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color.WHITE)

func _update_lights():
	if shader_material == null:
		return

	var lights = _screen_lights()
	shader_material.set_shader_parameter("light_count", mini(lights.size(), MAX_LIGHTS))
	for i in range(MAX_LIGHTS):
		var value = Vector4(-10000.0, -10000.0, 1.0, 0.0)
		if i < lights.size():
			var light = lights[i]
			var position = light.get("position", Vector2(-10000, -10000))
			value = Vector4(position.x, position.y, float(light.get("radius", 120.0)), 0.0)
		shader_material.set_shader_parameter("light%d" % i, value)

func _screen_lights():
	var result = []
	var canvas_transform = get_viewport().get_canvas_transform()

	for current_player in players:
		if not _player_alive(current_player):
			continue
		result.append({
			"position": canvas_transform * current_player.global_position,
			"radius": 182.0
		})

	var lanterns = _lantern_world_positions()
	lanterns.sort_custom(Callable(self, "_sort_lantern_distance"))
	for lantern_position in lanterns:
		if result.size() >= MAX_LIGHTS:
			break
		result.append({
			"position": canvas_transform * lantern_position,
			"radius": 142.0
		})

	return result

func _sort_lantern_distance(a, b):
	return focus_position.distance_squared_to(a) < focus_position.distance_squared_to(b)

func _lantern_world_positions():
	var result = []
	var radius = 1300
	var start_x = int(floor((focus_position.x - radius) / MINE_CELL_SIZE)) - 1
	var end_x = int(ceil((focus_position.x + radius) / MINE_CELL_SIZE)) + 1
	var start_y = int(floor((focus_position.y - radius) / MINE_CELL_SIZE)) - 1
	var end_y = int(ceil((focus_position.y + radius) / MINE_CELL_SIZE)) + 1

	for cell_x in range(start_x, end_x + 1):
		for cell_y in range(start_y, end_y + 1):
			var hash = _cell_hash(cell_x, cell_y)
			if hash % 4 == 0:
				result.append(_mine_room_center(cell_x, cell_y) + Vector2(18, -16))

	return result

func _mine_room_center(cell_x, cell_y):
	var hash = _cell_hash(cell_x, cell_y)
	var offset = Vector2((hash % 5) * 12 - 24, (int(hash / 5) % 5) * 10 - 20)
	if cell_x == 0 and cell_y == 0:
		offset = Vector2.ZERO
	return Vector2(cell_x * MINE_CELL_SIZE, cell_y * MINE_CELL_SIZE) + offset

func _cell_hash(cell_x, cell_y):
	return int(abs(sin(float(cell_x) * 129.898 + float(cell_y) * 782.33)) * 100000.0)

func _player_alive(current_player):
	return is_instance_valid(current_player) and bool(current_player.alive)

func _sync_rect():
	position = Vector2.ZERO
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
