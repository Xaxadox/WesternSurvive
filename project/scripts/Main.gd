extends Node2D

const ENEMY_SCENE_PATH = "res://scenes/enemy.tscn"
const BULLET_SCENE_PATH = "res://scenes/bullet.tscn"
const XP_PICKUP_SCENE_PATH = "res://scenes/xp_pickup.tscn"
const PLAYER_SCENE_PATH = "res://scenes/player.tscn"
const WORLD_ITEM_SCENE_PATH = "res://scenes/world_item.tscn"

const SAVE_DIR = "F:/WesternSurvive/cache"
const SAVE_PATH = "F:/WesternSurvive/cache/progress.json"
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

var characters = [
	{
		"id": "gunslinger",
		"name": "Pistoleiro",
		"name_en": "Gunslinger",
		"desc": "Equilibrado, com revolver inicial.",
		"desc_en": "Balanced, starts with a revolver.",
		"starter_weapon": "revolver",
		"synergy_weapon": "golden_revolver",
		"synergy_desc": "Sinergia: Revolver Dourado causa mais dano e recarrega mais rapido.",
		"synergy_desc_en": "Synergy: Golden Revolver deals more damage and reloads faster.",
		"health": 100,
		"speed": 235.0,
		"pickup": 95.0,
		"damage_mult": 1.0,
		"cooldown_mult": 1.0,
		"coat": Color("#37514a"),
		"hat": Color("#4a2c1d"),
		"scarf": Color("#d64a35"),
		"skin": Color("#f0b77d"),
		"outline": Color("#f2d36b"),
		"badge": Color("#f2d36b"),
		"visual_weapon": "revolver",
		"silhouette": "gunslinger"
	},
	{
		"id": "sheriff",
		"name": "Xerife",
		"name_en": "Sheriff",
		"desc": "Mais vida, com espingarda inicial.",
		"desc_en": "More health, starts with a shotgun.",
		"starter_weapon": "shotgun",
		"synergy_weapon": "coach_gun",
		"synergy_desc": "Sinergia: Escopeta de Carruagem dispara com cadencia melhor.",
		"synergy_desc_en": "Synergy: Coach Gun fires with better cadence.",
		"health": 125,
		"speed": 215.0,
		"pickup": 88.0,
		"damage_mult": 1.05,
		"cooldown_mult": 1.04,
		"coat": Color("#244a78"),
		"hat": Color("#2d261d"),
		"scarf": Color("#f0c95a"),
		"skin": Color("#f1c08b"),
		"outline": Color("#8fd3ff"),
		"badge": Color("#ffd56a"),
		"visual_weapon": "shotgun",
		"silhouette": "sheriff"
	},
	{
		"id": "bounty_hunter",
		"name": "Cacadora",
		"name_en": "Bounty Hunter",
		"desc": "Rapida e precisa, com rifle inicial.",
		"desc_en": "Fast and precise, starts with a rifle.",
		"starter_weapon": "rifle",
		"synergy_weapon": "rail_spike",
		"synergy_desc": "Sinergia: Lanca-Trilhos ganha dano extra.",
		"synergy_desc_en": "Synergy: Rail Spike gains extra damage.",
		"health": 86,
		"speed": 268.0,
		"pickup": 105.0,
		"damage_mult": 1.10,
		"cooldown_mult": 0.96,
		"coat": Color("#7f4fb0"),
		"hat": Color("#1f1728"),
		"scarf": Color("#ffd166"),
		"skin": Color("#e9a978"),
		"outline": Color("#f59be7"),
		"badge": Color("#f59be7"),
		"visual_weapon": "rifle",
		"silhouette": "hunter"
	},
	{
		"id": "shaman",
		"name": "Curandeiro",
		"name_en": "Healer",
		"desc": "Coleta longe e comeca com garrafa de fogo.",
		"desc_en": "Long pickup reach, starts with a fire bottle.",
		"starter_weapon": "fire_bottle",
		"synergy_weapon": "ghost_lantern",
		"synergy_desc": "Sinergia: Lampiao Fantasma pulsa mais vezes.",
		"synergy_desc_en": "Synergy: Ghost Lantern pulses more times.",
		"health": 94,
		"speed": 226.0,
		"pickup": 150.0,
		"damage_mult": 0.96,
		"cooldown_mult": 0.92,
		"coat": Color("#2f6f73"),
		"hat": Color("#203034"),
		"scarf": Color("#9be8d4"),
		"skin": Color("#d7a06f"),
		"outline": Color("#9be8d4"),
		"badge": Color("#9be8d4"),
		"visual_weapon": "lantern",
		"silhouette": "healer"
	}
]

var stages = [
	{
		"id": "ghost_town",
		"name": "Cidade Fantasma",
		"name_en": "Ghost Town",
		"desc": "Ruas abertas, gangues em quantidade.",
		"desc_en": "Open streets with large gangs.",
		"floor": Color("#c99052"),
		"grid": Color(0.55, 0.31, 0.15, 0.14),
		"accent": Color("#7a4a27"),
		"enemy_health": 1.0,
		"enemy_speed": 1.0,
		"spawn_mult": 1.0,
		"initial_enemies": 12,
		"food_mult": 1.25,
		"bomb_mult": 0.85
	},
	{
		"id": "canyon",
		"name": "Canyon Vermelho",
		"name_en": "Red Canyon",
		"desc": "Inimigos rapidos e corredores estreitos.",
		"desc_en": "Fast enemies and narrow paths.",
		"floor": Color("#b45f3c"),
		"grid": Color(0.33, 0.12, 0.08, 0.16),
		"accent": Color("#6a2720"),
		"enemy_health": 1.10,
		"enemy_speed": 1.10,
		"spawn_mult": 0.95,
		"initial_enemies": 13,
		"food_mult": 0.88,
		"bomb_mult": 1.05
	},
	{
		"id": "broken_fort",
		"name": "Forte Quebrado",
		"name_en": "Broken Fort",
		"desc": "Patio apertado, perfeito para armas em cone.",
		"desc_en": "Tight yard, ideal for cone weapons.",
		"floor": Color("#a97945"),
		"grid": Color(0.30, 0.18, 0.10, 0.18),
		"accent": Color("#4f3420"),
		"enemy_health": 1.16,
		"enemy_speed": 1.02,
		"spawn_mult": 1.06,
		"initial_enemies": 14,
		"food_mult": 1.0,
		"bomb_mult": 1.35
	},
	{
		"id": "mine",
		"name": "Mina Abandonada",
		"name_en": "Abandoned Mine",
		"desc": "Criaturas resistentes e muita pressao.",
		"desc_en": "Resistant creatures and heavy pressure.",
		"floor": Color("#6f5d4b"),
		"grid": Color(0.12, 0.09, 0.07, 0.22),
		"accent": Color("#c59b4f"),
		"enemy_health": 1.25,
		"enemy_speed": 0.95,
		"spawn_mult": 1.12,
		"initial_enemies": 11,
		"food_mult": 0.75,
		"bomb_mult": 1.15,
		"darkness": true
	},
	{
		"id": "bonus",
		"name": "Trilho do Eclipse",
		"name_en": "Eclipse Rail",
		"desc": "Fase bonus liberada pelas 4 armas secretas.",
		"desc_en": "Bonus stage unlocked by all 4 secret weapons.",
		"floor": Color("#393b4f"),
		"grid": Color(0.72, 0.61, 0.23, 0.16),
		"accent": Color("#f0c85a"),
		"enemy_health": 1.42,
		"enemy_speed": 1.18,
		"spawn_mult": 1.22,
		"initial_enemies": 18,
		"food_mult": 0.95,
		"bomb_mult": 1.45,
		"bonus": true
	}
]

var weapons = {
	"revolver": {
		"name": "Revolver",
		"name_en": "Revolver",
		"desc": "Tiros precisos na direcao da mira.",
		"desc_en": "Precise shots toward the aim pointer.",
		"max_bonus": "Olho de Duelo: mais tiros e penetracao.",
		"max_bonus_en": "Duel Eye: more shots and penetration.",
		"cooldown": 0.66,
		"icon": "revolver"
	},
	"shotgun": {
		"name": "Espingarda",
		"name_en": "Shotgun",
		"desc": "Rajada curta com varios chumbos.",
		"desc_en": "Short burst with several pellets.",
		"max_bonus": "Cano Serrado: rajada enorme em cone.",
		"max_bonus_en": "Sawed Barrel: huge cone burst.",
		"cooldown": 1.32,
		"icon": "shotgun"
	},
	"dynamite": {
		"name": "Dinamite",
		"name_en": "Dynamite",
		"desc": "Explode em grupos de inimigos.",
		"desc_en": "Explodes into enemy groups.",
		"max_bonus": "Pavio Duplo: explosao maior e estilhacos.",
		"max_bonus_en": "Double Fuse: larger blast and shrapnel.",
		"cooldown": 2.15,
		"icon": "dynamite"
	},
	"lasso": {
		"name": "Laco",
		"name_en": "Lasso",
		"desc": "Corta uma linha larga atravessando inimigos.",
		"desc_en": "Cuts a wide line through enemies.",
		"max_bonus": "No de Ferro: muito mais alcance e area.",
		"max_bonus_en": "Iron Knot: much more range and area.",
		"cooldown": 1.62,
		"icon": "lasso"
	},
	"knife": {
		"name": "Facas",
		"name_en": "Knives",
		"desc": "Leque rapido de laminas.",
		"desc_en": "Fast fan of blades.",
		"max_bonus": "Chuva de Facas: mais laminas por rajada.",
		"max_bonus_en": "Knife Rain: more blades per burst.",
		"cooldown": 0.92,
		"icon": "knife"
	},
	"rifle": {
		"name": "Rifle",
		"name_en": "Rifle",
		"desc": "Tiro forte, rapido e perfurante.",
		"desc_en": "Strong, fast, piercing shot.",
		"max_bonus": "Mira Longa: atravessa quase tudo.",
		"max_bonus_en": "Long Sight: pierces almost everything.",
		"cooldown": 1.48,
		"icon": "rifle"
	},
	"fire_bottle": {
		"name": "Garrafa de Fogo",
		"name_en": "Fire Bottle",
		"desc": "Arremesso em area contra multidoes.",
		"desc_en": "Area throw against crowds.",
		"max_bonus": "Fogo Selvagem: area maior e dano alto.",
		"max_bonus_en": "Wild Fire: larger area and high damage.",
		"cooldown": 1.95,
		"icon": "fire_bottle"
	},
	"horseshoe": {
		"name": "Ferraduras",
		"name_en": "Horseshoes",
		"desc": "Disparos em volta do personagem.",
		"desc_en": "Shots all around the character.",
		"max_bonus": "Sorte de Prata: muito mais ricochetes.",
		"max_bonus_en": "Silver Luck: many more ricochets.",
		"cooldown": 1.18,
		"icon": "horseshoe"
	},
	"golden_revolver": {
		"name": "Revolver Dourado",
		"name_en": "Golden Revolver",
		"desc": "Arma secreta com tiros duplos velozes.",
		"desc_en": "Secret weapon with fast double shots.",
		"max_bonus": "Dourado Vivo: rajadas quase continuas.",
		"max_bonus_en": "Living Gold: nearly continuous bursts.",
		"cooldown": 0.48,
		"secret": true,
		"icon": "golden_revolver"
	},
	"coach_gun": {
		"name": "Escopeta de Carruagem",
		"name_en": "Coach Gun",
		"desc": "Arma secreta com cones largos.",
		"desc_en": "Secret weapon with wide cones.",
		"max_bonus": "Porta de Saloons: cone devastador.",
		"max_bonus_en": "Saloon Doors: devastating cone.",
		"cooldown": 1.05,
		"secret": true,
		"icon": "coach_gun"
	},
	"rail_spike": {
		"name": "Lanca-Trilhos",
		"name_en": "Rail Spike",
		"desc": "Arma secreta que atravessa fileiras.",
		"desc_en": "Secret weapon that crosses whole lines.",
		"max_bonus": "Trilho Infinito: perfuracao absurda.",
		"max_bonus_en": "Endless Rail: absurd penetration.",
		"cooldown": 1.24,
		"secret": true,
		"icon": "rail_spike"
	},
	"ghost_lantern": {
		"name": "Lampiao Fantasma",
		"name_en": "Ghost Lantern",
		"desc": "Arma secreta com pulsos espirituais.",
		"desc_en": "Secret weapon with spectral pulses.",
		"max_bonus": "Procissao: aneis de dano ao redor.",
		"max_bonus_en": "Procession: rings of damage around you.",
		"cooldown": 1.45,
		"secret": true,
		"icon": "ghost_lantern"
	}
}

var unlock_rules = {
	"ghost_town:revolver": {
		"weapon": "golden_revolver",
		"text": "Revolver Dourado liberado por dominar o Revolver na Cidade Fantasma.",
		"text_en": "Golden Revolver unlocked by mastering the Revolver in Ghost Town."
	},
	"broken_fort:shotgun": {
		"weapon": "coach_gun",
		"text": "Escopeta de Carruagem liberada por dominar a Espingarda no Forte Quebrado.",
		"text_en": "Coach Gun unlocked by mastering the Shotgun in Broken Fort."
	},
	"canyon:rifle": {
		"weapon": "rail_spike",
		"text": "Lanca-Trilhos liberado por dominar o Rifle no Canyon Vermelho.",
		"text_en": "Rail Spike unlocked by mastering the Rifle in Red Canyon."
	},
	"mine:fire_bottle": {
		"weapon": "ghost_lantern",
		"text": "Lampiao Fantasma liberado por dominar a Garrafa de Fogo na Mina Abandonada.",
		"text_en": "Ghost Lantern unlocked by mastering the Fire Bottle in Abandoned Mine."
	}
}

var stat_upgrades = [
	{
		"type": "buff",
		"id": "spurs",
		"title": "Esporas de Ferro",
		"title_en": "Iron Spurs",
		"desc": "+14 de velocidade por nivel.",
		"desc_en": "+14 movement speed per level.",
		"max_bonus": "Galope Fantasma: +48 velocidade extra e 12% menos recarga.",
		"max_bonus_en": "Ghost Gallop: +48 extra speed and 12% lower cooldowns.",
		"icon": "spurs"
	},
	{
		"type": "buff",
		"id": "star",
		"title": "Estrela de Lata",
		"title_en": "Tin Star",
		"desc": "+16 de vida maxima por nivel.",
		"desc_en": "+16 max health per level.",
		"max_bonus": "Estrela de Aco: +80 vida maxima extra, cura grande e 18% menos dano recebido.",
		"max_bonus_en": "Steel Star: +80 extra max health, a large heal, and 18% less damage taken.",
		"icon": "star"
	},
	{
		"type": "buff",
		"id": "magnet",
		"title": "Bolsa de Garimpo",
		"title_en": "Prospector Bag",
		"desc": "+32 de alcance para coletar XP por nivel.",
		"desc_en": "+32 XP pickup range per level.",
		"max_bonus": "Ima de Mina: +160 alcance extra e +20% de XP coletada.",
		"max_bonus_en": "Mine Magnet: +160 extra range and +20% XP gained.",
		"icon": "magnet"
	},
	{
		"type": "buff",
		"id": "coffee",
		"title": "Cafe Forte",
		"title_en": "Strong Coffee",
		"desc": "Cura 16 e concede +8 de velocidade por nivel.",
		"desc_en": "Heals 16 and grants +8 speed per level.",
		"max_bonus": "Cafe da Madrugada: cura forte, +32 velocidade extra e regeneracao passiva.",
		"max_bonus_en": "Midnight Coffee: strong heal, +32 extra speed, and passive regeneration.",
		"icon": "coffee"
	}
]

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
	_load_progress()
	_apply_settings(progress.get("settings", {}))
	if is_instance_valid(music):
		music.configure("menu")
	hud.set_stats(player.health, player.max_health, xp, xp_required, level, kills, game_time)
	hud.set_run_context(_t("select_stage"), _t("select_character"))
	hud.set_weapons([])
	hud.set_settings(progress.get("settings", {}))
	hud.show_start_menu(characters, stages, progress, _start_run)

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
	music.configure(selected_stage.get("id", "ghost_town"))
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
	if not _player_alive(shooter):
		return

	firing_weapon_context = weapon_id
	match weapon_id:
		"revolver":
			_fire_revolver(weapon_id, shooter, Color("#ffe7a0"), 0)
		"shotgun":
			_fire_shotgun(weapon_id, shooter, 0)
		"dynamite":
			_fire_explosive(weapon_id, shooter, "dynamite")
		"lasso":
			_fire_lasso(weapon_id, shooter)
		"knife":
			_fire_knife(weapon_id, shooter)
		"rifle":
			_fire_rifle(weapon_id, shooter, Color("#d8e4ff"), "rail")
		"fire_bottle":
			_fire_explosive(weapon_id, shooter, "fire")
		"horseshoe":
			_fire_horseshoe(weapon_id, shooter)
		"golden_revolver":
			_fire_revolver(weapon_id, shooter, Color("#ffd55d"), 2)
		"coach_gun":
			_fire_shotgun(weapon_id, shooter, 3)
		"rail_spike":
			_fire_rifle(weapon_id, shooter, Color("#b9f0ff"), "rail_spike")
		"ghost_lantern":
			_fire_ghost_lantern(weapon_id, shooter)
	firing_weapon_context = ""

func _fire_revolver(weapon_id, shooter, color, bonus_shots):
	var base_direction = _weapon_direction(weapon_id, shooter)
	if base_direction == Vector2.ZERO:
		return

	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	var shots = 1 + int((level_value - 1) / 2) + bonus_shots
	if evolved:
		shots += 2

	var damage = _scaled_damage(7 + level_value * 3 + bonus_shots * 2, shooter)
	var pierce = 1 + int(level_value >= 4) + int(evolved) * 2
	var spread = 0.08 if shots > 1 else 0.0

	for i in range(shots):
		var offset = (float(i) - float(shots - 1) / 2.0) * spread
		_fire_projectile(shooter, base_direction.rotated(offset), damage, 1120.0 + level_value * 35.0, pierce, 1.42, {
			"hit_radius": 6.0,
			"visual": "bullet",
			"color": color,
			"line_length": 22.0
		})

func _fire_shotgun(weapon_id, shooter, bonus_pellets):
	var base_direction = _weapon_direction(weapon_id, shooter)
	if base_direction == Vector2.ZERO:
		return

	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	var pellets = 4 + level_value + bonus_pellets
	if evolved:
		pellets += 3

	var damage = _scaled_damage(4 + level_value * 2 + bonus_pellets, shooter)
	var spread = 0.56 + level_value * 0.025
	var pierce = 1 + int(evolved)

	for i in range(pellets):
		var t = 0.0
		if pellets > 1:
			t = float(i) / float(pellets - 1) - 0.5
		_fire_projectile(shooter, base_direction.rotated(t * spread), damage, 930.0, pierce, 0.68, {
			"hit_radius": 5.5,
			"visual": "bullet",
			"color": Color("#f2d799"),
			"line_length": 14.0
		})

func _fire_explosive(weapon_id, shooter, visual):
	var direction = _weapon_direction(weapon_id, shooter)
	if direction == Vector2.ZERO:
		return

	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	var is_fire = visual == "fire"
	var radius = 46.0 + level_value * 10.0
	var damage = _scaled_damage(8 + level_value * 4, shooter)
	var speed = 520.0 + level_value * 34.0
	var lifetime = 0.82
	if is_fire:
		radius += 12.0
		damage = _scaled_damage(6 + level_value * 3, shooter)
		lifetime = 0.72
	if evolved:
		radius += 36.0
		damage += _scaled_damage(8, shooter)

	_fire_projectile(shooter, direction, damage, speed, 1, lifetime, {
		"hit_radius": 9.0,
		"visual": visual,
		"color": Color("#f15d32") if is_fire else Color("#3a2518"),
		"explode_radius": radius,
		"explode_on_hit": true,
		"explode_on_expire": true
	})

	if evolved and not is_fire:
		for i in range(6):
			_fire_projectile(shooter, Vector2.RIGHT.rotated(float(i) / 6.0 * TAU), _scaled_damage(5 + level_value, shooter), 820.0, 1, 0.46, {
				"hit_radius": 4.0,
				"visual": "shard",
				"color": Color("#efc16f"),
				"line_length": 12.0
			})

func _fire_lasso(weapon_id, shooter):
	var direction = _weapon_direction(weapon_id, shooter)
	if direction == Vector2.ZERO:
		return

	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	_fire_projectile(shooter, direction, _scaled_damage(4 + level_value * 2, shooter), 690.0 + level_value * 24.0, 7 + level_value * 2 + int(evolved) * 8, 0.84 + level_value * 0.045, {
		"hit_radius": 15.0 + level_value * 1.6 + int(evolved) * 9.0,
		"visual": "lasso",
		"color": Color("#d2a257"),
		"line_length": 34.0 + level_value * 3.0,
		"spin": 7.0
	})

func _fire_knife(weapon_id, shooter):
	var base_direction = _weapon_direction(weapon_id, shooter)
	if base_direction == Vector2.ZERO:
		return

	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	var knives = 2 + level_value + int(evolved) * 4
	var spread = 0.34 + level_value * 0.035

	for i in range(knives):
		var t = 0.0
		if knives > 1:
			t = float(i) / float(knives - 1) - 0.5
		_fire_projectile(shooter, base_direction.rotated(t * spread), _scaled_damage(5 + level_value * 2, shooter), 1260.0, 1 + int(level_value >= 4) + int(evolved), 0.82, {
			"hit_radius": 5.0,
			"visual": "knife",
			"color": Color("#d9e0e2"),
			"line_length": 20.0
		})

func _fire_rifle(weapon_id, shooter, color, visual):
	var direction = _weapon_direction(weapon_id, shooter)
	if direction == Vector2.ZERO:
		return

	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	var secret_bonus = 5 if weapon_id == "rail_spike" else 0
	_fire_projectile(shooter, direction, _scaled_damage(15 + level_value * 6 + secret_bonus, shooter), 1480.0, 3 + level_value + int(evolved) * 7, 1.06, {
		"hit_radius": 7.0 + int(evolved) * 2.0,
		"visual": visual,
		"color": color,
		"line_length": 34.0 + level_value * 2.0
	})

func _fire_horseshoe(weapon_id, shooter):
	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	var shoes = 2 + level_value + int(evolved) * 4
	var start_angle = rng.randf_range(0.0, TAU)

	for i in range(shoes):
		var direction = Vector2.RIGHT.rotated(start_angle + float(i) / float(shoes) * TAU)
		_fire_projectile(shooter, direction, _scaled_damage(5 + level_value * 2, shooter), 860.0 + level_value * 30.0, 2 + int(evolved) * 4, 0.92, {
			"hit_radius": 7.5,
			"visual": "horseshoe",
			"color": Color("#bfc4c2"),
			"line_length": 18.0,
			"spin": 12.0
		})

func _fire_ghost_lantern(weapon_id, shooter):
	var level_value = _weapon_level(weapon_id)
	var evolved = _is_evolved(weapon_id)
	var pulses = 4 + level_value + int(evolved) * 4
	if _is_synergy_weapon(weapon_id, shooter):
		pulses += 2
	var radius = 22.0 + level_value * 2.0 + int(evolved) * 7.0
	var start_angle = rng.randf_range(0.0, TAU)

	for i in range(pulses):
		var direction = Vector2.RIGHT.rotated(start_angle + float(i) / float(pulses) * TAU)
		_fire_projectile(shooter, direction, _scaled_damage(7 + level_value * 3, shooter), 390.0 + level_value * 26.0, 99, 0.52 + level_value * 0.045, {
			"hit_radius": radius,
			"visual": "lantern",
			"color": Color("#9be8d4"),
			"line_length": 16.0,
			"spin": 2.8
		})

	if evolved:
		_fire_projectile(shooter, Vector2.ZERO, _scaled_damage(18 + level_value * 3, shooter), 0.0, 999, 0.22, {
			"hit_radius": 90.0,
			"visual": "lantern",
			"color": Color("#c9fff0"),
			"line_length": 8.0
		})

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
	var best = null
	var best_distance = INF

	for enemy in enemies.get_children():
		if not is_instance_valid(enemy):
			continue
		var distance = source_position.distance_squared_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy

	return best

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

	if is_instance_valid(music):
		music.set_music_volume(music_volume)
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
