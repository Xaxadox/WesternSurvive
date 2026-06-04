extends RefCounted

static var CHARACTER_DATA = [
	{
		"id": "gunslinger",
		"name": "Pistoleiro",
		"name_en": "Gunslinger",
		"desc": "Magnum .44: tambor de 6 balas, tiros fortes e recarga acelerada por abates.",
		"desc_en": "Magnum .44: 6-round cylinder, strong shots, and kills speed up reloads.",
		"starter_weapon": "revolver",
		"synergy_weapon": "golden_revolver",
		"synergy_desc": "Sinergia: Revolver Dourado ganha mais balas e recarga ainda mais curta.",
		"synergy_desc_en": "Synergy: Golden Revolver gains more rounds and an even shorter reload.",
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
		"silhouette": "gunslinger",
		"sprite": "res://assets/characters/frames/gunslinger/idle_down_0.png",
		"sprite_weapon_overlay": true,
		"menu_icon": "res://assets/menu/characters/gunslinger.png",
		"sprite_height": 72.0,
		"sprite_offset": Vector2(0, -10),
		"walk_sprites": [
			"res://assets/characters/frames/gunslinger/walk_side_0.png",
			"res://assets/characters/frames/gunslinger/walk_side_1.png",
			"res://assets/characters/frames/gunslinger/walk_side_2.png",
			"res://assets/characters/frames/gunslinger/walk_side_3.png"
		],
		"animations": {
			"idle_down": [
				"res://assets/characters/frames/gunslinger/idle_down_0.png"
			],
			"walk_down": [
				"res://assets/characters/frames/gunslinger/walk_down_0.png",
				"res://assets/characters/frames/gunslinger/walk_down_1.png",
				"res://assets/characters/frames/gunslinger/walk_down_2.png"
			],
			"idle_up": [
				"res://assets/characters/frames/gunslinger/idle_up_0.png"
			],
			"walk_up": [
				"res://assets/characters/frames/gunslinger/walk_up_0.png",
				"res://assets/characters/frames/gunslinger/walk_up_1.png"
			],
			"idle_side": [
				"res://assets/characters/frames/gunslinger/idle_side_0.png"
			],
			"walk_side": [
				"res://assets/characters/frames/gunslinger/walk_side_0.png",
				"res://assets/characters/frames/gunslinger/walk_side_1.png",
				"res://assets/characters/frames/gunslinger/walk_side_2.png",
				"res://assets/characters/frames/gunslinger/walk_side_3.png"
			]
		},
		"sprite_walk_cycle_seconds": 0.82
	},
	{
		"id": "sheriff",
		"name": "Xerife",
		"name_en": "Sheriff",
		"desc": "Espingarda de dois disparos; cada tiro espalha varios projeteis e aplica lentidao.",
		"desc_en": "Two-shot shotgun; each shot spreads several projectiles and slows targets.",
		"starter_weapon": "shotgun",
		"synergy_weapon": "coach_gun",
		"synergy_desc": "Sinergia: Escopeta de Carruagem dispara com cadencia melhor.",
		"synergy_desc_en": "Synergy: Coach Gun fires with better cadence.",
		"health": 120,
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
		"silhouette": "sheriff",
		"sprite": "res://assets/characters/frames/sheriff/idle_down_0.png",
		"menu_icon": "res://assets/menu/characters/sheriff.png",
		"sprite_height": 72.0,
		"sprite_offset": Vector2(0, -10),
		"walk_sprites": [
			"res://assets/characters/frames/sheriff/walk_side_0.png",
			"res://assets/characters/frames/sheriff/walk_side_1.png",
			"res://assets/characters/frames/sheriff/walk_side_2.png",
			"res://assets/characters/frames/sheriff/walk_side_3.png",
			"res://assets/characters/frames/sheriff/walk_side_4.png",
			"res://assets/characters/frames/sheriff/walk_side_5.png",
			"res://assets/characters/frames/sheriff/walk_side_6.png",
			"res://assets/characters/frames/sheriff/walk_side_7.png",
			"res://assets/characters/frames/sheriff/walk_side_8.png",
			"res://assets/characters/frames/sheriff/walk_side_9.png",
			"res://assets/characters/frames/sheriff/walk_side_10.png",
			"res://assets/characters/frames/sheriff/walk_side_11.png",
			"res://assets/characters/frames/sheriff/walk_side_12.png",
			"res://assets/characters/frames/sheriff/walk_side_13.png",
			"res://assets/characters/frames/sheriff/walk_side_14.png",
			"res://assets/characters/frames/sheriff/walk_side_15.png",
			"res://assets/characters/frames/sheriff/walk_side_16.png",
			"res://assets/characters/frames/sheriff/walk_side_17.png",
			"res://assets/characters/frames/sheriff/walk_side_18.png",
			"res://assets/characters/frames/sheriff/walk_side_19.png",
			"res://assets/characters/frames/sheriff/walk_side_20.png"
		],
		"animations": {
			"idle_down": [
				"res://assets/characters/frames/sheriff/idle_down_0.png"
			],
			"walk_down": [
				"res://assets/characters/frames/sheriff/walk_down_0.png",
				"res://assets/characters/frames/sheriff/walk_down_1.png",
				"res://assets/characters/frames/sheriff/walk_down_2.png",
				"res://assets/characters/frames/sheriff/walk_down_3.png",
				"res://assets/characters/frames/sheriff/walk_down_4.png",
				"res://assets/characters/frames/sheriff/walk_down_5.png",
				"res://assets/characters/frames/sheriff/walk_down_6.png",
				"res://assets/characters/frames/sheriff/walk_down_7.png",
				"res://assets/characters/frames/sheriff/walk_down_8.png",
				"res://assets/characters/frames/sheriff/walk_down_9.png",
				"res://assets/characters/frames/sheriff/walk_down_10.png",
				"res://assets/characters/frames/sheriff/walk_down_11.png"
			],
			"idle_up": [
				"res://assets/characters/frames/sheriff/idle_up_0.png"
			],
			"walk_up": [
				"res://assets/characters/frames/sheriff/walk_up_0.png",
				"res://assets/characters/frames/sheriff/walk_up_1.png",
				"res://assets/characters/frames/sheriff/walk_up_2.png",
				"res://assets/characters/frames/sheriff/walk_up_3.png",
				"res://assets/characters/frames/sheriff/walk_up_4.png",
				"res://assets/characters/frames/sheriff/walk_up_5.png",
				"res://assets/characters/frames/sheriff/walk_up_6.png",
				"res://assets/characters/frames/sheriff/walk_up_7.png",
				"res://assets/characters/frames/sheriff/walk_up_8.png"
			],
			"idle_side": [
				"res://assets/characters/frames/sheriff/idle_side_0.png"
			],
			"walk_side": [
				"res://assets/characters/frames/sheriff/walk_side_0.png",
				"res://assets/characters/frames/sheriff/walk_side_1.png",
				"res://assets/characters/frames/sheriff/walk_side_2.png",
				"res://assets/characters/frames/sheriff/walk_side_3.png",
				"res://assets/characters/frames/sheriff/walk_side_4.png",
				"res://assets/characters/frames/sheriff/walk_side_5.png",
				"res://assets/characters/frames/sheriff/walk_side_6.png",
				"res://assets/characters/frames/sheriff/walk_side_7.png",
				"res://assets/characters/frames/sheriff/walk_side_8.png",
				"res://assets/characters/frames/sheriff/walk_side_9.png",
				"res://assets/characters/frames/sheriff/walk_side_10.png",
				"res://assets/characters/frames/sheriff/walk_side_11.png",
				"res://assets/characters/frames/sheriff/walk_side_12.png",
				"res://assets/characters/frames/sheriff/walk_side_13.png",
				"res://assets/characters/frames/sheriff/walk_side_14.png",
				"res://assets/characters/frames/sheriff/walk_side_15.png",
				"res://assets/characters/frames/sheriff/walk_side_16.png",
				"res://assets/characters/frames/sheriff/walk_side_17.png",
				"res://assets/characters/frames/sheriff/walk_side_18.png",
				"res://assets/characters/frames/sheriff/walk_side_19.png",
				"res://assets/characters/frames/sheriff/walk_side_20.png"
			]
		},
		"sprite_walk_cycle_seconds": 0.82
	},
	{
		"id": "bounty_hunter",
		"name": "Cacadora",
		"name_en": "Bounty Hunter",
		"desc": "Pouca vida, muita velocidade e rifle com critico em longa distancia.",
		"desc_en": "Low health, high speed, and a rifle that crits at long range.",
		"starter_weapon": "rifle",
		"synergy_weapon": "rail_spike",
		"synergy_desc": "Sinergia: Lanca-Trilhos ganha dano extra.",
		"synergy_desc_en": "Synergy: Rail Spike gains extra damage.",
		"health": 72,
		"speed": 292.0,
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
		"silhouette": "hunter",
		"sprite": "res://assets/characters/frames/bounty_hunter/idle_down_0.png",
		"menu_icon": "res://assets/menu/characters/bounty_hunter.png",
		"sprite_height": 68.0,
		"sprite_offset": Vector2(0, -8),
		"walk_sprites": [
			"res://assets/characters/frames/bounty_hunter/walk_side_0.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_1.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_2.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_3.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_4.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_5.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_6.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_7.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_8.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_9.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_10.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_11.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_12.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_13.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_14.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_15.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_16.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_17.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_18.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_19.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_20.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_21.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_22.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_23.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_24.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_25.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_26.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_27.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_28.png",
			"res://assets/characters/frames/bounty_hunter/walk_side_29.png"
		],
		"animations": {
			"idle_down": [
				"res://assets/characters/frames/bounty_hunter/idle_down_0.png"
			],
			"walk_down": [
				"res://assets/characters/frames/bounty_hunter/walk_down_0.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_1.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_2.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_3.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_4.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_5.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_6.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_7.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_8.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_9.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_10.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_11.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_12.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_13.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_14.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_15.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_16.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_17.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_18.png",
				"res://assets/characters/frames/bounty_hunter/walk_down_19.png"
			],
			"idle_up": [
				"res://assets/characters/frames/bounty_hunter/idle_up_0.png"
			],
			"walk_up": [
				"res://assets/characters/frames/bounty_hunter/walk_up_0.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_1.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_2.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_3.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_4.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_5.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_6.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_7.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_8.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_9.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_10.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_11.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_12.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_13.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_14.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_15.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_16.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_17.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_18.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_19.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_20.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_21.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_22.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_23.png",
				"res://assets/characters/frames/bounty_hunter/walk_up_24.png"
			],
			"idle_side": [
				"res://assets/characters/frames/bounty_hunter/idle_side_0.png"
			],
			"walk_side": [
				"res://assets/characters/frames/bounty_hunter/walk_side_0.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_1.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_2.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_3.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_4.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_5.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_6.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_7.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_8.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_9.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_10.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_11.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_12.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_13.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_14.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_15.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_16.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_17.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_18.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_19.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_20.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_21.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_22.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_23.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_24.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_25.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_26.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_27.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_28.png",
				"res://assets/characters/frames/bounty_hunter/walk_side_29.png"
			]
		},
		"sprite_walk_cycle_seconds": 0.82
	},
	{
		"id": "shaman",
		"name": "Curandeiro",
		"name_en": "Healer",
		"desc": "Mais vida do grupo, molotov em area e imune a fogo e bombas.",
		"desc_en": "Highest health in the group, area molotov, and immune to fire and bombs.",
		"starter_weapon": "fire_bottle",
		"synergy_weapon": "ghost_lantern",
		"synergy_desc": "Sinergia: Lampiao Fantasma pulsa mais vezes.",
		"synergy_desc_en": "Synergy: Ghost Lantern pulses more times.",
		"health": 142,
		"speed": 216.0,
		"pickup": 150.0,
		"damage_mult": 0.94,
		"cooldown_mult": 0.92,
		"damage_immunities": ["fire", "bomb"],
		"coat": Color("#2f6f73"),
		"hat": Color("#203034"),
		"scarf": Color("#9be8d4"),
		"skin": Color("#d7a06f"),
		"outline": Color("#9be8d4"),
		"badge": Color("#9be8d4"),
		"visual_weapon": "lantern",
		"silhouette": "healer",
		"sprite": "res://assets/characters/frames/shaman/idle_down_0.png",
		"menu_icon": "res://assets/menu/characters/shaman.png",
		"sprite_height": 68.0,
		"sprite_offset": Vector2(0, -10),
		"walk_sprites": [
			"res://assets/characters/frames/shaman/walk_side_0.png",
			"res://assets/characters/frames/shaman/walk_side_1.png",
			"res://assets/characters/frames/shaman/walk_side_2.png",
			"res://assets/characters/frames/shaman/walk_side_3.png",
			"res://assets/characters/frames/shaman/walk_side_4.png",
			"res://assets/characters/frames/shaman/walk_side_5.png",
			"res://assets/characters/frames/shaman/walk_side_6.png",
			"res://assets/characters/frames/shaman/walk_side_7.png",
			"res://assets/characters/frames/shaman/walk_side_8.png",
			"res://assets/characters/frames/shaman/walk_side_9.png",
			"res://assets/characters/frames/shaman/walk_side_10.png",
			"res://assets/characters/frames/shaman/walk_side_11.png",
			"res://assets/characters/frames/shaman/walk_side_12.png",
			"res://assets/characters/frames/shaman/walk_side_13.png",
			"res://assets/characters/frames/shaman/walk_side_14.png",
			"res://assets/characters/frames/shaman/walk_side_15.png",
			"res://assets/characters/frames/shaman/walk_side_16.png",
			"res://assets/characters/frames/shaman/walk_side_17.png",
			"res://assets/characters/frames/shaman/walk_side_18.png",
			"res://assets/characters/frames/shaman/walk_side_19.png",
			"res://assets/characters/frames/shaman/walk_side_20.png"
		],
		"animations": {
			"idle_down": [
				"res://assets/characters/frames/shaman/idle_down_0.png"
			],
			"walk_down": [
				"res://assets/characters/frames/shaman/walk_down_0.png",
				"res://assets/characters/frames/shaman/walk_down_1.png",
				"res://assets/characters/frames/shaman/walk_down_2.png"
			],
			"idle_up": [
				"res://assets/characters/frames/shaman/idle_up_0.png"
			],
			"walk_up": [
				"res://assets/characters/frames/shaman/walk_up_0.png",
				"res://assets/characters/frames/shaman/walk_up_1.png",
				"res://assets/characters/frames/shaman/walk_up_2.png",
				"res://assets/characters/frames/shaman/walk_up_3.png",
				"res://assets/characters/frames/shaman/walk_up_4.png",
				"res://assets/characters/frames/shaman/walk_up_5.png"
			],
			"idle_side": [
				"res://assets/characters/frames/shaman/idle_side_0.png"
			],
			"walk_side": [
				"res://assets/characters/frames/shaman/walk_side_0.png",
				"res://assets/characters/frames/shaman/walk_side_1.png",
				"res://assets/characters/frames/shaman/walk_side_2.png",
				"res://assets/characters/frames/shaman/walk_side_3.png",
				"res://assets/characters/frames/shaman/walk_side_4.png",
				"res://assets/characters/frames/shaman/walk_side_5.png",
				"res://assets/characters/frames/shaman/walk_side_6.png",
				"res://assets/characters/frames/shaman/walk_side_7.png",
				"res://assets/characters/frames/shaman/walk_side_8.png",
				"res://assets/characters/frames/shaman/walk_side_9.png",
				"res://assets/characters/frames/shaman/walk_side_10.png",
				"res://assets/characters/frames/shaman/walk_side_11.png",
				"res://assets/characters/frames/shaman/walk_side_12.png",
				"res://assets/characters/frames/shaman/walk_side_13.png",
				"res://assets/characters/frames/shaman/walk_side_14.png",
				"res://assets/characters/frames/shaman/walk_side_15.png",
				"res://assets/characters/frames/shaman/walk_side_16.png",
				"res://assets/characters/frames/shaman/walk_side_17.png",
				"res://assets/characters/frames/shaman/walk_side_18.png",
				"res://assets/characters/frames/shaman/walk_side_19.png",
				"res://assets/characters/frames/shaman/walk_side_20.png"
			]
		},
		"sprite_walk_cycle_seconds": 0.82
	}
]

static var STAGE_DATA = [
	{
		"id": "ghost_town",
		"name": "Cidade Fantasma",
		"name_en": "Ghost Town",
		"desc": "Ruas abertas, gangues em quantidade.",
		"desc_en": "Open streets with large gangs.",
		"floor": Color("#c99052"),
		"grid": Color(0.55, 0.31, 0.15, 0.14),
		"accent": Color("#7a4a27"),
		"icon": "res://assets/menu/stages/ghost_town.png",
		"props": {
			"cactus": "res://assets/stages/props/ghost_town/cactus.png",
			"boulder": "res://assets/stages/props/ghost_town/boulder.png",
			"scrub": "res://assets/stages/props/ghost_town/scrub.png",
			"fence": "res://assets/stages/props/ghost_town/fence.png"
		},
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
		"icon": "res://assets/menu/stages/canyon.png",
		"props": {
			"spire": "res://assets/stages/props/canyon/spire.png",
			"boulder": "res://assets/stages/props/canyon/boulder.png",
			"scrub": "res://assets/stages/props/canyon/scrub.png"
		},
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
		"icon": "res://assets/menu/stages/broken_fort.png",
		"props": {
			"wall": "res://assets/stages/props/broken_fort/wall.png",
			"crate": "res://assets/stages/props/broken_fort/crate.png",
			"planks": "res://assets/stages/props/broken_fort/planks.png",
			"scrub": "res://assets/stages/props/broken_fort/scrub.png"
		},
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
		"icon": "res://assets/menu/stages/mine.png",
		"props": {
			"rail": "res://assets/stages/props/mine/rail.png",
			"rock": "res://assets/stages/props/mine/rock.png",
			"lantern": "res://assets/stages/props/mine/lantern.png"
		},
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
		"icon": "res://assets/menu/stages/bonus.png",
		"props": {
			"rail": "res://assets/stages/props/bonus/rail.png",
			"rock": "res://assets/stages/props/bonus/rock.png",
			"lantern": "res://assets/stages/props/bonus/lantern.png"
		},
		"enemy_health": 1.42,
		"enemy_speed": 1.18,
		"spawn_mult": 1.22,
		"initial_enemies": 18,
		"food_mult": 0.95,
		"bomb_mult": 1.45,
		"bonus": true
	}
]

static var WEAPON_DATA = {
	"revolver": {
		"name": "Magnum .44",
		"name_en": "Magnum .44",
		"desc": "Tambor de 6 balas com alto dano por disparo; perde forca em longo alcance.",
		"desc_en": "6-round cylinder with high damage per shot; loses power at long range.",
		"max_bonus": "Tiro de Elite: mais dano e penetracao.",
		"max_bonus_en": "Elite Shot: more damage and penetration.",
		"cooldown": 1.62,
		"icon": "revolver"
	},
	"shotgun": {
		"name": "Espingarda",
		"name_en": "Shotgun",
		"desc": "Dois disparos antes da recarga; cada disparo abre varios chumbos.",
		"desc_en": "Two shots before reloading; each shot spreads several pellets.",
		"max_bonus": "Cano Serrado: mais chumbos no cone curto.",
		"max_bonus_en": "Sawed Barrel: more pellets in the short cone.",
		"cooldown": 1.48,
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
		"desc": "Dano estavel em qualquer alcance, com critico a distancia.",
		"desc_en": "Stable damage at any range, with long-range crits.",
		"max_bonus": "Mira Longa: mais chance de critico e penetracao.",
		"max_bonus_en": "Long Sight: more crit chance and penetration.",
		"cooldown": 1.48,
		"icon": "rifle"
	},
	"fire_bottle": {
		"name": "Coquetel Molotov",
		"name_en": "Molotov Cocktail",
		"desc": "Cria uma area em chamas que causa dano continuo.",
		"desc_en": "Creates a burning area that deals damage over time.",
		"max_bonus": "Fogo Selvagem: area maior, mais duracao e dano continuo.",
		"max_bonus_en": "Wild Fire: larger area, longer duration, and stronger damage over time.",
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
		"name": "Magnum Dourada",
		"name_en": "Golden Revolver",
		"desc": "Arma secreta com tambor maior e rajada pesada.",
		"desc_en": "Secret weapon with a larger cylinder and heavy bursts.",
		"max_bonus": "Dourado Vivo: mais balas e recarga agressiva.",
		"max_bonus_en": "Living Gold: more rounds and aggressive reloads.",
		"cooldown": 1.28,
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

static var UNLOCK_RULE_DATA = {
	"ghost_town:revolver": {
		"weapon": "golden_revolver",
		"text": "Magnum Dourada liberada por dominar a Magnum .44 na Cidade Fantasma.",
		"text_en": "Golden Magnum unlocked by mastering the Magnum .44 in Ghost Town."
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

static var STAT_UPGRADE_DATA = [
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

static func characters():
	return CHARACTER_DATA.duplicate(true)

static func stages():
	return STAGE_DATA.duplicate(true)

static func weapons():
	return WEAPON_DATA.duplicate(true)

static func unlock_rules():
	return UNLOCK_RULE_DATA.duplicate(true)

static func stat_upgrades():
	return STAT_UPGRADE_DATA.duplicate(true)
