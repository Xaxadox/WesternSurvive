extends CanvasLayer

signal settings_changed(settings)
signal resume_requested
signal return_to_menu_requested

const UpgradeIconScript = preload("res://scripts/UpgradeIcon.gd")
const MENU_ATLAS_PATH = "res://assets/menu/western_menu_atlas.png"
const PAUSE_MENU_SCENE = preload("res://scenes/ui/pause_menu.tscn")
const LEVEL_UP_MENU_SCENE = preload("res://scenes/ui/level_up_menu.tscn")

var health_bar
var xp_bar
var title_label
var info_label
var context_label
var weapon_label
var notice_label
var notice_timer = 0.0
var language_option
var master_slider
var music_slider
var resolution_option
var fullscreen_check
var player_count_option

var pause_layer
var pause_label
var pause_content
var pause_menu_mode = "home"
var level_layer
var level_title_label
var game_over_layer
var game_over_title_label
var game_over_stats
var restart_button
var start_layer
var start_title_label
var start_content
var start_menu_mode = "home"
var character_list
var character_title_label
var stage_list
var stage_title_label
var selection_info_label
var start_button
var progress_label
var players_label
var language_label
var master_label
var music_label
var resolution_label

var choice_buttons = []
var choice_cards = []
var current_choices = []
var upgrade_callback = Callable()

var start_characters = []
var start_stages = []
var start_progress = {}
var start_callback = Callable()
var selected_character_index = 0
var selected_stage_index = 0
var selected_player_count = 1
var resolution_values = ["960x540", "1280x720", "1366x768", "1600x900", "1920x1080"]
var language_values = ["pt", "en"]
var current_language = "pt"
var menu_atlas_texture = null
var current_settings = {
	"master_volume": 0.85,
	"music_volume": 0.55,
	"resolution": "1280x720",
	"fullscreen": false,
	"language": "pt"
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_menu_atlas()
	_build_hud()
	_build_pause_layer()
	_build_level_layer()
	_build_game_over_layer()
	_build_start_layer()

func _load_menu_atlas():
	var loaded = ResourceLoader.load(MENU_ATLAS_PATH)
	if loaded is Texture2D:
		menu_atlas_texture = loaded
		return

	var image = Image.new()
	var error = image.load(MENU_ATLAS_PATH)
	if error == OK:
		menu_atlas_texture = ImageTexture.create_from_image(image)

func _process(delta):
	if notice_timer > 0.0:
		notice_timer -= delta
		if notice_timer <= 0.0:
			notice_label.visible = false

func _build_hud():
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.offset_left = 22
	margin.offset_top = 18
	margin.offset_right = -22
	margin.offset_bottom = 104
	root.add_child(margin)

	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.13, 0.09, 0.06, 0.86)))
	margin.add_child(panel)

	var box = HBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)

	var title_box = VBoxContainer.new()
	title_box.custom_minimum_size = Vector2(245, 50)
	box.add_child(title_box)

	title_label = Label.new()
	title_label.text = "Western Survive"
	title_label.add_theme_font_size_override("font_size", 22)
	title_box.add_child(title_label)

	context_label = Label.new()
	context_label.text = ""
	context_label.add_theme_font_size_override("font_size", 13)
	title_box.add_child(context_label)

	var bars = VBoxContainer.new()
	bars.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars.add_theme_constant_override("separation", 8)
	box.add_child(bars)

	health_bar = ProgressBar.new()
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(360, 16)
	health_bar.add_theme_stylebox_override("fill", _bar_style(Color("#b94a3a")))
	bars.add_child(health_bar)

	xp_bar = ProgressBar.new()
	xp_bar.max_value = 8
	xp_bar.value = 0
	xp_bar.show_percentage = false
	xp_bar.custom_minimum_size = Vector2(360, 13)
	xp_bar.add_theme_stylebox_override("fill", _bar_style(Color("#e6b84f")))
	bars.add_child(xp_bar)

	info_label = Label.new()
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	info_label.add_theme_font_size_override("font_size", 18)
	info_label.custom_minimum_size = Vector2(320, 40)
	box.add_child(info_label)

	var weapons_margin = MarginContainer.new()
	weapons_margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	weapons_margin.offset_left = 22
	weapons_margin.offset_top = -78
	weapons_margin.offset_right = -22
	weapons_margin.offset_bottom = -18
	root.add_child(weapons_margin)

	var weapons_panel = PanelContainer.new()
	weapons_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.10, 0.08, 0.06, 0.76)))
	weapons_margin.add_child(weapons_panel)

	weapon_label = Label.new()
	weapon_label.add_theme_font_size_override("font_size", 15)
	weapon_label.text = "%s: -" % _tr("build")
	weapons_panel.add_child(weapon_label)

	notice_label = Label.new()
	notice_label.visible = false
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_label.add_theme_font_size_override("font_size", 20)
	notice_label.add_theme_color_override("font_color", Color("#ffe7a0"))
	notice_label.anchor_left = 0.2
	notice_label.anchor_top = 0.13
	notice_label.anchor_right = 0.8
	notice_label.anchor_bottom = 0.21
	root.add_child(notice_label)

func _build_start_layer():
	start_layer = Control.new()
	start_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	start_layer.visible = false
	start_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(start_layer)

	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.015, 0.01, 0.83)
	start_layer.add_child(shade)

	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#2d2017")))
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 18
	panel.offset_top = 16
	panel.offset_right = -18
	panel.offset_bottom = -16
	start_layer.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var box = VBoxContainer.new()
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	start_title_label = Label.new()
	start_title_label.text = "Western Survive"
	start_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_title_label.add_theme_font_size_override("font_size", 26)
	box.add_child(start_title_label)

	progress_label = Label.new()
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_size_override("font_size", 13)
	box.add_child(progress_label)

	start_content = VBoxContainer.new()
	start_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	start_content.add_theme_constant_override("separation", 12)
	box.add_child(start_content)

func _show_start_mode(mode):
	start_menu_mode = mode
	if start_content == null:
		return

	_clear_container(start_content)
	_reset_start_content_refs()
	_update_start_progress_label()

	match mode:
		"characters":
			_build_character_menu()
		"stages":
			_build_stage_menu()
		"language":
			_build_language_menu(start_content, true)
		"video":
			_build_video_menu(start_content, true)
		"audio":
			_build_audio_menu(start_content, true)
		_:
			_build_start_home()

func _build_start_home():
	start_title_label.text = "Western Survive"
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 26)
	start_content.add_child(spacer)

	_add_menu_button(start_content, _tr("play"), Callable(self, "_show_start_mode").bind("characters"), 300, 9)
	_add_menu_button(start_content, _tr("language"), Callable(self, "_show_start_mode").bind("language"), 300, 10)
	_add_menu_button(start_content, _tr("video"), Callable(self, "_show_start_mode").bind("video"), 300, 11)
	_add_menu_button(start_content, _tr("audio"), Callable(self, "_show_start_mode").bind("audio"), 300, 12)

func _build_character_menu():
	start_title_label.text = _tr("choose_character")
	character_title_label = _add_section_title(start_content, _tr("characters"))
	character_list = _add_scroll_list(start_content)

	selected_character_index = clampi(selected_character_index, 0, maxi(start_characters.size() - 1, 0))
	for i in range(start_characters.size()):
		var button = _add_list_button(character_list, Callable(self, "_select_character").bind(i), i)
		button.set_meta("entry_index", i)

	selection_info_label = _add_selection_info(start_content)
	_add_player_count_controls(start_content)
	var row = _add_button_row(start_content)
	_add_menu_button(row, _tr("back"), Callable(self, "_show_start_mode").bind("home"), 180)
	_add_menu_button(row, _tr("continue"), Callable(self, "_show_start_mode").bind("stages"), 220)
	_update_start_buttons()

func _build_stage_menu():
	start_title_label.text = _tr("choose_stage")
	stage_title_label = _add_section_title(start_content, _tr("stages"))
	stage_list = _add_scroll_list(start_content)

	selected_stage_index = clampi(selected_stage_index, 0, maxi(start_stages.size() - 1, 0))
	for i in range(start_stages.size()):
		var button = _add_list_button(stage_list, Callable(self, "_select_stage").bind(i), 4 + i)
		button.set_meta("entry_index", i)

	selection_info_label = _add_selection_info(start_content)
	var row = _add_button_row(start_content)
	_add_menu_button(row, _tr("back"), Callable(self, "_show_start_mode").bind("characters"), 180)
	start_button = _add_menu_button(row, _tr("start"), Callable(self, "_on_start_pressed"), 220)
	_update_start_buttons()

func _build_language_menu(parent, show_back):
	start_title_label.text = _tr("language") if parent == start_content else _tr("paused")
	_add_language_controls(parent)
	if show_back:
		_add_menu_button(parent, _tr("back"), Callable(self, "_show_start_mode").bind("home"), 220)

func _build_video_menu(parent, show_back):
	start_title_label.text = _tr("video") if parent == start_content else _tr("paused")
	_add_video_controls(parent)
	if show_back:
		_add_menu_button(parent, _tr("back"), Callable(self, "_show_start_mode").bind("home"), 220)

func _build_audio_menu(parent, show_back):
	start_title_label.text = _tr("audio") if parent == start_content else _tr("paused")
	_add_audio_controls(parent)
	if show_back:
		_add_menu_button(parent, _tr("back"), Callable(self, "_show_start_mode").bind("home"), 220)

func _add_section_title(parent, text):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	parent.add_child(label)
	return label

func _add_scroll_list(parent):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#201711")))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)

	var list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	return list

func _add_list_button(parent, callback, icon_index = -1):
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 14)
	_apply_button_icon(button, icon_index)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _add_selection_info(parent):
	var label = Label.new()
	label.custom_minimum_size = Vector2(0, 50)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 13)
	parent.add_child(label)
	return label

func _add_button_row(parent):
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	return row

func _add_menu_button(parent, text, callback, width, icon_index = -1):
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, 44)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_apply_button_icon(button, icon_index)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _apply_button_icon(button, icon_index):
	if icon_index < 0 or menu_atlas_texture == null:
		return
	var texture = _menu_atlas_region(icon_index)
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _menu_atlas_region(index):
	if menu_atlas_texture == null:
		return null
	var texture = AtlasTexture.new()
	texture.atlas = menu_atlas_texture
	var cell = float(menu_atlas_texture.get_width()) / 4.0
	var col = index % 4
	var row = int(index / 4)
	texture.region = Rect2(float(col) * cell, float(row) * cell, cell, cell)
	return texture

func _add_language_controls(parent):
	var box = _add_settings_panel(parent)
	language_label = Label.new()
	language_label.text = _tr("language")
	box.add_child(language_label)

	language_option = OptionButton.new()
	language_option.add_item(_tr("portuguese"))
	language_option.add_item("English")
	language_option.item_selected.connect(_on_language_selected)
	box.add_child(language_option)
	_sync_settings_controls()

func _add_player_count_controls(parent):
	var box = _add_settings_panel(parent)
	players_label = Label.new()
	players_label.text = _tr("players")
	box.add_child(players_label)

	player_count_option = OptionButton.new()
	for i in range(1, 5):
		player_count_option.add_item(str(i))
	player_count_option.select(clampi(selected_player_count - 1, 0, 3))
	player_count_option.item_selected.connect(_on_player_count_selected)
	box.add_child(player_count_option)

func _add_video_controls(parent):
	var box = _add_settings_panel(parent)
	resolution_label = Label.new()
	resolution_label.text = _tr("resolution")
	box.add_child(resolution_label)

	resolution_option = OptionButton.new()
	for value in resolution_values:
		resolution_option.add_item(value)
	resolution_option.item_selected.connect(_on_resolution_selected)
	box.add_child(resolution_option)

	fullscreen_check = CheckButton.new()
	fullscreen_check.text = _tr("fullscreen")
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	box.add_child(fullscreen_check)
	_sync_settings_controls()

func _add_audio_controls(parent):
	var box = _add_settings_panel(parent)
	master_label = Label.new()
	master_label.text = _tr("master_volume")
	box.add_child(master_label)

	master_slider = HSlider.new()
	master_slider.min_value = 0
	master_slider.max_value = 100
	master_slider.step = 1
	master_slider.value_changed.connect(_on_master_volume_changed)
	box.add_child(master_slider)

	music_label = Label.new()
	music_label.text = _tr("music")
	box.add_child(music_label)

	music_slider = HSlider.new()
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.step = 1
	music_slider.value_changed.connect(_on_music_volume_changed)
	box.add_child(music_slider)
	_sync_settings_controls()

func _add_settings_panel(parent):
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#201711")))
	panel.custom_minimum_size = Vector2(420, 0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(panel)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	return box

func _clear_container(container):
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _reset_start_content_refs():
	character_list = null
	character_title_label = null
	stage_list = null
	stage_title_label = null
	selection_info_label = null
	start_button = null
	players_label = null
	player_count_option = null
	language_label = null
	language_option = null
	master_label = null
	master_slider = null
	music_label = null
	music_slider = null
	resolution_label = null
	resolution_option = null
	fullscreen_check = null

func _update_start_progress_label():
	if progress_label == null:
		return
	var unlocked_weapons = start_progress.get("unlocked_weapons", [])
	var secret_count = unlocked_weapons.size()
	var bonus_text = _tr("bonus_unlocked") if _stage_id_unlocked("bonus") else _tr("bonus_locked")
	progress_label.text = "%s %d/4  |  %s" % [_tr("secret_weapons"), secret_count, bonus_text]

func _build_pause_layer():
	pause_layer = PAUSE_MENU_SCENE.instantiate()
	pause_layer.visible = false
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_layer)

	var panel = pause_layer.get_node("Panel")
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#2d2017")))
	pause_label = pause_layer.get_node("Panel/Margin/Box/Title")
	pause_content = pause_layer.get_node("Panel/Margin/Box/Content")
	pause_label.text = _tr("paused_title")
	_show_pause_mode("home")

func _show_pause_mode(mode):
	pause_menu_mode = mode
	if pause_content == null:
		return
	_clear_container(pause_content)
	_reset_start_content_refs()

	if pause_label != null:
		pause_label.text = _tr("paused_title")

	match mode:
		"audio":
			_add_audio_controls(pause_content)
			_add_menu_button(pause_content, _tr("back"), Callable(self, "_show_pause_mode").bind("home"), 220)
		"video":
			_add_video_controls(pause_content)
			_add_menu_button(pause_content, _tr("back"), Callable(self, "_show_pause_mode").bind("home"), 220)
		_:
			_add_menu_button(pause_content, _tr("resume"), Callable(self, "_on_resume_pressed"), 260, 9)
			_add_menu_button(pause_content, _tr("audio"), Callable(self, "_show_pause_mode").bind("audio"), 260, 12)
			_add_menu_button(pause_content, _tr("video"), Callable(self, "_show_pause_mode").bind("video"), 260, 11)
			_add_menu_button(pause_content, _tr("back_to_menu"), Callable(self, "_on_return_to_menu_pressed"), 260)

func _on_resume_pressed():
	resume_requested.emit()

func _on_return_to_menu_pressed():
	return_to_menu_requested.emit()

func _build_level_layer():
	level_layer = LEVEL_UP_MENU_SCENE.instantiate()
	level_layer.visible = false
	level_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(level_layer)

	var panel = level_layer.get_node("Panel")
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#2d2017")))
	level_title_label = level_layer.get_node("Panel/Margin/Box/Title")
	level_title_label.text = _tr("choose_upgrade")

	choice_buttons.clear()
	choice_cards.clear()
	for i in range(3):
		var button = level_layer.get_node("Panel/Margin/Box/Choice%d" % i)
		button.pressed.connect(_on_choice_pressed.bind(i))
		choice_buttons.append(button)
		choice_cards.append({
			"icon": button.get_node("Row/Icon"),
			"title": button.get_node("Row/Labels/ChoiceTitle"),
			"desc": button.get_node("Row/Labels/ChoiceDesc")
		})

func _build_game_over_layer():
	game_over_layer = Control.new()
	game_over_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_layer.visible = false
	game_over_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(game_over_layer)

	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.68)
	game_over_layer.add_child(shade)

	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#241812")))
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -250
	panel.offset_top = -165
	panel.offset_right = 250
	panel.offset_bottom = 165
	game_over_layer.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	game_over_title_label = Label.new()
	game_over_title_label.text = _tr("game_over")
	game_over_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_title_label.add_theme_font_size_override("font_size", 34)
	box.add_child(game_over_title_label)

	game_over_stats = Label.new()
	game_over_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_stats.add_theme_font_size_override("font_size", 18)
	box.add_child(game_over_stats)

	restart_button = Button.new()
	restart_button.text = _tr("back_to_menu")
	restart_button.custom_minimum_size = Vector2(190, 42)
	restart_button.pressed.connect(_restart_scene)
	box.add_child(restart_button)

func show_start_menu(characters, stages, progress, callback):
	start_characters = characters
	start_stages = stages
	start_progress = progress
	start_callback = callback
	selected_character_index = 0
	selected_stage_index = _first_unlocked_stage_index()
	selected_player_count = 1
	start_menu_mode = "home"
	_show_start_mode("home")
	start_layer.visible = true

func hide_start_menu():
	start_layer.visible = false

func set_settings(settings):
	current_settings = {
		"master_volume": clampf(float(settings.get("master_volume", 0.85)), 0.0, 1.0),
		"music_volume": clampf(float(settings.get("music_volume", 0.55)), 0.0, 1.0),
		"resolution": str(settings.get("resolution", "1280x720")),
		"fullscreen": bool(settings.get("fullscreen", false)),
		"language": _safe_language(str(settings.get("language", "pt")))
	}
	current_language = current_settings["language"]
	_sync_settings_controls()
	_apply_language_texts()

func set_language(language):
	var safe_language = _safe_language(language)
	if current_language == safe_language and str(current_settings.get("language", "pt")) == safe_language:
		return
	current_language = safe_language
	current_settings["language"] = current_language
	_sync_settings_controls()
	_apply_language_texts()

func _rebuild_start_buttons():
	_show_start_mode(start_menu_mode)

func _update_start_buttons():
	if start_characters.is_empty() or start_stages.is_empty():
		if start_button != null:
			start_button.disabled = true
		_update_selection_info()
		return

	selected_character_index = clampi(selected_character_index, 0, start_characters.size() - 1)
	selected_stage_index = clampi(selected_stage_index, 0, start_stages.size() - 1)

	if character_list != null:
		for i in range(mini(character_list.get_child_count(), start_characters.size())):
			var button = character_list.get_child(i)
			var character = start_characters[i]
			var prefix = "> " if i == selected_character_index else "  "
			button.text = "%s%s" % [prefix, _entry_name(character, "character", i)]

	if stage_list != null:
		for i in range(mini(stage_list.get_child_count(), start_stages.size())):
			var button = stage_list.get_child(i)
			var stage = start_stages[i]
			var unlocked = _stage_id_unlocked(stage.get("id", ""))
			var prefix = "> " if i == selected_stage_index else "  "
			var lock_text = "" if unlocked else " [%s]" % _tr("locked")
			button.text = "%s%s%s" % [prefix, _entry_name(stage, "stage", i), lock_text]
			button.disabled = not unlocked

	if start_button == null:
		pass
	elif start_stages.is_empty():
		start_button.disabled = true
	else:
		start_button.disabled = not _stage_id_unlocked(start_stages[selected_stage_index].get("id", ""))
	_update_selection_info()

func _entry_name(data, fallback_key, index):
	var value = _localized(data, "name")
	if _is_valid_text(value):
		return value
	return "%s %d" % [_tr(fallback_key), index + 1]

func _update_selection_info():
	if selection_info_label == null:
		return
	if start_characters.is_empty() or start_stages.is_empty():
		selection_info_label.text = ""
		return

	selected_character_index = clampi(selected_character_index, 0, start_characters.size() - 1)
	selected_stage_index = clampi(selected_stage_index, 0, start_stages.size() - 1)
	var character = start_characters[selected_character_index]
	var stage = start_stages[selected_stage_index]
	var lines = []

	if _character_seen(character.get("id", ""), selected_character_index):
		lines.append("%s: %s" % [_entry_name(character, "character", selected_character_index), _localized(character, "desc")])
	else:
		lines.append("%s: %s" % [_entry_name(character, "character", selected_character_index), _tr("play_to_reveal")])

	if start_menu_mode == "characters":
		selection_info_label.text = lines[0]
		return

	if _stage_seen(stage.get("id", ""), selected_stage_index):
		lines.append("%s: %s" % [_entry_name(stage, "stage", selected_stage_index), _localized(stage, "desc")])
	else:
		lines.append("%s: %s" % [_entry_name(stage, "stage", selected_stage_index), _tr("play_to_reveal")])

	selection_info_label.text = _join_text(lines, "  |  ")

func _character_seen(character_id, index = -1):
	if index == 0:
		return true
	if character_id == "":
		return false
	var played_characters = start_progress.get("played_characters", [])
	return typeof(played_characters) == TYPE_ARRAY and played_characters.has(character_id)

func _stage_seen(stage_id, index = -1):
	if index == 0:
		return true
	if stage_id == "":
		return false
	var played_stages = start_progress.get("played_stages", [])
	return typeof(played_stages) == TYPE_ARRAY and played_stages.has(stage_id)

func _join_text(values, separator):
	var result = ""
	for value in values:
		if result != "":
			result += separator
		result += str(value)
	return result

func _select_character(index):
	if index < 0 or index >= start_characters.size():
		return
	selected_character_index = index
	_update_start_buttons()

func _select_stage(index):
	if index < 0 or index >= start_stages.size():
		return
	if not _stage_id_unlocked(start_stages[index].get("id", "")):
		return
	selected_stage_index = index
	_update_start_buttons()

func _on_start_pressed():
	if not start_callback.is_valid():
		return
	if start_characters.is_empty() or start_stages.is_empty():
		return
	selected_character_index = clampi(selected_character_index, 0, start_characters.size() - 1)
	selected_stage_index = clampi(selected_stage_index, 0, start_stages.size() - 1)
	var stage = start_stages[selected_stage_index]
	var character = start_characters[selected_character_index]
	start_callback.call(stage.get("id", ""), character.get("id", ""), selected_player_count)

func _first_unlocked_stage_index():
	for i in range(start_stages.size()):
		if _stage_id_unlocked(start_stages[i].get("id", "")):
			return i
	return 0

func _stage_id_unlocked(stage_id):
	if stage_id == "":
		return false
	if stage_id == "bonus":
		return start_progress.get("unlocked_stages", []).has(stage_id)
	return true

func _on_player_count_selected(index):
	selected_player_count = clampi(index + 1, 1, 4)

func _on_language_selected(index):
	current_settings["language"] = language_values[clampi(index, 0, language_values.size() - 1)]
	set_language(current_settings["language"])
	_emit_settings()


func _sync_settings_controls():
	if master_slider != null:
		master_slider.set_value_no_signal(float(current_settings.get("master_volume", 0.85)) * 100.0)
	if music_slider != null:
		music_slider.set_value_no_signal(float(current_settings.get("music_volume", 0.55)) * 100.0)
	if language_option != null:
		var language_index = language_values.find(str(current_settings.get("language", "pt")))
		if language_index < 0:
			language_index = 0
		language_option.select(language_index)
	if resolution_option != null:
		var resolution = str(current_settings.get("resolution", "1280x720"))
		var index = resolution_values.find(resolution)
		if index < 0:
			index = 1
		resolution_option.select(index)
	if fullscreen_check != null:
		fullscreen_check.set_pressed_no_signal(bool(current_settings.get("fullscreen", false)))

func _on_master_volume_changed(value):
	current_settings["master_volume"] = float(value) / 100.0
	_emit_settings()

func _on_music_volume_changed(value):
	current_settings["music_volume"] = float(value) / 100.0
	_emit_settings()

func _on_resolution_selected(index):
	current_settings["resolution"] = resolution_values[index]
	_emit_settings()

func _on_fullscreen_toggled(pressed):
	current_settings["fullscreen"] = pressed
	_emit_settings()

func _emit_settings():
	settings_changed.emit(current_settings.duplicate(true))

func _apply_language_texts():
	if start_title_label != null:
		start_title_label.text = "Western Survive"
	if character_title_label != null:
		character_title_label.text = _tr("characters")
	if stage_title_label != null:
		stage_title_label.text = _tr("stages")
	if players_label != null:
		players_label.text = _tr("players")
	if language_label != null:
		language_label.text = _tr("language")
	if language_option != null:
		language_option.set_item_text(0, _tr("portuguese"))
		language_option.set_item_text(1, "English")
	if master_label != null:
		master_label.text = _tr("master_volume")
	if music_label != null:
		music_label.text = _tr("music")
	if resolution_label != null:
		resolution_label.text = _tr("resolution")
	if fullscreen_check != null:
		fullscreen_check.text = _tr("fullscreen")
	if start_button != null:
		start_button.text = _tr("start")
	if pause_label != null:
		pause_label.text = _tr("paused_title")
	if level_title_label != null:
		level_title_label.text = _tr("choose_upgrade")
	if game_over_title_label != null:
		game_over_title_label.text = _tr("game_over")
	if restart_button != null:
		restart_button.text = _tr("back_to_menu")
	if start_layer != null and start_layer.visible:
		_show_start_mode(start_menu_mode)
	if pause_layer != null and pause_layer.visible:
		_show_pause_mode(pause_menu_mode)

func _localized(data, key):
	if typeof(data) != TYPE_DICTIONARY:
		return ""
	var value = data.get(key, "")
	if current_language == "en":
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

func _safe_language(language):
	return "en" if language == "en" else "pt"

func _tr(key):
	var english = current_language == "en"
	match key:
		"start_title":
			return "Choose your survivor and stage" if english else "Escolha seu sobrevivente e a fase"
		"play":
			return "Play" if english else "Jogar"
		"video":
			return "Video" if english else "Video"
		"audio":
			return "Audio" if english else "Audio"
		"choose_character":
			return "Choose your survivor" if english else "Escolha seu sobrevivente"
		"choose_stage":
			return "Choose the stage" if english else "Escolha a fase"
		"characters":
			return "Characters" if english else "Personagens"
		"stages":
			return "Stages" if english else "Fases"
		"character":
			return "Character" if english else "Personagem"
		"stage":
			return "Stage" if english else "Fase"
		"play_to_reveal":
			return "Play to reveal details" if english else "Jogue para revelar detalhes"
		"players":
			return "Players" if english else "Jogadores"
		"language":
			return "Language" if english else "Idioma"
		"portuguese":
			return "Portuguese" if english else "Portugues"
		"master_volume":
			return "Master volume" if english else "Volume geral"
		"music":
			return "Music" if english else "Musica"
		"resolution":
			return "Resolution" if english else "Resolucao"
		"fullscreen":
			return "Fullscreen" if english else "Tela cheia"
		"start":
			return "Start" if english else "Comecar"
		"continue":
			return "Continue" if english else "Continuar"
		"back":
			return "Back" if english else "Voltar"
		"resume":
			return "Resume" if english else "Continuar"
		"paused_title":
			return "Paused" if english else "Pausado"
		"paused":
			return "Paused\nESC to resume" if english else "Pausado\nESC para voltar"
		"choose_upgrade":
			return "Choose an upgrade" if english else "Escolha uma melhoria"
		"game_over":
			return "Run over" if english else "Fim da rodada"
		"back_to_menu":
			return "Back to menu" if english else "Voltar ao menu"
		"bonus_unlocked":
			return "Bonus stage unlocked" if english else "Fase bonus liberada"
		"bonus_locked":
			return "Bonus stage locked" if english else "Fase bonus travada"
		"secret_weapons":
			return "Secret weapons" if english else "Armas secretas"
		"locked":
			return "locked" if english else "travada"
		"weapons":
			return "Weapons" if english else "Armas"
		"build":
			return "Weapons/Buffs" if english else "Armas/Buffs"
		"level_short":
			return "Lv" if english else "Lv"
		"targets":
			return "Targets" if english else "Alvos"
		"time":
			return "Time" if english else "Tempo"
		_:
			return key

func set_run_context(stage_name, character_name):
	context_label.text = "%s  |  %s" % [stage_name, character_name]

func set_weapons(summary):
	if summary.is_empty():
		weapon_label.text = "%s: -" % _tr("build")
		return

	var text = ""
	for item in summary:
		if text != "":
			text += "  |  "
		text += item
	weapon_label.text = "%s: %s" % [_tr("build"), text]

func set_stats(health, max_health, xp, xp_required, level, kills, elapsed_time):
	health_bar.max_value = max_health
	health_bar.value = health
	xp_bar.max_value = xp_required
	xp_bar.value = xp
	info_label.text = "%s %d  |  %s  |  %s %d" % [_tr("level_short"), level, _format_time(elapsed_time), _tr("targets"), kills]

func show_toast(text):
	notice_label.text = text
	notice_label.visible = true
	notice_timer = 3.2

func show_pause(visible):
	if visible:
		_show_pause_mode("home")
	pause_layer.visible = visible

func show_level_up(choices, callback):
	current_choices = choices
	upgrade_callback = callback
	level_layer.visible = true

	for i in range(choice_buttons.size()):
		var button = choice_buttons[i]
		if i < choices.size():
			var choice = choices[i]
			var card = choice_cards[i]
			button.visible = true
			button.text = ""
			card["title"].text = choice.get("title", "")
			card["desc"].text = choice.get("desc", "")
			if card["icon"].has_method("configure"):
				card["icon"].configure(choice)
		else:
			button.visible = false

func show_game_over(kills, elapsed_time, stage_name = "", secret_count = 0):
	game_over_stats.text = "%s\n%s %s  |  %s %d\n%s %d/4" % [
		stage_name,
		_tr("time"),
		_format_time(elapsed_time),
		_tr("targets"),
		kills,
		_tr("secret_weapons"),
		secret_count
	]
	game_over_layer.visible = true

func hide_game_over():
	game_over_layer.visible = false

func _on_choice_pressed(index):
	if index >= current_choices.size():
		return

	var choice = current_choices[index]
	level_layer.visible = false
	if upgrade_callback.is_valid():
		upgrade_callback.call(choice)

func _format_time(seconds):
	var total = int(seconds)
	var minutes = int(total / 60)
	var secs = total % 60
	return "%02d:%02d" % [minutes, secs]

func _restart_scene():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _panel_style(color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#8f6233")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin(SIDE_LEFT, 12)
	style.set_content_margin(SIDE_TOP, 12)
	style.set_content_margin(SIDE_RIGHT, 12)
	style.set_content_margin(SIDE_BOTTOM, 12)
	return style

func _bar_style(color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style
