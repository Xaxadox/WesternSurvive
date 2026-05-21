extends Node2D

const ENEMY_SCENE_PATH = "res://scenes/enemy.tscn"
const BULLET_SCENE_PATH = "res://scenes/bullet.tscn"
const XP_PICKUP_SCENE_PATH = "res://scenes/xp_pickup.tscn"
const PLAYER_SCENE_PATH = "res://scenes/player.tscn"
const WORLD_ITEM_SCENE_PATH = "res://scenes/world_item.tscn"
const SpatialUtils = preload("res://scripts/SpatialUtils.gd")
const GameData = preload("res://scripts/GameData.gd")
const WeaponFire = preload("res://scripts/weapons/WeaponFire.gd")

const SAVE_DIR = "F:/WesternSurvive/cache"
const SAVE_PATH = "F:/WesternSurvive/cache/progress.json"
const MENU_STAGE_ID = "menu"
const MUSIC_STAGE_FADE_OUT = 0.28
const MUSIC_STAGE_FADE_IN = 0.62
const MUSIC_GAME_OVER_SILENCE = 1.2
const MUSIC_GAME_OVER_FADE_IN = 1.6
const MAX_WEAPON_LEVEL = 5
const BASE_WEAPONS = [
	"revolver",
	"shotgun",
	"dynamite",
	"lasso",
	"knife",
	"rifle",
	"fire_bottle",
	"horseshoe"
]
const SECRET_WEAPONS = [
	"golden_revolver",
	"coach_gun",
	"rail_spike",
	"ghost_lantern"
]
const MAX_BUFF_LEVEL = 5
const BASE_ENEMY_CAP = 185
const SOFT_ENEMY_CAP = 145

@onready var world = $World
@onready var floor = $World/DesertFloor
@onready var player = $World/Player
@onready var enemies = $World/Enemies
@onready var projectiles = $World/Projectiles
@onready var pickups = $World/Pickups
@onready var world_items = $World/WorldItems
@onready var group_camera = $World/GroupCamera
@onready var hud = $HUD
@onready var mine_darkness_layer = $MineDarkness
@onready var mine_darkness = $MineDarkness/Fog
@onready var music = $CodeMusic

var enemy_scene: PackedScene
var bullet_scene: PackedScene
var xp_pickup_scene: PackedScene
var player_scene: PackedScene
var world_item_scene: PackedScene
var rng = RandomNumberGenerator.new()

var characters = GameData.characters()
var stages = GameData.stages()
var weapons = GameData.weapons()
var unlock_rules = GameData.unlock_rules()
var stat_upgrades = GameData.stat_upgrades()
var progress = {
	"unlocked_weapons": [],
	"unlocked_stages": ["ghost_town", "canyon", "broken_fort", "mine"],
	"played_characters": [],
	"played_stages": [],
	"settings": {
		"master_volume": 0.85,
		"music_volume": 0.55,
		"resolution": "1280x720",
		"fullscreen": false,
		"language": "pt"
	}
}

var selected_stage = {}
var selected_character = {}
var party_characters = []
var players = []
var active_player_count = 1
var run_started = false
var game_time = 0.0
var kills = 0
var level = 1
var xp = 0
var xp_required = 8
var level_choice_open = false
var is_game_over = false
var manual_pause_open = false

var weapon_levels = {}
var weapon_timers = {}
var weapon_evolved = {}
var firing_weapon_context = ""
var buff_levels = {}
var buff_evolved = {}
var buff_cooldown_mult = 1.0
var xp_gain_mult = 1.0
var passive_regen_per_second = 0.0
var passive_regen_carry = 0.0

var spawn_timer = 0.0
var spawn_batch_timer = 0.0
var world_item_timer = 0.0
var pending_window_size = Vector2i(1280, 720)
var hud_update_timer = 0.0
var target_music_volume = 0.55
var current_music_volume = 0.55
var music_tween: Tween = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	rng.randomize()
	_load_scene_dependencies()
	get_tree().paused = false
	if world != null:
		world.process_mode = Node.PROCESS_MODE_PAUSABLE
	if mine_darkness_layer != null:
		mine_darkness_layer.layer = 1
	if mine_darkness != null:
		mine_darkness.visible = false
	if hud != null:
		hud.layer = 2
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	hud.settings_changed.connect(_on_settings_changed)
	hud.resume_requested.connect(_on_pause_resume_requested)
	hud.return_to_menu_requested.connect(_return_to_start_menu)
	hud.quit_requested.connect(_on_quit_requested)
	if is_instance_valid(music) and not music.beat_hit.is_connected(_on_music_beat_hit):
		music.beat_hit.connect(_on_music_beat_hit)
	_load_progress()
	_apply_settings(progress.get("settings", {}))
	if is_instance_valid(music):
		music.configure(MENU_STAGE_ID)
		_set_runtime_music_volume(_music_target_volume())
	hud.set_stats(player.health, player.max_health, xp, xp_required, level, kills, game_time)
	hud.set_run_context(_t("select_stage"), _t("select_character"))
	hud.set_weapons([])
	hud.set_settings(progress.get("settings", {}))
	hud.show_start_menu(characters, stages, progress, _start_run)

func _music_target_volume():
	return clampf(target_music_volume, 0.0, 1.0)

func _set_runtime_music_volume(value):
	current_music_volume = clampf(float(value), 0.0, 1.0)
	if is_instance_valid(music):
		music.set_music_volume(current_music_volume)

func _stop_music_tween():
	if music_tween != null:
		music_tween.kill()
		music_tween = null

func _create_music_tween():
	_stop_music_tween()
	music_tween = create_tween()
	music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return music_tween

func _transition_music_to(stage_id, fade_out_duration = MUSIC_STAGE_FADE_OUT, fade_in_duration = MUSIC_STAGE_FADE_IN):
	if not is_instance_valid(music):
		return

	var tween = _create_music_tween()
	var next_stage_id = stage_id if stage_id != "" else MENU_STAGE_ID
	var next_volume = _music_target_volume()
	tween.tween_method(Callable(self, "_set_runtime_music_volume"), current_music_volume, 0.0, fade_out_duration)
	tween.tween_callback(Callable(music, "configure").bind(next_stage_id))
	tween.tween_method(Callable(self, "_set_runtime_music_volume"), 0.0, next_volume, fade_in_duration)

func _cut_music_for_game_over():
	if not is_instance_valid(music):
		return

	_stop_music_tween()
	_set_runtime_music_volume(0.0)
	music.configure(MENU_STAGE_ID)

	var next_volume = _music_target_volume()
	if next_volume <= 0.0:
		return

	var tween = _create_music_tween()
	tween.tween_interval(MUSIC_GAME_OVER_SILENCE)
	tween.tween_method(Callable(self, "_set_runtime_music_volume"), 0.0, next_volume, MUSIC_GAME_OVER_FADE_IN)

func _music_visual_latency():
	if is_instance_valid(music) and music.generator != null:
		return maxf(0.0, float(music.generator.buffer_length))
	return 0.0

func _on_music_beat_hit(type):
	if hud == null or not hud.has_method("pulse_music_beat"):
		return

	var delay = _music_visual_latency()
	if delay <= 0.0:
		hud.pulse_music_beat(type)
		return

	get_tree().create_timer(delay, true).timeout.connect(func():
		if hud != null and hud.has_method("pulse_music_beat"):
			hud.pulse_music_beat(type)
	)

func _load_scene_dependencies():
	enemy_scene = load(ENEMY_SCENE_PATH) as PackedScene
	bullet_scene = load(BULLET_SCENE_PATH) as PackedScene
	xp_pickup_scene = load(XP_PICKUP_SCENE_PATH) as PackedScene
	player_scene = load(PLAYER_SCENE_PATH) as PackedScene
	world_item_scene = load(WORLD_ITEM_SCENE_PATH) as PackedScene

func _process(delta):
	if get_tree().paused:
		return
	if not run_started or is_game_over or level_choice_open:
		return

	_enforce_stage_layout()
	game_time += delta
	_update_party_camera(delta)
	_process_spawning(delta)
	_process_world_items(delta)
	_process_passive_buffs(delta)
	_process_weapons(delta)
	hud_update_timer -= delta
	if hud_update_timer <= 0.0:
		hud_update_timer = 0.12
		hud.set_stats(_party_health(), _party_max_health(), xp, xp_required, level, kills, game_time)
		hud.set_weapons(_weapon_summary())

func _input(event):
	if _pause_pressed(event) and _can_toggle_manual_pause():
		_set_manual_pause(not manual_pause_open)
		get_viewport().set_input_as_handled()

func _pause_pressed(event):
	if event.is_action_pressed("ui_cancel"):
		return true
	if event is InputEventKey:
		return event.pressed and not event.echo and event.keycode == KEY_ESCAPE
	return false

func _can_toggle_manual_pause():
	return run_started and not is_game_over and not level_choice_open

func _set_manual_pause(value):
	manual_pause_open = value
	get_tree().paused = value
	hud.show_pause(value)

func _on_pause_resume_requested():
	if manual_pause_open:
		_set_manual_pause(false)

func _on_quit_requested():
	get_tree().quit()

func _return_to_start_menu():
	get_tree().paused = false
	run_started = false
	is_game_over = false
	level_choice_open = false
	manual_pause_open = false
	game_time = 0.0
	kills = 0
	level = 1
	xp = 0
	xp_required = 8
	spawn_timer = 0.0
	spawn_batch_timer = 0.0
	world_item_timer = 0.0
	weapon_levels.clear()
	weapon_timers.clear()
	weapon_evolved.clear()
	_reset_run_buffs()
	_clear_children(enemies)
	_clear_children(projectiles)
	_clear_children(pickups)
	_clear_children(world_items)
	_reset_world_to_menu()
	_transition_music_to(MENU_STAGE_ID)
	hud.show_pause(false)
	hud.hide_game_over()
	hud.set_stats(player.health, player.max_health, xp, xp_required, level, kills, game_time)
	hud.set_run_context(_t("select_stage"), _t("select_character"))
	hud.set_weapons([])
	hud.show_start_menu(characters, stages, progress, _start_run)

func _start_run(stage_id, character_id, player_count = 1):
	selected_stage = _stage_by_id(stage_id)
	selected_character = _character_by_id(character_id)
	active_player_count = clampi(int(player_count), 1, 4)

	run_started = true
	is_game_over = false
	level_choice_open = false
	manual_pause_open = false
	get_tree().paused = false
	game_time = 0.0
	kills = 0
	level = 1
	xp = 0
	xp_required = 8
	spawn_timer = 0.0
	spawn_batch_timer = 8.0
	world_item_timer = 0.0
	hud_update_timer = 0.0
	weapon_levels.clear()
	weapon_timers.clear()
	weapon_evolved.clear()
	_reset_run_buffs()
	_clear_children(enemies)
	_clear_children(projectiles)
	_clear_children(pickups)
	_clear_children(world_items)

	_setup_players(character_id, active_player_count)
	_record_played_menu_info(selected_stage.get("id", ""), _party_character_ids())
	floor.set_stage(selected_stage)
	_configure_stage_mechanics()
	_transition_music_to(selected_stage.get("id", "ghost_town"))
	hud.hide_start_menu()
	hud.hide_game_over()
	hud.show_pause(false)
	hud.set_run_context(_localized(selected_stage, "name"), _players_text(active_player_count))

	for character in party_characters:
		_add_weapon(character.get("starter_weapon", "revolver"), true)

	for i in range(int(selected_stage.get("initial_enemies", 12))):
		_spawn_enemy(true)

	_seed_world_items()
	_update_party_camera(0.0)
	hud.show_toast(_run_started_text(active_player_count, _localized(selected_stage, "name")))
	hud.set_weapons(_weapon_summary())
	hud.set_stats(_party_health(), _party_max_health(), xp, xp_required, level, kills, game_time)

func _setup_players(character_id, count):
	players.clear()
	party_characters.clear()

	for existing in get_tree().get_nodes_in_group("player"):
		if existing != player and existing.get_parent() == world:
			existing.queue_free()

	var start_index = _character_index_by_id(character_id)
	for i in range(count):
		var character = characters[(start_index + i) % characters.size()]
		var current_player = player
		if i > 0:
			current_player = player_scene.instantiate()
			world.add_child(current_player)
		current_player.name = "Player%d" % (i + 1)
		current_player.configure(character, i)
		current_player.set_meta("character", character)
		current_player.global_position = _stage_safe_position(_player_spawn_position(i, count))
		_set_player_camera(current_player, false)
		_connect_player_signals(current_player)
		players.append(current_player)
		party_characters.append(character)

	player = players[0]
	if group_camera != null:
		group_camera.enabled = true

func _reset_world_to_menu():
	for existing in get_tree().get_nodes_in_group("player"):
		if existing != player and existing.get_parent() == world:
			existing.queue_free()

	players.clear()
	party_characters.clear()
	if is_instance_valid(player):
		player.configure(characters[0], 0)
		player.global_position = Vector2.ZERO
		_set_player_camera(player, false)
		_connect_player_signals(player)
		players.append(player)
		party_characters.append(characters[0])
	if group_camera != null:
		group_camera.enabled = true
		group_camera.global_position = Vector2.ZERO
	if floor != null:
		floor.set_stage(stages[0])
	if mine_darkness != null:
		mine_darkness.visible = false
		if mine_darkness.has_method("set_active"):
			mine_darkness.set_active(false)

func _connect_player_signals(current_player):
	var health_callable = Callable(self, "_on_player_health_changed")
	var died_callable = Callable(self, "_on_player_died")
	if not current_player.health_changed.is_connected(health_callable):
		current_player.health_changed.connect(health_callable)
	if not current_player.died.is_connected(died_callable):
		current_player.died.connect(died_callable)

func _set_player_camera(current_player, enabled):
	var camera = current_player.get_node_or_null("Camera2D")
	if camera != null:
		camera.enabled = enabled

func _player_spawn_position(index, count):
	if count <= 1:
		return Vector2.ZERO
	var angle = -PI / 2.0 + float(index) / float(count) * TAU
	return Vector2.RIGHT.rotated(angle) * 42.0

func _clear_children(node):
	for child in node.get_children():
		child.queue_free()

func _reset_run_buffs():
	buff_levels.clear()
	buff_evolved.clear()
	buff_cooldown_mult = 1.0
	xp_gain_mult = 1.0
	passive_regen_per_second = 0.0
	passive_regen_carry = 0.0

func _process_spawning(delta):
	spawn_timer -= delta
	spawn_batch_timer -= delta

	var spawn_mult = float(selected_stage.get("spawn_mult", 1.0)) * _co_op_spawn_mult()
	var enemy_count = enemies.get_child_count()
	var enemy_cap = _enemy_cap()
	var pressure = clampf(float(enemy_count - SOFT_ENEMY_CAP) / float(maxi(enemy_cap - SOFT_ENEMY_CAP, 1)), 0.0, 1.0)
	var spawn_delay = maxf(0.18, (1.12 - game_time * 0.0035) / spawn_mult) * lerpf(1.0, 2.6, pressure)
	if spawn_timer <= 0.0:
		spawn_timer = spawn_delay
		_spawn_enemy(false)

	if spawn_batch_timer <= 0.0 and game_time > 16.0 and enemy_count < enemy_cap:
		spawn_batch_timer = maxf(3.8, 12.0 - game_time * 0.018)
		var batch_size = maxi(1, 2 + int(game_time / 42.0) - int(pressure * 3.0))
		if selected_stage.get("id", "") == "bonus":
			batch_size += 2
		for i in range(batch_size):
			_spawn_enemy(false)

func _process_world_items(delta):
	if world_item_scene == null or world_items == null:
		return

	_prune_world_items()
	world_item_timer -= delta
	if world_item_timer > 0.0:
		return

	world_item_timer = rng.randf_range(6.5, 9.0)
	if world_items.get_child_count() < _world_item_cap():
		_spawn_world_item(false)

func _prune_world_items():
	var center = _party_center()
	var max_distance_sq = 2200.0 * 2200.0
	for item in world_items.get_children():
		if is_instance_valid(item) and item.global_position.distance_squared_to(center) > max_distance_sq:
			item.queue_free()

func _seed_world_items():
	if world_item_scene == null or world_items == null:
		return

	var count = maxi(4, int(round(float(_world_item_cap()) * 0.55)))
	for i in range(count):
		_spawn_world_item(true)

func _spawn_world_item(initial):
	var item = world_item_scene.instantiate()
	world_items.add_child(item)
	item.global_position = _world_item_spawn_position(initial)
	if item.has_method("setup"):
		item.setup({
			"kind": _roll_world_item_kind(),
			"heal": 10 + int(selected_stage.get("id", "") == "ghost_town") * 2,
			"damage": 32 + int(selected_stage.get("id", "") == "broken_fort") * 6,
			"radius": 96.0,
			"fuse": 2.75
		}, players)

func _world_item_spawn_position(initial):
	return _stage_spawn_position(_party_center(), 260.0, 960.0) if initial else _stage_spawn_position(_party_center(), 720.0, 1160.0)

func _roll_world_item_kind():
	var food_weight = 0.62 * float(selected_stage.get("food_mult", 1.0))
	var bomb_weight = 0.50 * float(selected_stage.get("bomb_mult", 1.0))
	var total = food_weight + bomb_weight
	if total <= 0.0:
		return "food"
	return "food" if rng.randf() <= food_weight / total else "bomb"

func _world_item_cap():
	return 8 + active_player_count + int(selected_stage.get("id", "") == "bonus") * 4

func _process_passive_buffs(delta):
	if passive_regen_per_second <= 0.0:
		return

	passive_regen_carry += passive_regen_per_second * delta
	var heal_amount = int(passive_regen_carry)
	if heal_amount <= 0:
		return

	passive_regen_carry -= float(heal_amount)
	for current_player in _alive_players():
		current_player.heal(heal_amount)

func _stage_spawn_position(origin, min_distance, max_distance):
	for attempt in range(24):
		var angle = rng.randf_range(0.0, TAU)
		var distance = rng.randf_range(min_distance, max_distance)
		var candidate = origin + Vector2.RIGHT.rotated(angle) * distance
		if _stage_position_walkable(candidate):
			return candidate
	return _stage_safe_position(origin + Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU)) * min_distance)

func _stage_safe_position(position):
	if selected_stage.get("id", "") == "mine" and floor != null and floor.has_method("mine_safe_position"):
		return floor.mine_safe_position(position)
	return position

func _stage_position_walkable(position):
	if selected_stage.get("id", "") == "mine" and floor != null and floor.has_method("is_mine_walkable"):
		return floor.is_mine_walkable(position)
	return true

func _enforce_stage_layout():
	if selected_stage.get("id", "") != "mine" or floor == null or not floor.has_method("mine_safe_position"):
		return

	for current_player in players:
		if is_instance_valid(current_player):
			current_player.global_position = floor.mine_safe_position(current_player.global_position)

	for enemy in enemies.get_children():
		if is_instance_valid(enemy):
			enemy.global_position = floor.mine_safe_position(enemy.global_position)

	for item in world_items.get_children():
		if is_instance_valid(item):
			item.global_position = floor.mine_safe_position(item.global_position)

	for pickup in pickups.get_children():
		if is_instance_valid(pickup):
			pickup.global_position = floor.mine_safe_position(pickup.global_position)

func _process_weapons(delta):
	for weapon_id in weapon_levels.keys():
		weapon_timers[weapon_id] = float(weapon_timers.get(weapon_id, 0.0)) - delta
		if weapon_timers[weapon_id] <= 0.0:
			for shooter in _alive_players():
				_fire_weapon(weapon_id, shooter)
			weapon_timers[weapon_id] = _weapon_cooldown(weapon_id)

func _spawn_enemy(initial):
	if enemies.get_child_count() >= _enemy_cap():
		return

	var enemy = enemy_scene.instantiate()
	enemies.add_child(enemy)
	enemy.target = player
	if enemy.has_method("set_targets"):
		enemy.set_targets(players)
	enemy.setup(_roll_enemy_data())
	enemy.died.connect(_on_enemy_died)

	var min_distance = 300.0 if initial else 520.0
	var max_distance = 650.0 if initial else 780.0
	enemy.global_position = _stage_spawn_position(_party_center(), min_distance, max_distance)

func _roll_enemy_data():
	var pressure = 1.0 + game_time / 120.0
	var health_mult = float(selected_stage.get("enemy_health", 1.0)) * _co_op_health_mult()
	var speed_mult = float(selected_stage.get("enemy_speed", 1.0))
	var roll = rng.randf()

	if selected_stage.get("id", "") == "bonus" and roll > 0.86:
		return {
			"health": int(52 * pressure * health_mult),
			"speed": (90.0 + game_time * 0.10) * speed_mult,
			"damage": 20,
			"xp": 6,
			"scale": 1.42,
			"color": Color("#29243e"),
			"hat": Color("#d5b653"),
			"attack_delay": 0.66,
			"knockback": 5.0
		}

	if game_time > 80.0 and roll > 0.78:
		return {
			"health": int(34 * pressure * health_mult),
			"speed": (72.0 + game_time * 0.08) * speed_mult,
			"damage": 16,
			"xp": 4,
			"scale": 1.28,
			"color": Color("#5f3029"),
			"hat": Color("#19110d"),
			"attack_delay": 0.72,
			"knockback": 6.0
		}

	if game_time > 28.0 and roll > 0.58:
		return {
			"health": int(13 * pressure * health_mult),
			"speed": (155.0 + game_time * 0.13) * speed_mult,
			"damage": 7,
			"xp": 2,
			"scale": 0.9,
			"color": Color("#8a5631"),
			"hat": Color("#3a261b"),
			"attack_delay": 0.42,
			"knockback": 13.0
		}

	return {
		"health": int(16 * pressure * health_mult),
		"speed": (98.0 + game_time * 0.10) * speed_mult,
		"damage": 9,
		"xp": 1,
		"scale": 1.0,
		"color": Color("#743126"),
		"hat": Color("#2c1a12"),
		"attack_delay": 0.58,
		"knockback": 10.0
	}

func _fire_weapon(weapon_id, shooter):
	WeaponFire.fire(self, weapon_id, shooter)

func _fire_projectile(shooter, direction, damage, speed, pierce, lifetime, options):
	var safe_direction = direction.normalized()
	if safe_direction == Vector2.ZERO:
		safe_direction = Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU))

	var bullet = bullet_scene.instantiate()
	projectiles.add_child(bullet)
	bullet.global_position = shooter.global_position + safe_direction * 24.0
	bullet.setup(safe_direction, damage, speed, pierce, lifetime, options)

func _weapon_cooldown(weapon_id):
	var level_value = _weapon_level(weapon_id)
	var base = float(weapons[weapon_id].get("cooldown", 1.0))
	var cooldown = base * pow(0.91, level_value - 1)
	if _is_evolved(weapon_id):
		cooldown *= 0.82
	if _any_synergy_weapon(weapon_id):
		cooldown *= 0.84
	cooldown *= _party_cooldown_mult()
	cooldown *= buff_cooldown_mult
	if selected_stage.get("id", "") == "bonus":
		cooldown *= 0.94
	return maxf(cooldown, 0.12)

func _scaled_damage(amount, shooter):
	var character = _character_for_player(shooter)
	var damage = float(amount) * float(character.get("damage_mult", 1.0))
	if _is_synergy_weapon(firing_weapon_context, shooter):
		damage *= 1.18
	return int(ceil(damage))

func _is_synergy_weapon(weapon_id, shooter = null):
	if weapon_id == "":
		return false
	if shooter != null:
		return _character_for_player(shooter).get("synergy_weapon", "") == weapon_id
	for character in party_characters:
		if character.get("synergy_weapon", "") == weapon_id:
			return true
	return false

func _any_synergy_weapon(weapon_id):
	return _is_synergy_weapon(weapon_id)

func _party_cooldown_mult():
	var result = 1.0
	for character in party_characters:
		result = minf(result, float(character.get("cooldown_mult", 1.0)))
	return result

func _co_op_health_mult():
	return 1.0 + max(active_player_count - 1, 0) * 0.45

func _co_op_spawn_mult():
	return 1.0 + max(active_player_count - 1, 0) * 0.12

func _enemy_cap():
	var cap = BASE_ENEMY_CAP + max(active_player_count - 1, 0) * 10
	if selected_stage.get("id", "") == "bonus":
		cap += 24
	return cap

func _character_for_player(current_player):
	if current_player != null and current_player.has_meta("character"):
		var character = current_player.get_meta("character")
		if typeof(character) == TYPE_DICTIONARY:
			return character
	return selected_character

func _weapon_direction(weapon_id, shooter):
	if bool(weapons.get(weapon_id, {}).get("secret", false)):
		var target = _nearest_enemy(shooter.global_position)
		if target == null:
			return Vector2.ZERO
		return (target.global_position - shooter.global_position).normalized()

	var direction = shooter.aim_direction.normalized()
	if direction == Vector2.ZERO:
		return Vector2.RIGHT
	return direction

func _nearest_enemy(source_position):
	return SpatialUtils.nearest_valid(source_position, enemies.get_children())

func _on_enemy_died(enemy):
	kills += 1
	call_deferred("_spawn_xp_pickup", enemy.global_position, enemy.xp_value)

func _spawn_xp_pickup(drop_position, value):
	var pickup = xp_pickup_scene.instantiate()
	pickups.add_child(pickup)
	pickup.global_position = drop_position
	pickup.setup(value, players)

func add_xp(amount):
	if is_game_over or not run_started:
		return

	xp += maxi(1, int(ceil(float(amount) * xp_gain_mult)))
	_try_level_up()
	hud.set_stats(_party_health(), _party_max_health(), xp, xp_required, level, kills, game_time)

func _try_level_up():
	if level_choice_open or xp < xp_required:
		return

	xp -= xp_required
	level += 1
	xp_required = int(ceil(float(xp_required) * 1.20 + 5.0))
	var choices = _roll_upgrade_choices()
	if choices.is_empty():
		hud.show_toast(_t("all_upgrades_maxed"))
		return
	level_choice_open = true
	get_tree().paused = true
	hud.show_pause(false)
	hud.show_level_up(choices, _on_upgrade_selected)

func _roll_upgrade_choices():
	var pool = []
	for weapon_id in _available_weapon_ids():
		if weapon_levels.has(weapon_id):
			if int(weapon_levels[weapon_id]) < MAX_WEAPON_LEVEL:
				var next_level = int(weapon_levels[weapon_id]) + 1
				pool.append({
					"type": "weapon",
					"id": weapon_id,
					"title": _upgrade_weapon_title(weapon_id, next_level),
					"desc": _weapon_upgrade_description(weapon_id, next_level),
					"icon": weapons[weapon_id].get("icon", weapon_id)
				})
		else:
			pool.append({
				"type": "weapon",
				"id": weapon_id,
				"title": _new_weapon_title(weapon_id),
				"desc": "%s\n%s" % [_localized(weapons[weapon_id], "desc"), _weapon_preview_text(weapon_id, 1)],
				"icon": weapons[weapon_id].get("icon", weapon_id)
			})

	for upgrade in stat_upgrades:
		var buff_id = upgrade.get("id", "")
		var next_level = int(buff_levels.get(buff_id, 0)) + 1
		if next_level <= MAX_BUFF_LEVEL:
			pool.append({
				"type": "buff",
				"id": buff_id,
				"title": _upgrade_buff_title(buff_id, next_level),
				"desc": _buff_upgrade_description(buff_id, next_level),
				"icon": upgrade.get("icon", buff_id)
			})

	pool.shuffle()
	return pool.slice(0, mini(3, pool.size()))

func _available_weapon_ids():
	var result = BASE_WEAPONS.duplicate()
	for weapon_id in progress.get("unlocked_weapons", []):
		if not result.has(weapon_id):
			result.append(weapon_id)
	return result

func _upgrade_weapon_title(weapon_id, next_level):
	return "%s %s %d" % [_localized(weapons[weapon_id], "name"), _t("level_short"), next_level]

func _new_weapon_title(weapon_id):
	return "%s: %s" % [_t("new_weapon"), _localized(weapons[weapon_id], "name")]

func _upgrade_buff_title(buff_id, next_level):
	var buff = _buff_by_id(buff_id)
	return "%s %s %d" % [_localized(buff, "title"), _t("level_short"), next_level]

func _weapon_upgrade_description(weapon_id, next_level):
	return "%s\n%s %d: %s" % [
		_weapon_preview_text(weapon_id, next_level),
		_t("max_level"),
		MAX_WEAPON_LEVEL,
		_localized(weapons[weapon_id], "max_bonus")
	]

func _buff_upgrade_description(buff_id, next_level):
	var buff = _buff_by_id(buff_id)
	return "%s\n%s %d: %s" % [
		_buff_preview_text(buff_id, next_level),
		_t("max_level"),
		MAX_BUFF_LEVEL,
		_localized(buff, "max_bonus")
	]

func _weapon_preview_text(weapon_id, level_value):
	var parts = []
	var cooldown = _format_cooldown(_weapon_cooldown_preview(weapon_id, level_value))

	match weapon_id:
		"revolver", "golden_revolver":
			var bonus_shots = 2 if weapon_id == "golden_revolver" else 0
			var shots = 1 + int((level_value - 1) / 2) + bonus_shots
			var damage = 7 + level_value * 3 + bonus_shots * 2
			var targets = 1 + int(level_value >= 4)
			parts = [
				_metric("damage", damage),
				_metric("shots", shots),
				_metric("targets", targets),
				_metric("cooldown", cooldown)
			]
		"shotgun", "coach_gun":
			var bonus_pellets = 3 if weapon_id == "coach_gun" else 0
			var pellets = 4 + level_value + bonus_pellets
			var damage = 4 + level_value * 2 + bonus_pellets
			var spread = int(round(rad_to_deg(0.56 + level_value * 0.025)))
			parts = [
				_metric("damage", damage),
				_metric("pellets", pellets),
				_metric("cone", "%d deg" % spread),
				_metric("cooldown", cooldown)
			]
		"dynamite":
			parts = [
				_metric("damage", 8 + level_value * 4),
				_metric("area", int(46 + level_value * 10)),
				_metric("targets", _t("many")),
				_metric("cooldown", cooldown)
			]
		"fire_bottle":
			parts = [
				_metric("damage", 6 + level_value * 3),
				_metric("area", int(58 + level_value * 10)),
				_metric("targets", _t("many")),
				_metric("cooldown", cooldown)
			]
		"lasso":
			parts = [
				_metric("damage", 4 + level_value * 2),
				_metric("targets", 7 + level_value * 2),
				_metric("width", int(15 + level_value * 1.6)),
				_metric("cooldown", cooldown)
			]
		"knife":
			parts = [
				_metric("damage", 5 + level_value * 2),
				_metric("blades", 2 + level_value),
				_metric("targets", 1 + int(level_value >= 4)),
				_metric("cooldown", cooldown)
			]
		"rifle", "rail_spike":
			var secret_bonus = 5 if weapon_id == "rail_spike" else 0
			parts = [
				_metric("damage", 15 + level_value * 6 + secret_bonus),
				_metric("targets", 3 + level_value),
				_metric("speed", 1480),
				_metric("cooldown", cooldown)
			]
		"horseshoe":
			parts = [
				_metric("damage", 5 + level_value * 2),
				_metric("shots", 2 + level_value),
				_metric("targets", 2),
				_metric("cooldown", cooldown)
			]
		"ghost_lantern":
			parts = [
				_metric("damage", 7 + level_value * 3),
				_metric("pulses", 4 + level_value),
				_metric("area", int(22 + level_value * 2)),
				_metric("cooldown", cooldown)
			]
		_:
			parts = [_metric("cooldown", cooldown)]

	return _join_parts(parts, " | ")

func _buff_preview_text(buff_id, level_value):
	var parts = []

	match buff_id:
		"spurs":
			var speed_bonus = level_value * 14 + int(level_value >= MAX_BUFF_LEVEL) * 48
			parts = [_metric("speed", "+%d" % speed_bonus)]
			if level_value >= MAX_BUFF_LEVEL:
				parts.append(_metric("cooldown", "-12%"))
		"star":
			var health_bonus = level_value * 16 + int(level_value >= MAX_BUFF_LEVEL) * 80
			parts = [_metric("health", "+%d" % health_bonus)]
			if level_value >= MAX_BUFF_LEVEL:
				parts.append(_metric("reduction", "-18%"))
		"magnet":
			var pickup_bonus = level_value * 32 + int(level_value >= MAX_BUFF_LEVEL) * 160
			parts = [_metric("pickup", "+%d" % pickup_bonus)]
			if level_value >= MAX_BUFF_LEVEL:
				parts.append(_metric("xp_bonus", "+20%"))
		"coffee":
			var speed_from_coffee = level_value * 8 + int(level_value >= MAX_BUFF_LEVEL) * 32
			parts = [
				_metric("speed", "+%d" % speed_from_coffee),
				_metric("heal_now", 75 if level_value >= MAX_BUFF_LEVEL else 16)
			]
			if level_value >= MAX_BUFF_LEVEL:
				parts.append(_metric("regen", "2/s"))
		_:
			parts = [_localized(_buff_by_id(buff_id), "desc")]

	return _join_parts(parts, " | ")

func _weapon_cooldown_preview(weapon_id, level_value):
	var base = float(weapons[weapon_id].get("cooldown", 1.0))
	return maxf(base * pow(0.91, level_value - 1), 0.12)

func _format_cooldown(value):
	return "%.2fs" % value

func _metric(label_key, value):
	return "%s %s" % [_t(label_key), str(value)]

func _join_parts(parts, separator):
	var result = ""
	for part in parts:
		if result != "":
			result += separator
		result += str(part)
	return result

func _localized(data, key):
	if typeof(data) != TYPE_DICTIONARY:
		return ""
	var value = data.get(key, "")
	if _language() == "en":
		var english_key = "%s_en" % key
		var english_value = data.get(english_key, value)
		if _is_valid_text(english_value):
			return str(english_value)
	if _is_valid_text(value):
		return str(value)
	return ""

func _is_valid_text(value):
	if value == null:
		return false
	var text = str(value)
	return text != "" and text != "<null>"

func _language():
	var settings = progress.get("settings", {})
	var language = str(settings.get("language", "pt"))
	return "en" if language == "en" else "pt"

func _players_text(count):
	if _language() == "en":
		return "%d player(s)" % count
	return "%d jogador(es)" % count

func _run_started_text(count, stage_name):
	if _language() == "en":
		return "%d player(s) entered %s" % [count, stage_name]
	return "%d jogador(es) entraram em %s" % [count, stage_name]

func _t(key):
	var english = _language() == "en"
	match key:
		"new_weapon":
			return "New weapon" if english else "Nova arma"
		"level_short":
			return "Lv" if english else "Nv"
		"max_level":
			return "At lv" if english else "No nv"
		"health":
			return "Health" if english else "Vida"
		"damage":
			return "Damage" if english else "Dano"
		"shots":
			return "Shots" if english else "Tiros"
		"pellets":
			return "Pellets" if english else "Chumbos"
		"targets":
			return "Targets" if english else "Alvos"
		"cooldown":
			return "Cooldown" if english else "Recarga"
		"cone":
			return "Cone" if english else "Cone"
		"area":
			return "Area" if english else "Area"
		"width":
			return "Width" if english else "Largura"
		"blades":
			return "Blades" if english else "Laminas"
		"speed":
			return "Speed" if english else "Veloc."
		"pickup":
			return "Pickup" if english else "Coleta"
		"xp_bonus":
			return "XP gain" if english else "XP ganho"
		"heal_now":
			return "Heal" if english else "Cura"
		"regen":
			return "Regen" if english else "Regen."
		"reduction":
			return "Damage taken" if english else "Dano recebido"
		"pulses":
			return "Pulses" if english else "Pulsos"
		"many":
			return "many" if english else "varios"
		"select_stage":
			return "Select a stage" if english else "Selecione uma fase"
		"select_character":
			return "Select a character" if english else "Selecione um personagem"
		"weapon_reached":
			return "reached lv" if english else "chegou ao nv"
		"max_buff":
			return "Max buff" if english else "Buff maximo"
		"evolved_weapon":
			return "evolved weapon" if english else "arma evoluida"
		"equipped_weapon":
			return "New weapon equipped" if english else "Nova arma equipada"
		"weapon_unlocked":
			return "New weapon unlocked." if english else "Nova arma liberada."
		"bonus_unlocked":
			return "Bonus stage unlocked: Eclipse Rail." if english else "Fase bonus liberada: Trilho do Eclipse."
		"player_down":
			return "A player fell. Remaining" if english else "Um jogador caiu. Restam"
		"all_upgrades_maxed":
			return "All upgrades are maxed." if english else "Todos upgrades estao no maximo."
		_:
			return key

func _on_upgrade_selected(choice):
	_apply_upgrade(choice)
	level_choice_open = false
	get_tree().paused = false
	hud.set_stats(_party_health(), _party_max_health(), xp, xp_required, level, kills, game_time)
	hud.set_weapons(_weapon_summary())
	call_deferred("_try_level_up")

func _apply_upgrade(choice):
	if choice.get("type", "stat") == "weapon":
		_upgrade_weapon(choice.get("id", ""))
		return

	_upgrade_buff(choice.get("id", ""))

func _upgrade_buff(buff_id):
	var buff = _buff_by_id(buff_id)
	if buff.is_empty():
		return

	var next_level = mini(int(buff_levels.get(buff_id, 0)) + 1, MAX_BUFF_LEVEL)
	buff_levels[buff_id] = next_level
	_apply_buff_level(buff_id)
	hud.show_toast("%s %s %d" % [_localized(buff, "title"), _t("weapon_reached"), next_level])

	if next_level >= MAX_BUFF_LEVEL and not bool(buff_evolved.get(buff_id, false)):
		buff_evolved[buff_id] = true
		_apply_buff_evolution(buff_id)
		hud.show_toast("%s: %s" % [_t("max_buff"), _localized(buff, "max_bonus")])

func _apply_buff_level(buff_id):
	match buff_id:
		"spurs":
			for current_player in players:
				current_player.move_speed += 14.0
		"star":
			for current_player in players:
				current_player.increase_max_health(16)
		"magnet":
			for current_player in players:
				current_player.pickup_radius += 32.0
		"coffee":
			for current_player in players:
				current_player.heal(16)
				current_player.move_speed += 8.0

func _apply_buff_evolution(buff_id):
	match buff_id:
		"spurs":
			buff_cooldown_mult *= 0.88
			for current_player in players:
				current_player.move_speed += 48.0
		"star":
			for current_player in players:
				current_player.increase_max_health(80)
				current_player.heal(80)
				current_player.damage_reduction = clampf(float(current_player.damage_reduction) + 0.18, 0.0, 0.65)
		"magnet":
			xp_gain_mult *= 1.20
			for current_player in players:
				current_player.pickup_radius += 160.0
		"coffee":
			passive_regen_per_second += 2.0
			for current_player in players:
				current_player.heal(75)
				current_player.move_speed += 32.0

func _upgrade_weapon(weapon_id):
	if not weapons.has(weapon_id):
		return

	if not weapon_levels.has(weapon_id):
		_add_weapon(weapon_id, false)
		return

	weapon_levels[weapon_id] = mini(int(weapon_levels[weapon_id]) + 1, MAX_WEAPON_LEVEL)
	hud.show_toast("%s %s %d" % [_localized(weapons[weapon_id], "name"), _t("weapon_reached"), weapon_levels[weapon_id]])

	if int(weapon_levels[weapon_id]) >= MAX_WEAPON_LEVEL and not bool(weapon_evolved.get(weapon_id, false)):
		weapon_evolved[weapon_id] = true
		hud.show_toast("%s: %s" % [_t("max_buff"), _localized(weapons[weapon_id], "max_bonus") if weapons[weapon_id].has("max_bonus") else _t("evolved_weapon")])
		_check_stage_weapon_unlock(weapon_id)

func _add_weapon(weapon_id, silent):
	if not weapons.has(weapon_id):
		return

	weapon_levels[weapon_id] = 1
	weapon_evolved[weapon_id] = false
	weapon_timers[weapon_id] = rng.randf_range(0.0, 0.35)
	if not silent:
		hud.show_toast("%s: %s" % [_t("equipped_weapon"), _localized(weapons[weapon_id], "name")])

func _check_stage_weapon_unlock(weapon_id):
	var rule_key = "%s:%s" % [selected_stage.get("id", ""), weapon_id]
	if not unlock_rules.has(rule_key):
		return

	var rule = unlock_rules[rule_key]
	var unlocked_weapon = rule.get("weapon", "")
	var unlocked_weapons = progress.get("unlocked_weapons", [])
	if unlocked_weapon == "" or unlocked_weapons.has(unlocked_weapon):
		return

	unlocked_weapons.append(unlocked_weapon)
	progress["unlocked_weapons"] = unlocked_weapons
	hud.show_toast(_localized(rule, "text") if rule.has("text") else _t("weapon_unlocked"))
	_unlock_bonus_if_ready()
	_save_progress()

func _unlock_bonus_if_ready():
	var unlocked_weapons = progress.get("unlocked_weapons", [])
	for weapon_id in SECRET_WEAPONS:
		if not unlocked_weapons.has(weapon_id):
			return

	var unlocked_stages = progress.get("unlocked_stages", [])
	if not unlocked_stages.has("bonus"):
		unlocked_stages.append("bonus")
		progress["unlocked_stages"] = unlocked_stages
		hud.show_toast(_t("bonus_unlocked"))

func _weapon_level(weapon_id):
	return int(weapon_levels.get(weapon_id, 1))

func _is_evolved(weapon_id):
	return bool(weapon_evolved.get(weapon_id, false))

func _buff_by_id(buff_id):
	for buff in stat_upgrades:
		if buff.get("id", "") == buff_id:
			return buff
	return {}

func _buff_level(buff_id):
	return int(buff_levels.get(buff_id, 0))

func _is_buff_evolved(buff_id):
	return bool(buff_evolved.get(buff_id, false))

func _weapon_summary():
	var summary = []
	for weapon_id in weapon_levels.keys():
		var name = _localized(weapons[weapon_id], "name")
		var suffix = "MAX" if _is_evolved(weapon_id) else "%s %d" % [_t("level_short"), _weapon_level(weapon_id)]
		if _is_synergy_weapon(weapon_id):
			suffix += "+"
		summary.append("%s %s" % [name, suffix])
	for buff in stat_upgrades:
		var buff_id = buff.get("id", "")
		if not buff_levels.has(buff_id):
			continue
		var buff_suffix = "MAX" if _is_buff_evolved(buff_id) else "%s %d" % [_t("level_short"), _buff_level(buff_id)]
		summary.append("%s %s" % [_localized(buff, "title"), buff_suffix])
	return summary

func _alive_players():
	var result = []
	for current_player in players:
		if _player_alive(current_player):
			result.append(current_player)
	return result

func _party_center():
	var alive = _alive_players()
	if alive.is_empty():
		alive = players

	var total = Vector2.ZERO
	var count = 0
	for current_player in alive:
		if is_instance_valid(current_player):
			total += current_player.global_position
			count += 1

	if count == 0:
		return Vector2.ZERO
	return total / float(count)

func _party_spread():
	var center = _party_center()
	var spread = 0.0
	for current_player in _alive_players():
		spread = maxf(spread, center.distance_to(current_player.global_position))
	return spread

func _update_party_camera(_delta):
	var center = _party_center()
	if group_camera != null:
		group_camera.global_position = center
		var spread = _party_spread()
		var zoom_value = clampf(1.0 - spread / 1700.0, 0.58, 1.0)
		group_camera.zoom = Vector2.ONE * zoom_value

	if floor != null and floor.has_method("set_focus_position"):
		floor.set_focus_position(center)
	if mine_darkness != null and mine_darkness.has_method("set_focus_position"):
		mine_darkness.set_focus_position(center)

func _configure_stage_mechanics():
	if mine_darkness == null:
		return
	var active = bool(selected_stage.get("darkness", false)) and DisplayServer.get_name() != "headless"
	mine_darkness.visible = active
	if mine_darkness.has_method("set_active"):
		mine_darkness.set_active(active)
	if mine_darkness.has_method("set_players"):
		mine_darkness.set_players(players)

func _player_alive(current_player):
	return is_instance_valid(current_player) and bool(current_player.alive)

func _party_health():
	var total = 0
	for current_player in players:
		if is_instance_valid(current_player):
			total += current_player.health
	return total

func _party_max_health():
	var total = 0
	for current_player in players:
		if is_instance_valid(current_player):
			total += current_player.max_health
	return max(total, 1)

func _on_player_health_changed(_current, _maximum):
	if run_started:
		hud.set_stats(_party_health(), _party_max_health(), xp, xp_required, level, kills, game_time)

func _on_player_died():
	if not _alive_players().is_empty():
		_update_party_camera(0.0)
		hud.show_toast("%s %d." % [_t("player_down"), _alive_players().size()])
		return

	is_game_over = true
	_cut_music_for_game_over()
	get_tree().paused = true
	hud.show_pause(false)
	hud.show_game_over(kills, game_time, _localized(selected_stage, "name"), progress.get("unlocked_weapons", []).size())

func _stage_by_id(stage_id):
	for stage in stages:
		if stage.get("id", "") == stage_id:
			return stage
	return stages[0]

func _character_by_id(character_id):
	for character in characters:
		if character.get("id", "") == character_id:
			return character
	return characters[0]

func _character_index_by_id(character_id):
	for i in range(characters.size()):
		if characters[i].get("id", "") == character_id:
			return i
	return 0

func _record_played_menu_info(stage_id, character_ids):
	var changed = false

	var played_characters = progress.get("played_characters", [])
	var ids = character_ids if typeof(character_ids) == TYPE_ARRAY else [character_ids]
	for character_id in ids:
		if character_id != "" and not played_characters.has(character_id):
			played_characters.append(character_id)
			changed = true
	if changed:
		progress["played_characters"] = played_characters

	var played_stages = progress.get("played_stages", [])
	if stage_id != "" and not played_stages.has(stage_id):
		played_stages.append(stage_id)
		progress["played_stages"] = played_stages
		changed = true

	if changed:
		_save_progress()

func _party_character_ids():
	var result = []
	for character in party_characters:
		var character_id = character.get("id", "")
		if character_id != "" and not result.has(character_id):
			result.append(character_id)
	return result

func _load_progress():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				progress = parsed

	if not progress.has("unlocked_weapons") or typeof(progress["unlocked_weapons"]) != TYPE_ARRAY:
		progress["unlocked_weapons"] = []
	if not progress.has("unlocked_stages") or typeof(progress["unlocked_stages"]) != TYPE_ARRAY:
		progress["unlocked_stages"] = ["ghost_town", "canyon", "broken_fort", "mine"]
	if not progress.has("played_characters") or typeof(progress["played_characters"]) != TYPE_ARRAY:
		progress["played_characters"] = []
	if not progress.has("played_stages") or typeof(progress["played_stages"]) != TYPE_ARRAY:
		progress["played_stages"] = []
	if not progress.has("settings") or typeof(progress["settings"]) != TYPE_DICTIONARY:
		progress["settings"] = {
			"master_volume": 0.85,
			"music_volume": 0.55,
			"resolution": "1280x720",
			"fullscreen": false,
			"language": "pt"
		}
	else:
		if not progress["settings"].has("language"):
			progress["settings"]["language"] = "pt"

	for stage_id in ["ghost_town", "canyon", "broken_fort", "mine"]:
		if not progress["unlocked_stages"].has(stage_id):
			progress["unlocked_stages"].append(stage_id)

func _save_progress():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(progress, "\t"))

func _on_settings_changed(settings):
	progress["settings"] = settings
	_apply_settings(settings)
	if run_started:
		hud.set_run_context(_localized(selected_stage, "name"), _players_text(active_player_count))
		hud.set_weapons(_weapon_summary())
	else:
		hud.set_run_context(_t("select_stage"), _t("select_character"))
	_save_progress()

func _apply_settings(settings):
	var master_volume = clampf(float(settings.get("master_volume", 0.85)), 0.0, 1.0)
	var music_volume = clampf(float(settings.get("music_volume", 0.55)), 0.0, 1.0)
	var resolution = str(settings.get("resolution", "1280x720"))
	var fullscreen = bool(settings.get("fullscreen", false))
	var language = str(settings.get("language", "pt"))

	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_mute(master_bus, master_volume <= 0.001)
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(master_volume, 0.001)))

	target_music_volume = music_volume
	if is_instance_valid(music):
		_set_runtime_music_volume(target_music_volume)
	if hud != null and hud.has_method("set_language"):
		hud.set_language(language)

	_apply_window_settings(resolution, fullscreen)

func _apply_window_settings(resolution, fullscreen):
	if DisplayServer.get_name() == "headless":
		return

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return

	pending_window_size = _safe_window_size(_resolution_to_size(resolution))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	call_deferred("_apply_deferred_window_size")

func _apply_deferred_window_size():
	if DisplayServer.get_name() == "headless":
		return
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return

	var size = _safe_window_size(pending_window_size)
	DisplayServer.window_set_size(size)
	_center_window(size)

func _safe_window_size(size):
	var usable = _usable_screen_rect()
	if usable.size.x <= 0 or usable.size.y <= 0:
		return size

	var max_size = Vector2i(maxi(640, usable.size.x - 48), maxi(360, usable.size.y - 72))
	if size.x <= max_size.x and size.y <= max_size.y:
		return size

	var scale = minf(float(max_size.x) / float(size.x), float(max_size.y) / float(size.y))
	return Vector2i(maxi(640, int(round(float(size.x) * scale))), maxi(360, int(round(float(size.y) * scale))))

func _center_window(size):
	var usable = _usable_screen_rect()
	if usable.size.x <= 0 or usable.size.y <= 0:
		return

	var offset = Vector2i(maxi(0, (usable.size.x - size.x) / 2), maxi(0, (usable.size.y - size.y) / 2))
	DisplayServer.window_set_position(usable.position + offset)

func _usable_screen_rect():
	var screen = DisplayServer.window_get_current_screen()
	var usable = DisplayServer.screen_get_usable_rect(screen)
	if usable.size.x <= 0 or usable.size.y <= 0:
		usable = Rect2i(Vector2i.ZERO, DisplayServer.screen_get_size(screen))
	return usable

func _resolution_to_size(value):
	match value:
		"960x540":
			return Vector2i(960, 540)
		"1366x768":
			return Vector2i(1366, 768)
		"1600x900":
			return Vector2i(1600, 900)
		"1920x1080":
			return Vector2i(1920, 1080)
		_:
			return Vector2i(1280, 720)
