extends Node2D

const MINE_CELL_SIZE = 288
const MINE_CORRIDOR_HALF_WIDTH = 36.0
const MINE_WALKABLE_PADDING = 20.0

var player = null
var tile_size = 96
var focus_position = Vector2.ZERO
var last_draw_focus = Vector2(9999999, 9999999)
var stage_data = {
	"id": "ghost_town",
	"floor": Color("#c99052"),
	"grid": Color(0.55, 0.31, 0.15, 0.12),
	"accent": Color("#7a4a27")
}

func _ready():
	player = get_tree().get_first_node_in_group("player")

func set_stage(data):
	stage_data = data
	last_draw_focus = Vector2(9999999, 9999999)
	queue_redraw()

func set_focus_position(position):
	focus_position = position
	if last_draw_focus.distance_squared_to(focus_position) > float(tile_size * tile_size) * 0.18:
		last_draw_focus = focus_position
		queue_redraw()

func _process(_delta):
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

func _draw():
	var center = focus_position
	if is_instance_valid(player):
		center = focus_position

	var viewport_size = get_viewport_rect().size * 2.70
	var area = Rect2(center - viewport_size, viewport_size * 2.0)
	var stage_id = stage_data.get("id", "ghost_town")
	if stage_id == "mine":
		draw_rect(area, Color("#18130f"))
		_draw_mine_layout(area)
		return

	draw_rect(area, stage_data.get("floor", Color("#c99052")))

	var start_x = int(floor(area.position.x / tile_size) * tile_size)
	var end_x = int(ceil(area.end.x / tile_size) * tile_size)
	var start_y = int(floor(area.position.y / tile_size) * tile_size)
	var end_y = int(ceil(area.end.y / tile_size) * tile_size)
	var grid_color = stage_data.get("grid", Color(0.55, 0.31, 0.15, 0.12))

	for x in range(start_x, end_x + tile_size, tile_size):
		draw_line(Vector2(x, start_y), Vector2(x, end_y), grid_color, 1.0)

	for y in range(start_y, end_y + tile_size, tile_size):
		draw_line(Vector2(start_x, y), Vector2(end_x, y), grid_color, 1.0)

	for x in range(start_x, end_x + tile_size * 2, tile_size * 2):
		for y in range(start_y, end_y + tile_size * 2, tile_size * 2):
			var hash = _cell_hash(x, y) % 23
			var offset = Vector2((hash % 5) * 9 - 18, (hash % 7) * 7 - 21)
			_draw_stage_prop(Vector2(x, y) + offset, hash)

func _draw_mine_layout(area):
	var start_x = int(floor(area.position.x / MINE_CELL_SIZE)) - 1
	var end_x = int(ceil(area.end.x / MINE_CELL_SIZE)) + 1
	var start_y = int(floor(area.position.y / MINE_CELL_SIZE)) - 1
	var end_y = int(ceil(area.end.y / MINE_CELL_SIZE)) + 1
	var tunnel_shadow = Color("#0b0907")
	var tunnel = Color("#675646")
	var chamber = Color("#735f4d")
	var chamber_light = Color("#816c57")

	for cell_x in range(start_x, end_x + 1):
		for cell_y in range(start_y, end_y + 1):
			var center = _mine_room_center(cell_x, cell_y)
			var right = _mine_room_center(cell_x + 1, cell_y)
			_draw_mine_corridor(center, right, tunnel_shadow, tunnel)
			if _mine_has_vertical_connection(cell_x, cell_y):
				var down = _mine_room_center(cell_x, cell_y + 1)
				_draw_mine_corridor(center, down, tunnel_shadow, tunnel)

	for cell_x in range(start_x, end_x + 1):
		for cell_y in range(start_y, end_y + 1):
			var hash = _mine_hash(cell_x, cell_y)
			var center = _mine_room_center(cell_x, cell_y)
			var room_radius = _mine_room_radius(cell_x, cell_y)
			draw_circle(center + Vector2(5, 8), room_radius + 14.0, Color(0, 0, 0, 0.30))
			draw_circle(center, room_radius, chamber)
			draw_circle(center + Vector2(-room_radius * 0.18, -room_radius * 0.12), room_radius * 0.66, chamber_light)
			_draw_mine_wall_marks(center, room_radius, hash)
			if hash % 4 == 0:
				_draw_lantern(center + Vector2(18, -16))
			elif hash % 5 == 0:
				_draw_mine_rail(center + Vector2(-8, 20))
			elif hash % 7 == 0:
				_draw_rock(center + Vector2(24, 18))

func _draw_mine_corridor(a, b, shadow, color):
	draw_line(a, b, shadow, MINE_CORRIDOR_HALF_WIDTH * 2.6)
	draw_line(a, b, color.darkened(0.08), MINE_CORRIDOR_HALF_WIDTH * 2.1)
	draw_line(a, b, color, MINE_CORRIDOR_HALF_WIDTH * 1.55)

func _draw_mine_wall_marks(center, radius, hash):
	var wall = Color(0.08, 0.06, 0.045, 0.35)
	for i in range(3):
		var angle = float((hash + i * 37) % 360) / 360.0 * TAU
		var start = center + Vector2(cos(angle), sin(angle)) * (radius * 0.76)
		var end = center + Vector2(cos(angle + 0.28), sin(angle + 0.28)) * (radius * 1.08)
		draw_line(start, end, wall, 2.0)

func is_mine_walkable(position):
	if stage_data.get("id", "ghost_town") != "mine":
		return true
	return _mine_walkable_at(position)

func mine_safe_position(position):
	if stage_data.get("id", "ghost_town") != "mine":
		return position
	if _mine_walkable_at(position):
		return position

	var best = position
	var best_distance = INF
	var cell = _mine_cell(position)
	for cell_x in range(cell.x - 2, cell.x + 3):
		for cell_y in range(cell.y - 2, cell.y + 3):
			var room = _mine_room_center(cell_x, cell_y)
			var candidate = _safe_point_in_circle(position, room, _mine_room_radius(cell_x, cell_y) + MINE_WALKABLE_PADDING)
			var distance = position.distance_squared_to(candidate)
			if distance < best_distance:
				best_distance = distance
				best = candidate

			var right = _mine_room_center(cell_x + 1, cell_y)
			candidate = _safe_point_in_corridor(position, room, right, MINE_CORRIDOR_HALF_WIDTH + MINE_WALKABLE_PADDING)
			distance = position.distance_squared_to(candidate)
			if distance < best_distance:
				best_distance = distance
				best = candidate

			if _mine_has_vertical_connection(cell_x, cell_y):
				var down = _mine_room_center(cell_x, cell_y + 1)
				candidate = _safe_point_in_corridor(position, room, down, MINE_CORRIDOR_HALF_WIDTH + MINE_WALKABLE_PADDING)
				distance = position.distance_squared_to(candidate)
				if distance < best_distance:
					best_distance = distance
					best = candidate

	return best

func _mine_walkable_at(position):
	var cell = _mine_cell(position)
	for cell_x in range(cell.x - 1, cell.x + 2):
		for cell_y in range(cell.y - 1, cell.y + 2):
			var room = _mine_room_center(cell_x, cell_y)
			if position.distance_to(room) <= _mine_room_radius(cell_x, cell_y) + MINE_WALKABLE_PADDING:
				return true

			var right = _mine_room_center(cell_x + 1, cell_y)
			if _distance_to_segment(position, room, right) <= MINE_CORRIDOR_HALF_WIDTH + MINE_WALKABLE_PADDING:
				return true

			if _mine_has_vertical_connection(cell_x, cell_y):
				var down = _mine_room_center(cell_x, cell_y + 1)
				if _distance_to_segment(position, room, down) <= MINE_CORRIDOR_HALF_WIDTH + MINE_WALKABLE_PADDING:
					return true

	return false

func _safe_point_in_circle(point, center, radius):
	var offset = point - center
	var distance = offset.length()
	if distance <= radius:
		return point
	if distance <= 0.001:
		return center
	return center + offset / distance * radius

func _safe_point_in_corridor(point, a, b, half_width):
	var closest = _closest_point_on_segment(point, a, b)
	var offset = point - closest
	var distance = offset.length()
	if distance <= half_width:
		return point
	if distance <= 0.001:
		return closest
	return closest + offset / distance * half_width

func _mine_cell(position):
	return Vector2i(int(floor(position.x / float(MINE_CELL_SIZE))), int(floor(position.y / float(MINE_CELL_SIZE))))

func _mine_room_center(cell_x, cell_y):
	var hash = _mine_hash(cell_x, cell_y)
	var offset = Vector2((hash % 5) * 12 - 24, (int(hash / 5) % 5) * 10 - 20)
	if cell_x == 0 and cell_y == 0:
		offset = Vector2.ZERO
	return Vector2(cell_x * MINE_CELL_SIZE, cell_y * MINE_CELL_SIZE) + offset

func _mine_room_radius(cell_x, cell_y):
	return 62.0 + float(_mine_hash(cell_x, cell_y) % 34)

func _mine_has_vertical_connection(cell_x, cell_y):
	return abs(cell_x) % 3 == 0 or _mine_hash(cell_x, cell_y) % 6 == 0

func _mine_hash(cell_x, cell_y):
	return int(abs(sin(float(cell_x) * 129.898 + float(cell_y) * 782.33)) * 100000.0)

func _distance_to_segment(point, a, b):
	return point.distance_to(_closest_point_on_segment(point, a, b))

func _closest_point_on_segment(point, a, b):
	var segment = b - a
	var length_sq = segment.length_squared()
	if length_sq <= 0.001:
		return a
	var t = clampf((point - a).dot(segment) / length_sq, 0.0, 1.0)
	return a + segment * t

func _cell_hash(x, y):
	return int(abs(sin(float(x) * 12.9898 + float(y) * 78.233)) * 100000.0)

func _draw_stage_prop(pos, hash):
	match stage_data.get("id", "ghost_town"):
		"canyon":
			if hash == 1 or hash == 9:
				_draw_canyon_spire(pos)
			elif hash == 4:
				_draw_rock(pos)
			elif hash == 8:
				_draw_scrub(pos)
		"broken_fort":
			if hash == 1:
				_draw_fort_wall(pos)
			elif hash == 4 or hash == 11:
				_draw_crate(pos)
			elif hash == 8:
				_draw_scrub(pos)
		"mine":
			if hash == 1:
				_draw_mine_rail(pos)
			elif hash == 4:
				_draw_rock(pos)
			elif hash == 8 or hash == 13:
				_draw_lantern(pos)
		"bonus":
			if hash == 1 or hash == 14:
				_draw_gold_rail(pos)
			elif hash == 4:
				_draw_rock(pos)
			elif hash == 8:
				_draw_lantern(pos)
		_:
			if hash == 1:
				_draw_cactus(pos)
			elif hash == 4:
				_draw_rock(pos)
			elif hash == 8:
				_draw_scrub(pos)
			elif hash == 12:
				_draw_fence(pos)

func _draw_cactus(pos):
	var green = Color("#356f42")
	draw_line(pos + Vector2(0, 16), pos + Vector2(0, -20), green, 7.0)
	draw_line(pos + Vector2(-11, 1), pos + Vector2(-3, -6), green, 5.0)
	draw_line(pos + Vector2(10, -4), pos + Vector2(3, -12), green, 5.0)

func _draw_rock(pos):
	draw_circle(pos, 10, Color("#8d6a4c"))
	draw_circle(pos + Vector2(8, 4), 7, Color("#73563d"))

func _draw_scrub(pos):
	var brush = Color("#9b7d35")
	draw_line(pos + Vector2(-12, 8), pos + Vector2(0, -6), brush, 3.0)
	draw_line(pos + Vector2(12, 7), pos + Vector2(0, -6), brush, 3.0)
	draw_line(pos + Vector2(-5, 10), pos + Vector2(5, -4), brush, 2.0)

func _draw_fence(pos):
	var wood = Color("#6e4428")
	draw_line(pos + Vector2(-20, -6), pos + Vector2(20, -6), wood, 4.0)
	draw_line(pos + Vector2(-20, 6), pos + Vector2(20, 6), wood, 4.0)
	draw_line(pos + Vector2(-13, -14), pos + Vector2(-13, 14), wood, 5.0)
	draw_line(pos + Vector2(13, -14), pos + Vector2(13, 14), wood, 5.0)

func _draw_canyon_spire(pos):
	var clay = Color("#8b3e2d")
	draw_polygon(PackedVector2Array([
		pos + Vector2(-12, 18),
		pos + Vector2(-4, -24),
		pos + Vector2(9, -14),
		pos + Vector2(15, 18)
	]), PackedColorArray([clay, clay.lightened(0.12), clay, clay.darkened(0.08)]))

func _draw_fort_wall(pos):
	var wood = Color("#5c3d27")
	draw_rect(Rect2(pos + Vector2(-22, -9), Vector2(44, 18)), wood)
	draw_line(pos + Vector2(-20, 0), pos + Vector2(20, 0), Color("#3e281a"), 2.0)

func _draw_crate(pos):
	var wood = Color("#7b4d2c")
	draw_rect(Rect2(pos + Vector2(-11, -11), Vector2(22, 22)), wood)
	draw_line(pos + Vector2(-9, -9), pos + Vector2(9, 9), Color("#4a2c1b"), 2.0)
	draw_line(pos + Vector2(-9, 9), pos + Vector2(9, -9), Color("#4a2c1b"), 2.0)

func _draw_mine_rail(pos):
	var rail = Color("#44362d")
	draw_line(pos + Vector2(-24, -5), pos + Vector2(24, -5), rail, 3.0)
	draw_line(pos + Vector2(-24, 5), pos + Vector2(24, 5), rail, 3.0)
	for i in range(-2, 3):
		draw_line(pos + Vector2(i * 10, -9), pos + Vector2(i * 10, 9), Color("#6a4a32"), 2.0)

func _draw_lantern(pos):
	draw_rect(Rect2(pos + Vector2(-4, -10), Vector2(8, 18)), Color("#3a261a"))
	draw_circle(pos, 8, Color(1.0, 0.72, 0.22, 0.32))
	draw_circle(pos, 3, Color("#f5c45b"))

func _draw_gold_rail(pos):
	var gold = Color("#d8b551")
	draw_line(pos + Vector2(-28, -7), pos + Vector2(28, -7), gold, 3.0)
	draw_line(pos + Vector2(-28, 7), pos + Vector2(28, 7), gold, 3.0)
	draw_line(pos + Vector2(-10, -12), pos + Vector2(10, 12), Color("#74602f"), 2.0)
