extends Node2D

const RuntimeAssetsScript = preload("res://scripts/core/runtime_assets.gd")
## LocationBase - Base script for all location scenes.
## Sets up common UI elements: dialogue box, HUD, map button, hint button.

@export var location_id: String = ""
@export var location_name: String = ""
@export var bg_color: Color = Color(0.05, 0.05, 0.12)

const UI_SPRITE_DIR := "res://assets/sprites/ui"
const SegmentedEnergyBarScript: GDScript = preload("res://scripts/ui/segmented_energy_bar.gd")
const HUD_ENERGY_BAR_RECT := Rect2(-536.0, 20.0, 512.0, 96.0)
const DIALOGUE_FRAME_SOURCE_SIZE := Vector2(1280.0, 280.0)
const DIALOGUE_FRAME_OFFSET := Vector2(0.0, -18.0)
const DIALOGUE_PORTRAIT_RECT := Rect2(68.0, 42.0, 252.0, 150.0)
const DIALOGUE_NAME_RECT := Rect2(68.0, 192.0, 252.0, 26.0)
const DIALOGUE_BLUE_CONTENT_RECT := Rect2(370.0, 44.0, 834.0, 184.0)
const MEI_LING_EAGLE_EYE_VARIANT := "res://assets/sprites/locations/mei_ling_apartment_eye_scan_variant.png"
const MEI_LING_FAMILY_MEMORY_VARIANT := "res://assets/sprites/locations/mei_ling_apartment_family_memory_variant.png"
const FAMILY_MEMORY_FRAGMENT_SFX := "res://assets/audio/sfx/family_memory_fragment.ogg"
const BROKEN_PLAYER_SCAN_SFX := "res://assets/audio/sfx/broken_player_scan.ogg"
const STORY_CG_DIR := "res://assets/sprites/cg"
const EAGLE_EYE_ANOMALY_ACTIONS := {
	"review_family_memory_clip": true,
	"inspect_original_backup_album": true,
	"scan_broken_memory_player": true,
	"decode_eye_signature": true,
	"decode_hao_ran_last_message": true,
	"consult_dr_chen_eye_warning": true,
	"inspect_eleven_pm_call_log": true,
	"review_east_district_camera_gap": true,
	"visit_dr_chen_clinic": true,
	"compile_ch1_three_evidence_inference": true,
}
const CaseDataScript: GDScript = preload("res://scripts/data/case_data.gd")
const DialogueDataScript: GDScript = preload("res://scripts/data/dialogue_data.gd")

var _augmented_vision: CanvasLayer = null
var _background_texture_rect: TextureRect = null
var _base_background_texture: Texture2D = null
var _eagle_eye_background_texture: Texture2D = null
var _family_memory_background_texture: Texture2D = null
var _ap_widget: Control = null
var _ap_status_bar: SegmentedEnergyBarScript = null
var _ap_label: Label = null
var _scan_markers: Array[Button] = []

func _ready() -> void:
	AudioManager.play_location_bgm(location_id)
	_setup_background()
	_setup_ui()
	_setup_augmented_vision()
	_setup_scan_markers()
	_trigger_initial_dialogue()

func _setup_scan_markers() -> void:
	if _base_background_texture == null:
		set_process(false)
		return
	var layer := CanvasLayer.new()
	layer.name = "ScanMarkers"
	layer.layer = 51
	for action in _get_location_story_actions():
		if not action.has("scan_position"):
			continue
		var marker := Button.new()
		marker.name = "Scan_" + str(action.id)
		marker.text = "掃描"
		marker.tooltip_text = str(action.title)
		marker.custom_minimum_size = Vector2(72, 48)
		marker.add_theme_font_size_override("font_size", 18)
		marker.add_theme_color_override("font_color", Color("66cbb9"))
		marker.set_meta("action", action)
		marker.visible = false
		marker.pressed.connect(func():
			if GameManager.eagle_eye_active and not SceneManager.is_transitioning():
				_run_story_action(action)
		)
		layer.add_child(marker)
		_scan_markers.append(marker)
	if _scan_markers.is_empty():
		layer.free()
	else:
		add_child(layer)
	set_process(not _scan_markers.is_empty())

func _process(_delta: float) -> void:
	var available := _get_available_story_actions()
	var viewport_size := get_viewport_rect().size
	for marker in _scan_markers:
		var action: Dictionary = marker.get_meta("action")
		marker.visible = GameManager.eagle_eye_active and GameManager.current_state == GameManager.GameState.PLAYING and not SceneManager.is_transitioning() and action in available
		if not marker.visible:
			continue
		var point := Vector2(action.scan_position[0], action.scan_position[1])
		# Match the background's aspect-cover transform, including narrow windows.
		var source_size := _base_background_texture.get_size()
		var scale_factor := maxf(viewport_size.x / source_size.x, viewport_size.y / source_size.y)
		marker.position = point * source_size * scale_factor + (viewport_size - source_size * scale_factor) * 0.5 - marker.size * 0.5
		marker.text = "重看" if GameManager.get_dialogue_flag(action.scan_flag) else "掃描"

func _setup_background() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = -10

	var bg_texture := _load_location_background()

	if bg_texture:
		var bg_img := TextureRect.new()
		bg_img.texture = bg_texture
		bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		canvas.add_child(bg_img)
		_background_texture_rect = bg_img
		_base_background_texture = bg_texture
		_eagle_eye_background_texture = RuntimeAssetsScript.load_texture(_get_eagle_eye_background_variant_path())
		_family_memory_background_texture = RuntimeAssetsScript.load_texture(_get_family_memory_background_variant_path())
	else:
		var bg := ColorRect.new()
		bg.color = bg_color
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		canvas.add_child(bg)

	add_child(canvas)

func _load_location_background() -> Texture2D:
	var bg_path := "res://assets/sprites/locations/%s.png" % location_id
	return RuntimeAssetsScript.load_texture(bg_path)

func _get_eagle_eye_background_variant_path() -> String:
	if location_id == "mei_ling_apartment":
		return MEI_LING_EAGLE_EYE_VARIANT
	return "res://assets/sprites/locations/%s_eye_scan_variant.png" % location_id

func _get_family_memory_background_variant_path() -> String:
	if location_id == "mei_ling_apartment":
		return MEI_LING_FAMILY_MEMORY_VARIANT
	return ""

func _load_ui_texture(asset_name: String) -> Texture2D:
	return RuntimeAssetsScript.load_texture("%s/%s.png" % [UI_SPRITE_DIR, asset_name])

func _setup_augmented_vision() -> void:
	var AugmentedVisionScript: GDScript = load("res://scripts/gameplay/augmented_vision.gd")
	_augmented_vision = AugmentedVisionScript.new()
	_augmented_vision.name = "AugmentedVision"
	add_child(_augmented_vision)
	if _augmented_vision.has_signal("eagle_eye_activated"):
		_augmented_vision.eagle_eye_activated.connect(func():
			_set_eagle_eye_background_active(true)
			_set_ap_widget_visible(false)
		)
	if _augmented_vision.has_signal("eagle_eye_deactivated"):
		_augmented_vision.eagle_eye_deactivated.connect(func():
			_set_eagle_eye_background_active(false)
			_set_ap_widget_visible(true)
		)
	_set_eagle_eye_background_active(GameManager.eagle_eye_active)
	_set_ap_widget_visible(not GameManager.eagle_eye_active)

func _set_eagle_eye_background_active(active: bool) -> void:
	if not _background_texture_rect:
		return
	if active and _eagle_eye_background_texture:
		_background_texture_rect.texture = _eagle_eye_background_texture
	else:
		_background_texture_rect.texture = _base_background_texture

func _set_ap_widget_visible(is_visible: bool) -> void:
	if _ap_widget:
		_ap_widget.visible = is_visible and GameManager.current_state != GameManager.GameState.DIALOGUE

func _create_generated_panel_style(asset_name: String, fallback_color: Color, border_color: Color, margin: int) -> StyleBox:
	var texture := _load_ui_texture(asset_name)
	if texture:
		var generated_style := StyleBoxTexture.new()
		generated_style.texture = texture
		generated_style.set_texture_margin_all(24)
		generated_style.set_content_margin_all(margin)
		return generated_style

	var flat_style := StyleBoxFlat.new()
	flat_style.bg_color = fallback_color
	flat_style.border_color = border_color
	flat_style.set_border_width_all(2)
	flat_style.set_corner_radius_all(8)
	flat_style.set_content_margin_all(margin)
	return flat_style

func _get_dialogue_frame_scale() -> Vector2:
	# Keep reading height and font size when the viewport becomes narrower.
	return Vector2(minf(get_viewport_rect().size.x / DIALOGUE_FRAME_SOURCE_SIZE.x, 1.0), 1.0)

func _apply_source_rect(control: Control, source_rect: Rect2, frame_scale: Vector2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = source_rect.position * frame_scale
	control.size = source_rect.size * frame_scale

func _setup_ui() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 10
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	_setup_hud(ui_layer)
	_setup_toolbar(ui_layer)
	_setup_dialogue_system(ui_layer)

	# Update AP display when it changes
	GameManager.action_points_changed.connect(func(remaining: int):
		_update_ap_label(remaining)
	)

func _setup_hud(ui_layer: CanvasLayer) -> void:
	var hud := HBoxContainer.new()
	hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud.offset_bottom = 40
	hud.offset_left = 24
	hud.offset_top = 24
	hud.name = "HUD"

	var info_label := Label.new()
	info_label.text = "第%d章 | %s" % [GameManager.current_chapter, location_name]
	info_label.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9, 0.8))
	info_label.name = "LocationName"
	info_label.add_theme_font_size_override("font_size", 20)
	info_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	info_label.add_theme_constant_override("shadow_offset_x", 2)
	info_label.add_theme_constant_override("shadow_offset_y", 2)
	hud.add_child(info_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.add_child(spacer)

	ui_layer.add_child(hud)

	_ap_widget = _create_ap_widget()
	_ap_widget.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_ap_widget.offset_left = HUD_ENERGY_BAR_RECT.position.x
	_ap_widget.offset_top = HUD_ENERGY_BAR_RECT.position.y
	_ap_widget.offset_right = HUD_ENERGY_BAR_RECT.position.x + HUD_ENERGY_BAR_RECT.size.x
	_ap_widget.offset_bottom = HUD_ENERGY_BAR_RECT.position.y + HUD_ENERGY_BAR_RECT.size.y
	ui_layer.add_child(_ap_widget)

func _setup_toolbar(ui_layer: CanvasLayer) -> void:
	var toolbar := HBoxContainer.new()
	toolbar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	toolbar.offset_top = -56
	toolbar.alignment = BoxContainer.ALIGNMENT_CENTER
	toolbar.add_theme_constant_override("separation", 20)
	toolbar.name = "Toolbar"

	var toolbar_texture := _load_ui_texture("toolbar_buttons")
	if toolbar_texture:
		var toolbar_backdrop := TextureRect.new()
		toolbar_backdrop.texture = toolbar_texture
		toolbar_backdrop.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		toolbar_backdrop.offset_top = -64
		toolbar_backdrop.offset_bottom = 0
		toolbar_backdrop.stretch_mode = TextureRect.STRETCH_SCALE
		toolbar_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui_layer.add_child(toolbar_backdrop)

	if not _get_location_story_actions().is_empty():
		var investigate_btn := _create_toolbar_button("調查", Color(1.0, 0.0, 0.6), Callable(self, "_show_story_actions"))
		toolbar.add_child(investigate_btn)

	var map_btn := _create_toolbar_button("地圖", Color(0.0, 0.9, 0.9), Callable(self, "_show_map"))
	toolbar.add_child(map_btn)

	var eye_btn := _create_toolbar_button("鷹眼", Color(0.9, 0.9, 0.0), Callable(self, "_toggle_eagle_eye"))
	toolbar.add_child(eye_btn)

	var board_btn := _create_toolbar_button("證據板", Color(0.0, 0.9, 0.9), Callable(self, "_open_evidence_board"))
	toolbar.add_child(board_btn)

	if InputManager.is_mobile:
		var HotspotScript: GDScript = load("res://scripts/gameplay/hotspot.gd")
		var hint_btn := _create_toolbar_button("提示", Color(0.5, 0.9, 0.5), func():
			HotspotScript.pulse_all_hotspots(get_tree())
			_hint_scan_markers()
		)
		toolbar.add_child(hint_btn)

	var menu_btn := _create_toolbar_button("選單", Color(0.5, 0.5, 0.5), Callable(self, "_show_pause_menu"))
	toolbar.add_child(menu_btn)

	ui_layer.add_child(toolbar)

func _create_toolbar_button(text: String, color: Color, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(80, 48)
	button.add_theme_color_override("font_color", color)
	button.pressed.connect(callback)
	return button

func _setup_dialogue_system(ui_layer: CanvasLayer) -> void:
	var dialogue_system := Control.new()
	dialogue_system.name = "DialogueSystem"
	dialogue_system.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_system.set_script(load("res://scripts/gameplay/dialogue_system.gd"))
	dialogue_system.add_to_group("dialogue_system")

	var dialogue_frame_scale := _get_dialogue_frame_scale()
	var dialogue_frame_size := DIALOGUE_FRAME_SOURCE_SIZE * dialogue_frame_scale

	var dialogue_frame_root := Control.new()
	dialogue_frame_root.name = "DialogueFrameRoot"
	dialogue_frame_root.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	dialogue_frame_root.offset_left = DIALOGUE_FRAME_OFFSET.x
	dialogue_frame_root.offset_right = DIALOGUE_FRAME_OFFSET.x + dialogue_frame_size.x
	dialogue_frame_root.offset_top = DIALOGUE_FRAME_OFFSET.y - dialogue_frame_size.y
	dialogue_frame_root.offset_bottom = DIALOGUE_FRAME_OFFSET.y
	dialogue_frame_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_system.add_child(dialogue_frame_root)

	var dialogue_frame_texture := TextureRect.new()
	dialogue_frame_texture.name = "DialogueFrameTexture"
	dialogue_frame_texture.texture = _load_ui_texture("dialogue_panel")
	dialogue_frame_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialogue_frame_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_frame_texture.stretch_mode = TextureRect.STRETCH_SCALE
	dialogue_frame_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_frame_root.add_child(dialogue_frame_texture)

	var portrait_left := TextureRect.new()
	portrait_left.name = "PortraitLeft"
	_apply_source_rect(portrait_left, DIALOGUE_PORTRAIT_RECT, dialogue_frame_scale)
	portrait_left.custom_minimum_size = DIALOGUE_PORTRAIT_RECT.size * dialogue_frame_scale
	portrait_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_left.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_left.clip_contents = true
	portrait_left.z_index = 2
	portrait_left.visible = false
	dialogue_frame_root.add_child(portrait_left)

	var portrait_right := TextureRect.new()
	portrait_right.name = "PortraitRight"
	_apply_source_rect(portrait_right, DIALOGUE_PORTRAIT_RECT, dialogue_frame_scale)
	portrait_right.custom_minimum_size = DIALOGUE_PORTRAIT_RECT.size * dialogue_frame_scale
	portrait_right.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_right.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_right.clip_contents = true
	portrait_right.z_index = 2
	portrait_right.visible = false
	dialogue_frame_root.add_child(portrait_right)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	_apply_source_rect(name_label, DIALOGUE_NAME_RECT, dialogue_frame_scale)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.z_index = 4
	name_label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6))
	name_label.add_theme_font_size_override("font_size", 18)
	dialogue_frame_root.add_child(name_label)

	# Dialogue panel content is positioned in the source image's blue frame.
	var dialogue_panel := Control.new()
	dialogue_panel.name = "DialoguePanel"
	_apply_source_rect(dialogue_panel, DIALOGUE_BLUE_CONTENT_RECT, dialogue_frame_scale)
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	dialogue_panel.clip_contents = true

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)

	var dialogue_text := RichTextLabel.new()
	dialogue_text.name = "DialogueText"
	dialogue_text.bbcode_enabled = true
	dialogue_text.fit_content = false
	dialogue_text.clip_contents = true
	dialogue_text.scroll_active = false
	dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_text.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9))
	dialogue_text.add_theme_font_size_override("normal_font_size", 24 if not InputManager.is_mobile else 20)
	dialogue_text.custom_minimum_size = Vector2(0, 106 if not InputManager.is_mobile else 76)
	vbox.add_child(dialogue_text)

	var choices_container := VBoxContainer.new()
	choices_container.name = "ChoicesContainer"
	choices_container.add_theme_constant_override("separation", 5)
	choices_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices_container.visible = false
	var choices_scroll := ScrollContainer.new()
	choices_scroll.name = "ChoicesScroll"
	choices_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	choices_scroll.follow_focus = true
	choices_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choices_scroll.visible = false
	choices_scroll.add_child(choices_container)
	vbox.add_child(choices_scroll)

	var continue_indicator := Label.new()
	continue_indicator.name = "ContinueIndicator"
	continue_indicator.text = "▼"
	continue_indicator.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9, 0.7))
	continue_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	continue_indicator.visible = false
	vbox.add_child(continue_indicator)

	var dialogue_margin := MarginContainer.new()
	dialogue_margin.name = "DialogueContentMargin"
	dialogue_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_margin.add_theme_constant_override("margin_left", 0)
	dialogue_margin.add_theme_constant_override("margin_right", 0)
	dialogue_margin.add_theme_constant_override("margin_top", 0)
	dialogue_margin.add_theme_constant_override("margin_bottom", 0)
	dialogue_margin.add_child(vbox)

	dialogue_panel.add_child(dialogue_margin)
	dialogue_frame_root.add_child(dialogue_panel)

	ui_layer.add_child(dialogue_system)

func _update_ap_label(remaining: int) -> void:
	if _ap_label:
		_ap_label.text = "AP: %d/%d" % [remaining, GameManager.max_action_points]
	_update_ap_status_bar(remaining)

func _update_ap_status_bar(remaining: int) -> void:
	if _ap_status_bar:
		_ap_status_bar.set_energy(float(remaining), float(GameManager.max_action_points))

func _create_ap_widget() -> Control:
	var widget := Control.new()
	widget.name = "APWidget"
	widget.custom_minimum_size = HUD_ENERGY_BAR_RECT.size

	_ap_status_bar = SegmentedEnergyBarScript.new()
	_ap_status_bar.name = "APStatusBar"
	_ap_status_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ap_status_bar.stretch_mode = TextureRect.STRETCH_SCALE
	_ap_status_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	widget.add_child(_ap_status_bar)

	_ap_label = Label.new()
	_ap_label.name = "APLabel"
	_ap_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ap_label.offset_left = 24
	_ap_label.offset_right = -32
	_ap_label.offset_top = 8
	_ap_label.offset_bottom = 40
	_ap_label.add_theme_color_override("font_color", Color(0.95, 0.66, 0.05))
	_ap_label.add_theme_font_size_override("font_size", 18)
	_ap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ap_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_update_ap_label(GameManager.action_points)
	widget.add_child(_ap_label)
	GameManager.game_state_changed.connect(func(_state: String):
		_set_ap_widget_visible(not GameManager.eagle_eye_active)
	)
	return widget

func _trigger_initial_dialogue() -> void:
	var chapter_data: Dictionary = CaseDataScript.get_chapter_data(GameManager.current_chapter)
	var loc_data: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	var initial_dialogue: String = loc_data.get("initial_dialogue", "")

	if initial_dialogue != "" and not GameManager.get_dialogue_flag("visited_" + location_id):
		GameManager.set_dialogue_flag("visited_" + location_id)
		var dialogue_entries: Array = DialogueDataScript.get_dialogue(initial_dialogue)
		if dialogue_entries.size() > 0:
			await get_tree().process_frame
			var ds := get_tree().get_first_node_in_group("dialogue_system")
			if ds and ds.has_method("start_dialogue"):
				ds.start_dialogue(dialogue_entries)

func _get_location_story_actions() -> Array:
	var chapter_data: Dictionary = CaseDataScript.get_chapter_data(GameManager.current_chapter)
	var loc_data: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	return loc_data.get("story_actions", [])

func _get_available_story_actions() -> Array:
	var available: Array = []
	for action in _get_location_story_actions():
		var action_data: Dictionary = action
		var hide_after_flag: String = action_data.get("hide_after_flag", "")
		if hide_after_flag != "" and GameManager.get_dialogue_flag(hide_after_flag):
			continue

		if not GameManager.meets_story_conditions(action_data):
			continue
		if action_data.get("use_calculated_ending", false) and GameManager.calculate_ending() == "":
			continue

		available.append(action_data)
	return available

func _create_popup_layer(dim_alpha: float) -> CanvasLayer:
	var popup_layer := CanvasLayer.new()
	popup_layer.layer = 95

	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, dim_alpha)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup_layer.add_child(dimmer)

	return popup_layer

func _create_popup_content(popup_layer: CanvasLayer, min_width: float, border_color: Color, title_text: String, title_color: Color) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(
		"panel",
		_create_generated_panel_style("popup_panel", Color(0.05, 0.05, 0.15, 0.95), border_color, 20)
	)
	var viewport_size := get_viewport_rect().size
	panel.custom_minimum_size = Vector2(minf(maxf(min_width, 480.0), viewport_size.x - 48.0), 0)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = title_text
	title.add_theme_color_override("font_color", title_color)
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	margin.add_child(scroll)
	panel.add_child(margin)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.add_child(panel)
	popup_layer.add_child(center)
	vbox.minimum_size_changed.connect(func():
		panel.custom_minimum_size.y = minf(vbox.get_combined_minimum_size().y + 120.0, viewport_size.y - 48.0)
	)

	return vbox

func _create_popup_button(text: String, color: Color, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.add_theme_color_override("font_color", color)
	button.pressed.connect(callback)
	return button

func _show_story_actions(message: String = "") -> void:
	if SceneManager.is_transitioning() or GameManager.current_state != GameManager.GameState.PLAYING:
		return
	var existing := get_node_or_null("StoryActions")
	if existing != null and not existing.is_queued_for_deletion():
		return
	var actions := _get_available_story_actions()

	var popup_layer := _create_popup_layer(0.6)
	popup_layer.name = "StoryActions"
	var vbox := _create_popup_content(popup_layer, 320.0, Color(1.0, 0.0, 0.6), "調查", Color(1.0, 0.0, 0.6))
	var branch_hint := GameManager.get_chapter_branch_hint()
	if not branch_hint.is_empty():
		var route_label := Label.new()
		route_label.text = branch_hint
		route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		route_label.add_theme_font_size_override("font_size", 18)
		vbox.add_child(route_label)
	if not message.is_empty():
		var notice := Label.new()
		notice.text = message
		notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(notice)

	if actions.is_empty():
		var empty_label := Label.new()
		empty_label.text = "目前沒有新的調查行動"
		empty_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_label)
	else:
		for action in actions:
			var action_data: Dictionary = action
			var title := str(action_data.get("title", "調查"))
			if action_data.has("scan_flag"):
				title += "（已保存）" if GameManager.get_dialogue_flag(action_data.scan_flag) else "（鷹眼 %d 能量）" % int(action_data.scan_cost)
			var btn := _create_popup_button(title, Color(0.0, 0.9, 0.9), func():
				popup_layer.queue_free()
				_run_story_action(action_data)
			)
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.0, 0.6))
			vbox.add_child(btn)

	var journal_btn := _create_popup_button("查看已保存的鷹眼紀錄", Color("edc66c"), func():
		popup_layer.queue_free()
		_show_scan_journal()
	)
	vbox.add_child(journal_btn)
	var close_btn := _create_popup_button("取消", Color(0.5, 0.5, 0.5), Callable(popup_layer, "queue_free"))
	vbox.add_child(close_btn)

	add_child(popup_layer)

func _hint_scan_markers() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING or SceneManager.is_transitioning():
		return
	var shown := false
	for marker in _scan_markers:
		if not marker.visible:
			continue
		shown = true
		var tween := marker.create_tween()
		tween.tween_property(marker, "self_modulate", Color("edc66c"), 0.25)
		tween.tween_property(marker, "self_modulate", Color.WHITE, 0.25)
	if not shown:
		_show_story_actions("開啟鷹眼可查看場景上的掃描標記；也可直接選擇下方調查。")

func _show_scan_journal() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING or SceneManager.is_transitioning() or get_node_or_null("ScanJournal") != null:
		return
	if GameManager.eagle_eye_active:
		_augmented_vision._deactivate()
	var journal := _create_popup_layer(0.75)
	journal.name = "ScanJournal"
	var content := _create_popup_content(journal, 560.0, Color("66cbb9"), "鷹眼紀錄｜回看不耗能", Color("66cbb9"))
	var count := 0
	for chapter in [1, 2, 3]:
		for location in CaseDataScript.get_chapter_data(chapter).locations.values():
			for action in location.get("story_actions", []):
				if not action.has("scan_summary") or not GameManager.get_dialogue_flag(action.get("scan_flag", "")):
					continue
				count += 1
				var reading := Label.new()
				reading.text = "第%d章・%s\n%s\n%s" % [chapter, location.name, action.title, action.scan_summary]
				reading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				reading.add_theme_font_size_override("font_size", 20)
				content.add_child(reading)
				content.add_child(HSeparator.new())
	if count == 0:
		var empty := Label.new()
		empty.text = "還沒有掃描紀錄。先在場景或調查清單中完成一次掃描。"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(empty)
	content.add_child(_create_popup_button("返回調查", Color("66cbb9"), func():
		journal.queue_free()
		_show_story_actions()
	))
	add_child(journal)

func _run_story_action(action_data: Dictionary) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING or action_data not in _get_available_story_actions():
		return
	var scan_flag: String = action_data.get("scan_flag", "")
	if not scan_flag.is_empty() and not GameManager.get_dialogue_flag(scan_flag):
		var was_active := GameManager.eagle_eye_active
		if not GameManager.perform_eagle_eye_scan(float(action_data.get("scan_cost", 20.0))):
			_show_story_actions("鷹眼能量不足。關閉鷹眼等待充能，再重試；調查進度不會消失。")
			return
		if was_active and not GameManager.eagle_eye_active:
			_augmented_vision._deactivate()
		GameManager.set_dialogue_flag(scan_flag)
		_augmented_vision.trigger_glitch_pulse()
	var flag: String = action_data.get("set_flag", "")
	if flag != "":
		GameManager.set_dialogue_flag(flag)

	var flags: Array = action_data.get("set_flags", [])
	for flag_id in flags:
		GameManager.set_dialogue_flag(str(flag_id))

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

	_trigger_eagle_eye_anomaly(action_data)
	_show_story_cg(action_data.get("story_cg", ""))

	var dialogue_entries: Array = DialogueDataScript.get_dialogue(dialogue_id)
	if dialogue_entries.is_empty():
		return
	if action_data.get("show_ending_requirements", false):
		var status_entries: Array = []
		var ending_titles := {"ending_a_justice": "正義之光", "ending_b_grey_deal": "灰色交易", "ending_c_memory_rebirth": "記憶重生"}
		for ending_id in ending_titles:
			var missing := GameManager.get_ending_requirements(ending_id)
			var status_text: String = ending_titles[ending_id] + "："
			status_text += "已準備就緒。" if missing.is_empty() else "尚需" + "、".join(missing) + "。"
			status_entries.append({"speaker": "narrator", "text": status_text})
		status_entries.append_array(dialogue_entries)
		dialogue_entries = status_entries

	var ds := get_tree().get_first_node_in_group("dialogue_system")
	if ds and ds.has_method("start_dialogue"):
		if action_data.get("use_calculated_ending", false) and not GameManager.get_dialogue_flag("case_resolved"):
			ds.dialogue_ended.connect(GameManager.complete_case.bind(dialogue_id), CONNECT_ONE_SHOT)
		ds.start_dialogue(dialogue_entries)

func _trigger_eagle_eye_anomaly(action_data: Dictionary) -> void:
	var action_id: String = action_data.get("id", "")
	if not EAGLE_EYE_ANOMALY_ACTIONS.has(action_id):
		return
	if action_id == "review_family_memory_clip":
		_show_family_memory_variant()
		_play_optional_sfx(FAMILY_MEMORY_FRAGMENT_SFX)
	elif action_id == "scan_broken_memory_player":
		_play_optional_sfx(BROKEN_PLAYER_SCAN_SFX)
	if _augmented_vision and _augmented_vision.has_method("trigger_glitch_pulse"):
		_augmented_vision.trigger_glitch_pulse()

func _play_optional_sfx(path: String) -> void:
	if AudioManager and AudioManager.has_method("play_optional_sfx"):
		AudioManager.play_optional_sfx(path)

func _show_story_cg(cg_id: String) -> void:
	if cg_id == "":
		return
	var texture := RuntimeAssetsScript.load_texture("%s/%s.png" % [STORY_CG_DIR, cg_id])
	if texture == null:
		return
	var cg_layer := CanvasLayer.new()
	cg_layer.layer = 5
	cg_layer.name = "StoryCG_%s" % cg_id
	var cg_view := TextureRect.new()
	cg_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg_view.texture = texture
	cg_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	cg_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cg_view.modulate = Color(1, 1, 1, 0.88)
	cg_layer.add_child(cg_view)
	add_child(cg_layer)
	var tween := cg_layer.create_tween()
	tween.tween_interval(4.0)
	tween.tween_callback(cg_layer.queue_free)

func _show_family_memory_variant() -> void:
	if not _background_texture_rect or not _family_memory_background_texture:
		return
	_background_texture_rect.texture = _family_memory_background_texture
	var tween := create_tween()
	tween.tween_interval(3.2)
	tween.tween_callback(func():
		if not _background_texture_rect:
			return
		if GameManager.eagle_eye_active and _eagle_eye_background_texture:
			_background_texture_rect.texture = _eagle_eye_background_texture
		else:
			_background_texture_rect.texture = _base_background_texture
	)

func _show_map(message: String = "") -> void:
	if SceneManager.is_transitioning() or GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if get_node_or_null("LocationMap") != null:
		return
	var chapter_data: Dictionary = CaseDataScript.get_chapter_data(GameManager.current_chapter)
	var current_loc: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	var connections: Array = current_loc.get("connections", [])

	var popup_layer := _create_popup_layer(0.6)
	popup_layer.name = "LocationMap"
	var vbox := _create_popup_content(popup_layer, 380.0, Color(0.0, 0.7, 0.7), "前往目的地", Color(0.0, 0.9, 0.9))
	var ap_label := Label.new()
	ap_label.text = "行動力 %d / %d｜移動消耗 1 點\n休整可補滿行動力，保留調查進度。" % [GameManager.action_points, GameManager.max_action_points]
	if GameManager.current_chapter == 2 and GameManager.get_dialogue_flag("ghost_identity_resolved") and not GameManager.get_dialogue_flag("ghost_followup_resolved"):
		ap_label.text += "\n幽靈的離線約定尚未處理；離開本章後無法回訪。"
	ap_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(ap_label)
	if not message.is_empty():
		var status_label := Label.new()
		status_label.text = message
		status_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
		vbox.add_child(status_label)

	for conn_id in connections:
		var target_location_id := str(conn_id)
		var loc: Dictionary = chapter_data.get("locations", {}).get(target_location_id, {})
		if loc.is_empty() or not GameManager.meets_story_conditions(loc):
			continue

		var btn := _create_popup_button(str(loc.get("name", target_location_id)), Color(0.0, 0.9, 0.9), _travel_from_map.bind(target_location_id, popup_layer))
		btn.disabled = GameManager.action_points < 1
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.0, 0.6))
		vbox.add_child(btn)
		var scan_count := 0
		for action in loc.get("story_actions", []):
			if action.has("scan_flag") and not GameManager.get_dialogue_flag(action.scan_flag):
				scan_count += 1
		if scan_count > 0:
			var scan_note := Label.new()
			scan_note.text = "鷹眼調查 %d 處未掃描（部分需先取得線索）" % scan_count
			scan_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			scan_note.add_theme_font_size_override("font_size", 16)
			scan_note.add_theme_color_override("font_color", Color("66cbb9"))
			vbox.add_child(scan_note)

	var rest_btn := _create_popup_button("休整（恢復全部行動力）", Color(0.5, 0.9, 0.6), _rest_from_map.bind(popup_layer))
	rest_btn.disabled = GameManager.action_points >= GameManager.max_action_points
	vbox.add_child(rest_btn)
	if GameManager.can_advance_chapter():
		var next_chapter: Dictionary = CaseDataScript.get_chapter_data(GameManager.current_chapter + 1)
		var chapter_btn := _create_popup_button("前往下一章：%s" % str(next_chapter.get("title", "")), Color(1.0, 0.8, 0.3), _advance_chapter_from_map.bind(popup_layer))
		vbox.add_child(chapter_btn)

	var close_btn := _create_popup_button("取消", Color(0.5, 0.5, 0.5), Callable(popup_layer, "queue_free"))
	vbox.add_child(close_btn)

	add_child(popup_layer)

func _travel_from_map(target_location_id: String, popup_layer: CanvasLayer) -> void:
	if not is_instance_valid(popup_layer) or popup_layer.is_queued_for_deletion() or SceneManager.is_transitioning():
		return
	popup_layer.queue_free()
	if not SceneManager.transition_failed.is_connected(_on_map_transition_failed):
		SceneManager.transition_failed.connect(_on_map_transition_failed, CONNECT_ONE_SHOT)
	SceneManager.travel_to_location(target_location_id)

func _rest_from_map(popup_layer: CanvasLayer) -> void:
	if not is_instance_valid(popup_layer) or popup_layer.is_queued_for_deletion() or SceneManager.is_transitioning():
		return
	if not GameManager.rest():
		return
	popup_layer.queue_free()
	await get_tree().process_frame
	_show_map("休整完成，可以繼續調查。")

func _advance_chapter_from_map(popup_layer: CanvasLayer) -> void:
	if not is_instance_valid(popup_layer) or popup_layer.is_queued_for_deletion() or SceneManager.is_transitioning():
		return
	if not GameManager.can_advance_chapter():
		return
	popup_layer.queue_free()
	if not SceneManager.transition_failed.is_connected(_on_map_transition_failed):
		SceneManager.transition_failed.connect(_on_map_transition_failed, CONNECT_ONE_SHOT)
	GameManager.advance_chapter()

func _on_map_transition_failed(_scene_name: String) -> void:
	await get_tree().process_frame
	_show_map("轉場未完成，行動力與調查進度已保留。")

func _toggle_eagle_eye() -> void:
	if _augmented_vision and _augmented_vision.has_method("toggle"):
		_augmented_vision.toggle()
	else:
		if GameManager.eagle_eye_active:
			GameManager.deactivate_eagle_eye()
		else:
			GameManager.activate_eagle_eye()

func _open_evidence_board() -> void:
	if SceneManager.is_transitioning() or GameManager.current_state != GameManager.GameState.PLAYING:
		return
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
	var popup_layer := _create_popup_layer(0.7)
	var vbox := _create_popup_content(popup_layer, 280.0, Color(0.0, 0.7, 0.7), "NEON MEMORIES", Color(0.0, 0.9, 0.9))
	var title := vbox.get_child(0) as Label
	if title:
		title.add_theme_font_size_override("font_size", 20)

	var save_btn := _create_popup_button("存檔", Color(0.0, 0.9, 0.9), func():
		SaveManager.save_game(1)
		popup_layer.queue_free()
	)
	save_btn.disabled = GameManager.current_state != GameManager.GameState.PLAYING or SceneManager.is_transitioning()
	if save_btn.disabled:
		save_btn.text = "對話／操作結束後才能存檔"
	vbox.add_child(save_btn)

	var main_menu_btn := _create_popup_button("回到主選單", Color(0.9, 0.5, 0.0), func():
		if popup_layer.is_queued_for_deletion() or SceneManager.is_transitioning():
			return
		popup_layer.queue_free()
		SceneManager.transition_failed.connect(_on_pause_transition_failed, CONNECT_ONE_SHOT)
		SceneManager.change_scene("main_menu")
	)
	vbox.add_child(main_menu_btn)

	var resume_btn := _create_popup_button("繼續遊戲", Color(0.5, 0.9, 0.5), Callable(popup_layer, "queue_free"))
	vbox.add_child(resume_btn)

	add_child(popup_layer)

func _on_pause_transition_failed(_scene_name: String) -> void:
	await get_tree().process_frame
	_show_pause_menu()
