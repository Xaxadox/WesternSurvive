extends StaticBody2D

var kind = "building"
var obstacle_size = Vector2(120, 92)
var body_color = Color("#7a4a27")
var detail_color = Color("#3f281a")

func _ready():
	collision_layer = 4
	collision_mask = 0

func setup(data):
	kind = str(data.get("kind", kind))
	obstacle_size = data.get("size", obstacle_size)
	body_color = data.get("color", body_color)
	detail_color = data.get("detail", detail_color)
	var shape = RectangleShape2D.new()
	shape.size = obstacle_size
	$CollisionShape2D.shape = shape
	queue_redraw()

func _draw():
	match kind:
		"building":
			_draw_building()
		"wagon":
			_draw_wagon()
		"fence":
			_draw_fence()
		"cactus":
			_draw_cactus()
		_:
			_draw_boulder()

func _draw_building():
	var rect = Rect2(-obstacle_size * 0.5, obstacle_size)
	draw_rect(rect, body_color)
	draw_rect(Rect2(rect.position + Vector2(10, 12), Vector2(obstacle_size.x - 20, 16)), detail_color)
	draw_rect(Rect2(rect.position + Vector2(obstacle_size.x * 0.42, obstacle_size.y * 0.48), Vector2(obstacle_size.x * 0.18, obstacle_size.y * 0.42)), detail_color)
	draw_line(rect.position + Vector2(0, 28), rect.position + Vector2(obstacle_size.x, 28), detail_color, 3)

func _draw_wagon():
	var rect = Rect2(-obstacle_size * 0.5, obstacle_size)
	draw_rect(rect, body_color)
	draw_line(rect.position + Vector2(8, 8), rect.end - Vector2(8, 8), detail_color, 4)
	draw_line(Vector2(rect.end.x - 8, rect.position.y + 8), Vector2(rect.position.x + 8, rect.end.y - 8), detail_color, 4)
	draw_circle(rect.position + Vector2(18, obstacle_size.y + 8), 12, detail_color)
	draw_circle(rect.position + Vector2(obstacle_size.x - 18, obstacle_size.y + 8), 12, detail_color)

func _draw_fence():
	var rect = Rect2(-obstacle_size * 0.5, obstacle_size)
	for y in [-12.0, 12.0]:
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), body_color, 6)
	for x in range(int(rect.position.x) + 18, int(rect.end.x), 34):
		draw_line(Vector2(x, -28), Vector2(x, 28), detail_color, 7)

func _draw_cactus():
	var green = Color("#386b35")
	draw_line(Vector2(0, obstacle_size.y * 0.35), Vector2(0, -obstacle_size.y * 0.35), green, 12)
	draw_line(Vector2(-24, 6), Vector2(-8, -12), green, 9)
	draw_line(Vector2(24, -4), Vector2(8, -20), green, 9)
	draw_circle(Vector2.ZERO, obstacle_size.x * 0.22, Color(0, 0, 0, 0.16))

func _draw_boulder():
	draw_circle(Vector2.ZERO, obstacle_size.x * 0.42, body_color)
	draw_circle(Vector2(obstacle_size.x * 0.22, obstacle_size.y * 0.08), obstacle_size.x * 0.28, detail_color)
