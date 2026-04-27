extends Node2D
## LocationBase - Base script for all location scenes.
## Sets up common UI elements: dialogue box, HUD, map button, hint button.

@export var location_id: String = ""
@export var location_name: String = ""
@export var bg_color: Color = Color(0.05, 0.05, 0.12)

var _dialogue_system_scene: PackedScene = null

func _ready() -> void:
	_setup_background()
	_setup_ui()
	_setup_location_label()
	_trigger_initial_dialogue()

func _setup_background() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = -10

	var bg_texture := _load_location_background()

	if bg_texture:
		var bg_img := TextureRect.new()
		bg_img.texture = bg_texture
		bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		canvas.add_child(bg_img)
	else:
		var bg := ColorRect.new()
		bg.color = bg_color
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		canvas.add_child(bg)

	add_child(canvas)

func _load_location_background() -> Texture2D:
	for extension in ["png", "svg"]:
		var bg_path := "res://assets/sprites/locations/%s.%s" % [location_id, extension]
		var bg_texture := load(bg_path) as Texture2D
		if bg_texture:
			return bg_texture
	return null

func _setup_ui() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 10
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	# HUD - top bar
	var hud := HBoxContainer.new()
	hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud.offset_bottom = 40
	hud.name = "HUD"

	# Chapter & Location label
	var info_label := Label.new()
	info_label.text = "第%d章 | %s" % [GameManager.current_chapter, location_name]
	info_label.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9, 0.8))
	info_label.add_theme_font_size_override("font_size", 14)
	hud.add_child(info_label)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(spacer)

	# Action points
	var ap_label := Label.new()
	ap_label.text = "AP: %d/%d" % [GameManager.action_points, GameManager.max_action_points]
	ap_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.0))
	ap_label.add_theme_font_size_override("font_size", 14)
	ap_label.name = "APLabel"
	hud.add_child(ap_label)

	ui_layer.add_child(hud)

	# Bottom toolbar
	var toolbar := HBoxContainer.new()
	toolbar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	toolbar.offset_top = -56
	toolbar.alignment = BoxContainer.ALIGNMENT_CENTER
	toolbar.add_theme_constant_override("separation", 20)
	toolbar.name = "Toolbar"

	if not _get_location_story_actions().is_empty():
		var investigate_btn := Button.new()
		investigate_btn.text = "調查"
		investigate_btn.custom_minimum_size = Vector2(80, 48)
		investigate_btn.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6))
		investigate_btn.pressed.connect(_show_story_actions)
		toolbar.add_child(investigate_btn)

	# Map button
	var map_btn := Button.new()
	map_btn.text = "地圖"
	map_btn.custom_minimum_size = Vector2(80, 48)
	map_btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	map_btn.pressed.connect(_show_map)
	toolbar.add_child(map_btn)

	# Eagle eye button
	var eye_btn := Button.new()
	eye_btn.text = "鷹眼"
	eye_btn.custom_minimum_size = Vector2(80, 48)
	eye_btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.0))
	eye_btn.pressed.connect(_toggle_eagle_eye)
	toolbar.add_child(eye_btn)

	# Evidence board button
	var board_btn := Button.new()
	board_btn.text = "證據板"
	board_btn.custom_minimum_size = Vector2(80, 48)
	board_btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	board_btn.pressed.connect(_open_evidence_board)
	toolbar.add_child(board_btn)

	# Hint button (mobile)
	if InputManager.is_mobile:
		var hint_btn := Button.new()
		hint_btn.text = "提示"
		hint_btn.custom_minimum_size = Vector2(80, 48)
		hint_btn.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		var HotspotScript: GDScript = load("res://scripts/gameplay/hotspot.gd")
		hint_btn.pressed.connect(func(): HotspotScript.pulse_all_hotspots(get_tree()))
		toolbar.add_child(hint_btn)

	# Menu button
	var menu_btn := Button.new()
	menu_btn.text = "選單"
	menu_btn.custom_minimum_size = Vector2(80, 48)
	menu_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	menu_btn.pressed.connect(_show_pause_menu)
	toolbar.add_child(menu_btn)

	ui_layer.add_child(toolbar)

	# Dialogue system
	var dialogue_system := Control.new()
	dialogue_system.name = "DialogueSystem"
	dialogue_system.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_system.set_script(load("res://scripts/gameplay/dialogue_system.gd"))
	dialogue_system.add_to_group("dialogue_system")

	# Portraits
	var portrait_left := TextureRect.new()
	portrait_left.name = "PortraitLeft"
	portrait_left.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	portrait_left.offset_left = 16
	portrait_left.offset_top = -280
	portrait_left.offset_bottom = -80
	portrait_left.custom_minimum_size = Vector2(120, 200)
	portrait_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_left.visible = false
	dialogue_system.add_child(portrait_left)

	var portrait_right := TextureRect.new()
	portrait_right.name = "PortraitRight"
	portrait_right.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	portrait_right.offset_right = -16
	portrait_right.offset_left = -136
	portrait_right.offset_top = -280
	portrait_right.offset_bottom = -80
	portrait_right.custom_minimum_size = Vector2(120, 200)
	portrait_right.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_right.visible = false
	dialogue_system.add_child(portrait_right)

	# Dialogue panel (bottom of screen)
	var dialogue_panel := PanelContainer.new()
	dialogue_panel.name = "DialoguePanel"
	dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialogue_panel.offset_top = -200
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.02, 0.08, 0.9)
	panel_style.border_color = Color(0.0, 0.7, 0.7, 0.8)
	panel_style.border_width_top = 2
	panel_style.set_content_margin_all(16)
	dialogue_panel.add_theme_stylebox_override("panel", panel_style)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 4)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6))
	name_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(name_label)

	var dialogue_text := RichTextLabel.new()
	dialogue_text.name = "DialogueText"
	dialogue_text.bbcode_enabled = true
	dialogue_text.fit_content = true
	dialogue_text.scroll_active = false
	dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_text.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9))
	dialogue_text.add_theme_font_size_override("normal_font_size", 18)
	dialogue_text.custom_minimum_size = Vector2(0, 80)
	vbox.add_child(dialogue_text)

	var choices_container := VBoxContainer.new()
	choices_container.name = "ChoicesContainer"
	choices_container.add_theme_constant_override("separation", 6)
	choices_container.visible = false
	vbox.add_child(choices_container)

	var continue_indicator := Label.new()
	continue_indicator.name = "ContinueIndicator"
	continue_indicator.text = "▼"
	continue_indicator.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9, 0.7))
	continue_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	continue_indicator.visible = false
	vbox.add_child(continue_indicator)

	dialogue_panel.add_child(vbox)
	dialogue_system.add_child(dialogue_panel)

	ui_layer.add_child(dialogue_system)

	# Update AP display when it changes
	GameManager.action_points_changed.connect(func(remaining: int):
		ap_label.text = "AP: %d/%d" % [remaining, GameManager.max_action_points]
	)

func _setup_location_label() -> void:
	# Large location name that fades in and out
	var canvas := CanvasLayer.new()
	canvas.layer = 20

	var label := Label.new()
	label.text = location_name
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	canvas.add_child(label)
	add_child(canvas)

	# Animate
	label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)

func _trigger_initial_dialogue() -> void:
	var chapter_data := CaseData.get_chapter_data(GameManager.current_chapter)
	var loc_data: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	var initial_dialogue: String = loc_data.get("initial_dialogue", "")

	if initial_dialogue != "" and not GameManager.get_dialogue_flag("visited_" + location_id):
		GameManager.set_dialogue_flag("visited_" + location_id)
		var dialogue_entries := DialogueData.get_dialogue(initial_dialogue)
		if dialogue_entries.size() > 0:
			await get_tree().process_frame
			var ds := get_tree().get_first_node_in_group("dialogue_system")
			if ds and ds.has_method("start_dialogue"):
				ds.start_dialogue(dialogue_entries)

func _get_location_story_actions() -> Array:
	var chapter_data := CaseData.get_chapter_data(GameManager.current_chapter)
	var loc_data: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	return loc_data.get("story_actions", [])

func _get_available_story_actions() -> Array:
	var available: Array = []
	for action in _get_location_story_actions():
		var action_data: Dictionary = action
		var requires_flag: String = action_data.get("requires_flag", "")
		if requires_flag != "" and not GameManager.get_dialogue_flag(requires_flag):
			continue

		var requires_evidence: String = action_data.get("requires_evidence", "")
		if requires_evidence != "" and not GameManager.has_evidence(requires_evidence):
			continue

		available.append(action_data)
	return available

func _show_story_actions() -> void:
	var actions := _get_available_story_actions()

	var popup_layer := CanvasLayer.new()
	popup_layer.layer = 95

	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.6)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup_layer.add_child(dimmer)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.15, 0.95)
	style.border_color = Color(1.0, 0.0, 0.6)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(320, 0)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "調查"
	title.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6))
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	if actions.is_empty():
		var empty_label := Label.new()
		empty_label.text = "目前沒有新的調查行動"
		empty_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_label)
	else:
		for action in actions:
			var action_data := action
			var btn := Button.new()
			btn.text = action_data.get("title", "調查")
			btn.custom_minimum_size = Vector2(0, 48)
			btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.0, 0.6))
			btn.pressed.connect(func():
				popup_layer.queue_free()
				_run_story_action(action_data)
			)
			vbox.add_child(btn)

	var close_btn := Button.new()
	close_btn.text = "取消"
	close_btn.custom_minimum_size = Vector2(0, 48)
	close_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	close_btn.pressed.connect(popup_layer.queue_free)
	vbox.add_child(close_btn)

	margin.add_child(vbox)
	panel.add_child(margin)
	popup_layer.add_child(panel)
	add_child(popup_layer)

func _run_story_action(action_data: Dictionary) -> void:
	var flag: String = action_data.get("set_flag", "")
	if flag != "":
		GameManager.set_dialogue_flag(flag)

	var evidence: String = action_data.get("give_evidence", "")
	if evidence != "":
		GameManager.collect_evidence(evidence)

	var dialogue_id: String = ""
	if action_data.get("use_calculated_ending", false):
		dialogue_id = GameManager.calculate_ending()
	else:
		dialogue_id = action_data.get("dialogue", "")
	if dialogue_id == "":
		return

	var dialogue_entries := DialogueData.get_dialogue(dialogue_id)
	if dialogue_entries.is_empty():
		return

	var ds := get_tree().get_first_node_in_group("dialogue_system")
	if ds and ds.has_method("start_dialogue"):
		ds.start_dialogue(dialogue_entries)

func _show_map() -> void:
	var chapter_data := CaseData.get_chapter_data(GameManager.current_chapter)
	var current_loc: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	var connections: Array = current_loc.get("connections", [])

	var popup_layer := CanvasLayer.new()
	popup_layer.layer = 95

	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.6)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup_layer.add_child(dimmer)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.15, 0.95)
	style.border_color = Color(0.0, 0.7, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(320, 0)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "前往目的地"
	title.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	for conn_id in connections:
		var loc: Dictionary = chapter_data.get("locations", {}).get(conn_id, {})
		var req_flag: String = loc.get("requires_flag", "")
		if req_flag != "" and not GameManager.get_dialogue_flag(req_flag):
			continue

		var btn := Button.new()
		btn.text = loc.get("name", conn_id)
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.0, 0.6))
		btn.pressed.connect(func():
			popup_layer.queue_free()
			GameManager.spend_action_points(1)
			await SceneManager.change_scene(conn_id)
		)
		vbox.add_child(btn)

	var close_btn := Button.new()
	close_btn.text = "取消"
	close_btn.custom_minimum_size = Vector2(0, 48)
	close_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	close_btn.pressed.connect(popup_layer.queue_free)
	vbox.add_child(close_btn)

	margin.add_child(vbox)
	panel.add_child(margin)
	popup_layer.add_child(panel)
	add_child(popup_layer)

func _toggle_eagle_eye() -> void:
	if GameManager.eagle_eye_active:
		GameManager.deactivate_eagle_eye()
	else:
		GameManager.activate_eagle_eye()

func _open_evidence_board() -> void:
	var EvidenceBoardScript: GDScript = load("res://scripts/gameplay/evidence_board.gd")
	var board: Control = EvidenceBoardScript.new()
	board.set_anchors_preset(Control.PRESET_FULL_RECT)
	var canvas := CanvasLayer.new()
	canvas.layer = 80
	canvas.name = "EvidenceBoardLayer"

	# Build board UI structure
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.08, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)

	var board_container := Control.new()
	board_container.name = "BoardContainer"
	board_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	var cards_layer := Control.new()
	cards_layer.name = "CardsLayer"
	cards_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	var lines_layer := Control.new()
	lines_layer.name = "LinesLayer"
	lines_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_container.add_child(lines_layer)
	board_container.add_child(cards_layer)

	var ui_container := Control.new()
	ui_container.name = "UI"
	ui_container.set_anchors_preset(Control.PRESET_FULL_RECT)

	var progress := ProgressBar.new()
	progress.name = "ProgressBar"
	progress.set_anchors_preset(Control.PRESET_TOP_WIDE)
	progress.custom_minimum_size = Vector2(0, 20)
	ui_container.add_child(progress)

	var close_btn := Button.new()
	close_btn.name = "CloseButton"
	close_btn.text = "關閉證據板"
	close_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	close_btn.offset_left = -160
	close_btn.offset_top = -50
	close_btn.custom_minimum_size = Vector2(150, 44)
	close_btn.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	ui_container.add_child(close_btn)

	board.add_child(bg)
	board.add_child(board_container)
	board.add_child(ui_container)
	canvas.add_child(board)
	add_child(canvas)

	board.board_closed.connect(func(): canvas.queue_free())
	board.open()

func _show_pause_menu() -> void:
	var popup_layer := CanvasLayer.new()
	popup_layer.layer = 95

	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.7)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup_layer.add_child(dimmer)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.15, 0.95)
	style.border_color = Color(0.0, 0.7, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(280, 0)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "NEON MEMORIES"
	title.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var save_btn := Button.new()
	save_btn.text = "存檔"
	save_btn.custom_minimum_size = Vector2(0, 48)
	save_btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	save_btn.pressed.connect(func():
		SaveManager.save_game(1)
		popup_layer.queue_free()
	)
	vbox.add_child(save_btn)

	var main_menu_btn := Button.new()
	main_menu_btn.text = "回到主選單"
	main_menu_btn.custom_minimum_size = Vector2(0, 48)
	main_menu_btn.add_theme_color_override("font_color", Color(0.9, 0.5, 0.0))
	main_menu_btn.pressed.connect(func():
		popup_layer.queue_free()
		await SceneManager.change_scene("main_menu")
	)
	vbox.add_child(main_menu_btn)

	var resume_btn := Button.new()
	resume_btn.text = "繼續遊戲"
	resume_btn.custom_minimum_size = Vector2(0, 48)
	resume_btn.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	resume_btn.pressed.connect(popup_layer.queue_free)
	vbox.add_child(resume_btn)

	margin.add_child(vbox)
	panel.add_child(margin)
	popup_layer.add_child(panel)
	add_child(popup_layer)
