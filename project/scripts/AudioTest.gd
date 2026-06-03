extends Control

const CodeMusic = preload("res://scripts/CodeMusic.gd")
const StageAmbience = preload("res://scripts/StageAmbience.gd")
const WeaponSfx = preload("res://scripts/WeaponSfx.gd")
const StingerSfx = preload("res://scripts/StingerSfx.gd")
const CombatSfx = preload("res://scripts/CombatSfx.gd")

const STAGES = [
	"menu",
	"ghost_town",
	"canyon",
	"broken_fort",
	"mine",
	"bonus"
]

const WEAPONS = [
	"revolver",
	"golden_revolver",
	"shotgun",
	"coach_gun",
	"rifle",
	"rail_spike",
	"dynamite",
	"fire_bottle",
	"lasso",
	"knife",
	"horseshoe",
	"ghost_lantern"
]

const STINGERS = [
	"stage_start",
	"level_up",
	"upgrade_select",
	"unlock",
	"bonus_unlock",
	"player_down",
	"game_over"
]

const COMBAT_EFFECTS = [
	"enemy_hit",
	"enemy_down",
	"player_damage",
	"xp_pickup",
	"heal_pickup",
	"explosion"
]

var music = null
var ambience = null
var weapon_sfx = null
var stinger_sfx = null
var combat_sfx = null
var stage_option: OptionButton = null
var intensity_slider: HSlider = null
var volume_slider: HSlider = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		return

	_build_audio_nodes()
	_build_ui()
	_apply_stage()
	_apply_volume()
	_apply_intensity()

func _build_audio_nodes():
	music = CodeMusic.new()
	music.name = "CodeMusic"
	add_child(music)

	ambience = StageAmbience.new()
	ambience.name = "StageAmbience"
	add_child(ambience)

	weapon_sfx = WeaponSfx.new()
	weapon_sfx.name = "WeaponSfx"
	add_child(weapon_sfx)

	stinger_sfx = StingerSfx.new()
	stinger_sfx.name = "StingerSfx"
	add_child(stinger_sfx)

	combat_sfx = CombatSfx.new()
	combat_sfx.name = "CombatSfx"
	add_child(combat_sfx)

func _build_ui():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 14)
	root.offset_left = 28
	root.offset_top = 24
	root.offset_right = -28
	root.offset_bottom = -24
	add_child(root)

	var title = Label.new()
	title.text = "Audio Test"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	var controls = HBoxContainer.new()
	controls.add_theme_constant_override("separation", 16)
	root.add_child(controls)

	stage_option = OptionButton.new()
	for stage_id in STAGES:
		stage_option.add_item(stage_id)
	stage_option.item_selected.connect(func(_index): _apply_stage())
	controls.add_child(stage_option)

	volume_slider = _add_slider(controls, "Music", 0.0, 1.0, 0.55)
	volume_slider.value_changed.connect(func(_value): _apply_volume())

	intensity_slider = _add_slider(controls, "Intensity", 0.0, 1.0, 0.25)
	intensity_slider.value_changed.connect(func(_value): _apply_intensity())

	var grid = GridContainer.new()
	grid.columns = 4
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	root.add_child(grid)

	_add_section(grid, "Weapons", WEAPONS, func(id): weapon_sfx.play_weapon(id))
	_add_section(grid, "Stingers", STINGERS, func(id): stinger_sfx.play_stinger(id))
	_add_section(grid, "Combat", COMBAT_EFFECTS, func(id): combat_sfx.play_effect(id))

	var footer = Label.new()
	footer.text = "Scene path: res://scenes/audio_test.tscn"
	footer.add_theme_font_size_override("font_size", 13)
	root.add_child(footer)

func _add_slider(parent, label_text, minimum, maximum, initial_value):
	var box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(180, 0)
	parent.add_child(box)

	var label = Label.new()
	label.text = label_text
	box.add_child(label)

	var slider = HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = 0.01
	slider.value = initial_value
	box.add_child(slider)
	return slider

func _add_section(parent, title_text, ids, callback):
	var box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(230, 0)
	box.add_theme_constant_override("separation", 6)
	parent.add_child(box)

	var label = Label.new()
	label.text = title_text
	label.add_theme_font_size_override("font_size", 18)
	box.add_child(label)

	for id in ids:
		var button = Button.new()
		button.text = id
		button.custom_minimum_size = Vector2(210, 34)
		button.pressed.connect(func(): callback.call(id))
		box.add_child(button)

func _apply_stage():
	var stage_id = STAGES[stage_option.selected]
	music.configure(stage_id)
	ambience.configure(stage_id)
	stinger_sfx.play_stinger("stage_start")

func _apply_volume():
	music.set_music_volume(float(volume_slider.value))

func _apply_intensity():
	music.set_music_intensity(float(intensity_slider.value))
