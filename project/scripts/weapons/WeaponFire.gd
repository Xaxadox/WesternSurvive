extends RefCounted

static var FIRE_CONFIG = {
	"revolver": {
		"family": "revolver",
		"color": Color("#ffe7a0"),
		"bonus_shots": 0
	},
	"shotgun": {
		"family": "shotgun",
		"bonus_pellets": 0
	},
	"dynamite": {
		"family": "explosive",
		"visual": "dynamite"
	},
	"lasso": {
		"family": "lasso"
	},
	"knife": {
		"family": "knife"
	},
	"rifle": {
		"family": "rifle",
		"color": Color("#d8e4ff"),
		"visual": "rail"
	},
	"fire_bottle": {
		"family": "explosive",
		"visual": "fire"
	},
	"horseshoe": {
		"family": "horseshoe"
	},
	"golden_revolver": {
		"family": "revolver",
		"color": Color("#ffd55d"),
		"bonus_shots": 2
	},
	"coach_gun": {
		"family": "shotgun",
		"bonus_pellets": 3
	},
	"rail_spike": {
		"family": "rifle",
		"color": Color("#b9f0ff"),
		"visual": "rail_spike"
	},
	"ghost_lantern": {
		"family": "ghost_lantern"
	}
}

static func fire(context, weapon_id, shooter):
	if not context._player_alive(shooter):
		return

	var config = FIRE_CONFIG.get(weapon_id, {})
	if config.is_empty():
		return

	context.firing_weapon_context = weapon_id
	_fire_from_config(context, weapon_id, shooter, config)
	context.firing_weapon_context = ""

static func _fire_from_config(context, weapon_id, shooter, config):
	match str(config.get("family", "")):
		"revolver":
			_fire_revolver(context, weapon_id, shooter, config.get("color", Color("#ffe7a0")), int(config.get("bonus_shots", 0)))
		"shotgun":
			_fire_shotgun(context, weapon_id, shooter, int(config.get("bonus_pellets", 0)))
		"explosive":
			_fire_explosive(context, weapon_id, shooter, str(config.get("visual", "dynamite")))
		"lasso":
			_fire_lasso(context, weapon_id, shooter)
		"knife":
			_fire_knife(context, weapon_id, shooter)
		"rifle":
			_fire_rifle(context, weapon_id, shooter, config.get("color", Color("#d8e4ff")), str(config.get("visual", "rail")))
		"horseshoe":
			_fire_horseshoe(context, weapon_id, shooter)
		"ghost_lantern":
			_fire_ghost_lantern(context, weapon_id, shooter)

static func _fire_revolver(context, weapon_id, shooter, color, bonus_shots):
	var base_direction = context._weapon_direction(weapon_id, shooter)
	if base_direction == Vector2.ZERO:
		return

	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	var shots = 6 + int(level_value >= 4) + int(evolved) + bonus_shots
	if evolved:
		shots = maxi(shots, 8)

	var damage = context._scaled_damage(13 + level_value * 4 + bonus_shots * 2, shooter)
	var pierce = 1 + int(level_value >= 4) + int(evolved) * 2
	var spread = 0.15 if shots > 1 else 0.0

	for i in range(shots):
		var offset = (float(i) - float(shots - 1) / 2.0) * spread
		context._fire_projectile(shooter, base_direction.rotated(offset), damage, 1180.0 + level_value * 32.0, pierce, 0.92, {
			"hit_radius": 6.0,
			"visual": "bullet",
			"color": color,
			"line_length": 23.0,
			"medium_range": 520.0,
			"far_range": 880.0,
			"medium_damage_mult": 0.72,
			"far_damage_mult": 0.38
		})

	if context.has_method("_on_weapon_reloading"):
		context._on_weapon_reloading(weapon_id, shooter)

static func _fire_shotgun(context, weapon_id, shooter, bonus_pellets):
	var base_direction = context._weapon_direction(weapon_id, shooter)
	if base_direction == Vector2.ZERO:
		return

	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	var pellets = 6 + level_value + bonus_pellets + int(evolved) * 2

	var damage = context._scaled_damage(6 + level_value * 3 + bonus_pellets, shooter)
	var spread = 0.58 + level_value * 0.03
	var pierce = 1 + int(evolved)

	for i in range(pellets):
		var t = 0.0
		if pellets > 1:
			t = float(i) / float(pellets - 1) - 0.5
		context._fire_projectile(shooter, base_direction.rotated(t * spread), damage, 930.0, pierce, 0.48, {
			"hit_radius": 5.8,
			"visual": "bullet",
			"color": Color("#f2d799"),
			"line_length": 14.0,
			"medium_range": 180.0,
			"far_range": 385.0,
			"medium_damage_mult": 0.44,
			"far_damage_mult": 0.0,
			"no_damage_past_far": true,
			"slow_factor": 0.55,
			"slow_duration": 1.25 + float(level_value) * 0.08
		})

static func _fire_explosive(context, weapon_id, shooter, visual):
	var direction = context._weapon_direction(weapon_id, shooter)
	if direction == Vector2.ZERO:
		return

	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	var is_fire = visual == "fire"
	var radius = 46.0 + level_value * 10.0
	var damage = context._scaled_damage(8 + level_value * 4, shooter)
	var speed = 520.0 + level_value * 34.0
	var lifetime = 0.82
	if is_fire:
		radius = 62.0 + level_value * 12.0
		damage = context._scaled_damage(3 + level_value * 2, shooter)
		lifetime = 0.64
	if evolved:
		radius += 36.0
		damage += context._scaled_damage(3 if is_fire else 8, shooter)

	if is_fire:
		context._fire_projectile(shooter, direction, damage, speed, 1, lifetime, {
			"hit_radius": 9.0,
			"visual": visual,
			"color": Color("#f15d32"),
			"ground_fire_on_hit": true,
			"ground_fire_on_expire": true,
			"ground_fire_radius": radius,
			"ground_fire_duration": 3.0 + float(level_value) * 0.35 + int(evolved) * 1.15,
			"dot_interval": 0.42,
			"damage_kind": "fire"
		})
		return

	context._fire_projectile(shooter, direction, damage, speed, 1, lifetime, {
		"hit_radius": 9.0,
		"visual": visual,
		"color": Color("#f15d32") if is_fire else Color("#3a2518"),
		"explode_radius": radius,
		"explode_on_hit": true,
		"explode_on_expire": true
	})

	if evolved and not is_fire:
		for i in range(6):
			context._fire_projectile(shooter, Vector2.RIGHT.rotated(float(i) / 6.0 * TAU), context._scaled_damage(5 + level_value, shooter), 820.0, 1, 0.46, {
				"hit_radius": 4.0,
				"visual": "shard",
				"color": Color("#efc16f"),
				"line_length": 12.0
			})

static func _fire_lasso(context, weapon_id, shooter):
	var direction = context._weapon_direction(weapon_id, shooter)
	if direction == Vector2.ZERO:
		return

	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	context._fire_projectile(shooter, direction, context._scaled_damage(4 + level_value * 2, shooter), 690.0 + level_value * 24.0, 7 + level_value * 2 + int(evolved) * 8, 0.84 + level_value * 0.045, {
		"hit_radius": 15.0 + level_value * 1.6 + int(evolved) * 9.0,
		"visual": "lasso",
		"color": Color("#d2a257"),
		"line_length": 34.0 + level_value * 3.0,
		"spin": 7.0
	})

static func _fire_knife(context, weapon_id, shooter):
	var base_direction = context._weapon_direction(weapon_id, shooter)
	if base_direction == Vector2.ZERO:
		return

	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	var knives = 2 + level_value + int(evolved) * 4
	var spread = 0.34 + level_value * 0.035

	for i in range(knives):
		var t = 0.0
		if knives > 1:
			t = float(i) / float(knives - 1) - 0.5
		context._fire_projectile(shooter, base_direction.rotated(t * spread), context._scaled_damage(5 + level_value * 2, shooter), 1260.0, 1 + int(level_value >= 4) + int(evolved), 0.82, {
			"hit_radius": 5.0,
			"visual": "knife",
			"color": Color("#d9e0e2"),
			"line_length": 20.0
		})

static func _fire_rifle(context, weapon_id, shooter, color, visual):
	var direction = context._weapon_direction(weapon_id, shooter)
	if direction == Vector2.ZERO:
		return

	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	var secret_bonus = 5 if weapon_id == "rail_spike" else 0
	context._fire_projectile(shooter, direction, context._scaled_damage(18 + level_value * 5 + secret_bonus, shooter), 1480.0, 3 + level_value + int(evolved) * 7, 1.08, {
		"hit_radius": 7.0 + int(evolved) * 2.0,
		"visual": visual,
		"color": color,
		"line_length": 34.0 + level_value * 2.0,
		"crit_range": 560.0,
		"crit_chance": 0.18 + float(level_value) * 0.045 + int(evolved) * 0.12,
		"crit_multiplier": 1.85 + int(evolved) * 0.20,
		"crit_speed_bonus": 36.0 + float(level_value) * 3.0,
		"crit_speed_duration": 1.35
	})

static func _fire_horseshoe(context, weapon_id, shooter):
	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	var shoes = 2 + level_value + int(evolved) * 4
	var start_angle = context.rng.randf_range(0.0, TAU)

	for i in range(shoes):
		var direction = Vector2.RIGHT.rotated(start_angle + float(i) / float(shoes) * TAU)
		context._fire_projectile(shooter, direction, context._scaled_damage(5 + level_value * 2, shooter), 860.0 + level_value * 30.0, 2 + int(evolved) * 4, 0.92, {
			"hit_radius": 7.5,
			"visual": "horseshoe",
			"color": Color("#bfc4c2"),
			"line_length": 18.0,
			"spin": 12.0
		})

static func _fire_ghost_lantern(context, weapon_id, shooter):
	var level_value = context._weapon_level(weapon_id)
	var evolved = context._is_evolved(weapon_id)
	var pulses = 4 + level_value + int(evolved) * 4
	if context._is_synergy_weapon(weapon_id, shooter):
		pulses += 2
	var radius = 22.0 + level_value * 2.0 + int(evolved) * 7.0
	var start_angle = context.rng.randf_range(0.0, TAU)

	for i in range(pulses):
		var direction = Vector2.RIGHT.rotated(start_angle + float(i) / float(pulses) * TAU)
		context._fire_projectile(shooter, direction, context._scaled_damage(7 + level_value * 3, shooter), 390.0 + level_value * 26.0, 99, 0.52 + level_value * 0.045, {
			"hit_radius": radius,
			"visual": "lantern",
			"color": Color("#9be8d4"),
			"line_length": 16.0,
			"spin": 2.8
		})

	if evolved:
		context._fire_projectile(shooter, Vector2.ZERO, context._scaled_damage(18 + level_value * 3, shooter), 0.0, 999, 0.22, {
			"hit_radius": 90.0,
			"visual": "lantern",
			"color": Color("#c9fff0"),
			"line_length": 8.0
		})
