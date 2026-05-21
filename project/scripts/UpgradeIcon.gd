extends Control

var choice_data = {}

func configure(data):
	choice_data = data
	queue_redraw()

func _draw():
	var center = size * 0.5
	var radius = minf(size.x, size.y) * 0.43
	var icon_id = str(choice_data.get("icon", choice_data.get("id", "")))
	var is_weapon = str(choice_data.get("type", "")) == "weapon"
	var base = Color("#4c3222") if is_weapon else Color("#27413a")
	var rim = Color("#d8a84f") if is_weapon else Color("#9be8d4")

	draw_circle(center + Vector2(2, 3), radius, Color(0, 0, 0, 0.30))
	draw_circle(center, radius, base)
	draw_arc(center, radius - 1.0, 0.0, TAU, 42, rim, 3.0)

	match icon_id:
		"shotgun", "coach_gun":
			_draw_long_gun(center, Color("#f2d799"), true)
		"rifle", "rail_spike":
			_draw_long_gun(center, Color("#d8e4ff"), false)
		"dynamite":
			_draw_dynamite(center)
		"lasso":
			_draw_lasso(center)
		"knife":
			_draw_knife(center)
		"fire_bottle":
			_draw_fire(center)
		"horseshoe":
			_draw_horseshoe(center)
		"ghost_lantern":
			_draw_lantern(center)
		"spurs":
			_draw_spurs(center)
		"star":
			_draw_star(center, 17.0, Color("#ffd56a"))
		"magnet":
			_draw_magnet(center)
		"coffee":
			_draw_coffee(center)
		_:
			_draw_revolver(center, Color("#ffd55d") if icon_id == "golden_revolver" else Color("#ffe7a0"))

func _draw_revolver(center, flash):
	draw_line(center + Vector2(-16, 2), center + Vector2(16, -4), Color("#21160f"), 6)
	draw_line(center + Vector2(-7, 4), center + Vector2(-12, 17), Color("#5b3724"), 5)
	draw_circle(center + Vector2(2, 0), 7, Color("#6d7480"))
	draw_circle(center + Vector2(18, -5), 4, flash)

func _draw_long_gun(center, flash, double_barrel):
	draw_line(center + Vector2(-20, 4), center + Vector2(21, -5), Color("#23160e"), 6)
	draw_line(center + Vector2(-17, 0), center + Vector2(20, -9), Color("#9a6a3d"), 3)
	if double_barrel:
		draw_line(center + Vector2(-15, 8), center + Vector2(20, -1), Color("#c29b66"), 3)
	draw_line(center + Vector2(-20, 6), center + Vector2(-26, 18), Color("#4a2b19"), 5)
	draw_circle(center + Vector2(23, -6), 3, flash)

func _draw_dynamite(center):
	draw_rect(Rect2(center + Vector2(-13, -8), Vector2(26, 16)), Color("#8d2d22"))
	draw_line(center + Vector2(10, -8), center + Vector2(19, -19), Color("#e2c15f"), 2)
	draw_circle(center + Vector2(21, -21), 4, Color("#ffcf5a"))

func _draw_lasso(center):
	draw_arc(center, 18, 0.15 * PI, 2.05 * PI, 42, Color("#d2a257"), 5)
	draw_line(center + Vector2(-4, 14), center + Vector2(18, 23), Color("#d2a257"), 3)

func _draw_knife(center):
	draw_polygon(PackedVector2Array([
		center + Vector2(20, -2),
		center + Vector2(-7, -10),
		center + Vector2(-18, -2),
		center + Vector2(-6, 8)
	]), PackedColorArray([Color("#eef2f3"), Color("#cbd4d8"), Color("#8c9ca4"), Color("#dfe7e9")]))
	draw_line(center + Vector2(-18, -2), center + Vector2(-27, 7), Color("#5b3a24"), 5)

func _draw_fire(center):
	draw_circle(center, 18, Color(1.0, 0.28, 0.08, 0.58))
	draw_circle(center + Vector2(4, -4), 10, Color(1.0, 0.82, 0.22, 0.78))
	draw_rect(Rect2(center + Vector2(-8, 5), Vector2(18, 8)), Color("#3a2618"))

func _draw_horseshoe(center):
	draw_arc(center, 19, 0.20 * PI, 1.80 * PI, 36, Color("#cfd5d2"), 6)
	draw_circle(center + Vector2(-11, 14), 3, Color("#cfd5d2"))
	draw_circle(center + Vector2(11, 14), 3, Color("#cfd5d2"))

func _draw_lantern(center):
	draw_circle(center, 18, Color(0.61, 0.91, 0.83, 0.24))
	draw_rect(Rect2(center + Vector2(-8, -12), Vector2(16, 25)), Color("#3c2a1d"))
	draw_circle(center + Vector2(0, 2), 8, Color("#9be8d4"))
	draw_line(center + Vector2(-6, -14), center + Vector2(6, -14), Color("#d6c28b"), 3)

func _draw_spurs(center):
	draw_circle(center + Vector2(-8, 3), 11, Color("#bfc4c2"))
	draw_circle(center + Vector2(-8, 3), 6, Color("#27413a"))
	_draw_star(center + Vector2(11, -4), 12.0, Color("#d8e4ff"))

func _draw_magnet(center):
	draw_arc(center, 19, 0.12 * PI, 0.88 * PI, 32, Color("#c4483e"), 7)
	draw_rect(Rect2(center + Vector2(-19, -3), Vector2(9, 13)), Color("#d9e0e2"))
	draw_rect(Rect2(center + Vector2(10, -3), Vector2(9, 13)), Color("#d9e0e2"))

func _draw_coffee(center):
	draw_rect(Rect2(center + Vector2(-13, -8), Vector2(24, 22)), Color("#f0c95a"))
	draw_arc(center + Vector2(12, 2), 8, -0.5 * PI, 0.5 * PI, 18, Color("#f0c95a"), 4)
	draw_line(center + Vector2(-8, -17), center + Vector2(-5, -25), Color("#fff1a6"), 2)
	draw_line(center + Vector2(1, -17), center + Vector2(3, -25), Color("#fff1a6"), 2)

func _draw_star(center, radius, color):
	var points = PackedVector2Array()
	var colors = PackedColorArray()
	for i in range(10):
		var angle = -PI * 0.5 + float(i) * PI / 5.0
		var point_radius = radius if i % 2 == 0 else radius * 0.45
		points.append(center + Vector2(cos(angle), sin(angle)) * point_radius)
		colors.append(color)
	draw_polygon(points, colors)
