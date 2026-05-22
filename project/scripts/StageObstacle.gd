extends StaticBody2D

var kind = "building"
var obstacle_size = Vector2(120, 92)
var body_color = Color("#7a4a27")
var detail_color = Color("#3f281a")
var texture_path = ""
var texture: Texture2D = null
var texture_height = 0.0
var texture_offset = Vector2.ZERO

func _ready():
	collision_layer = 4
	collision_mask = 0

func setup(data):
	kind = str(data.get("kind", kind))
	obstacle_size = data.get("size", obstacle_size)
	body_color = data.get("color", body_color)
	detail_color = data.get("detail", detail_color)
	texture_path = str(data.get("texture", ""))
	texture = _load_texture(texture_path)
	texture_height = float(data.get("texture_height", obstacle_size.y))
	texture_offset = data.get("texture_offset", Vector2.ZERO)
	var shape = RectangleShape2D.new()
	shape.size = obstacle_size
	$CollisionShape2D.shape = shape
	queue_redraw()

func _draw():
	if texture != null and texture_height > 0.0:
		_draw_texture_prop()
		return

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

func _draw_texture_prop():
	var aspect = float(texture.get_width()) / float(maxi(texture.get_height(), 1))
	var size = Vector2(texture_height * aspect, texture_height)
	draw_texture_rect(texture, Rect2(texture_offset - size * 0.5, size), false)

func _load_texture(path):
	if path == "":
		return null
	if ResourceLoader.exists(path):
		var loaded = load(path)
		if loaded is Texture2D:
			return loaded
	var image = Image.new()
	if image.load(path) == OK:
		return ImageTexture.create_from_image(image)
	return null

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
