extends Control
## Main Menu - Title screen with responsive layout for desktop and mobile.

@onready var new_game_btn: Button = $TitleContainer/NewGameButton
@onready var continue_btn: Button = $TitleContainer/ContinueButton
@onready var controls_btn: Button = $TitleContainer/ControlsButton
@onready var settings_btn: Button = $TitleContainer/SettingsButton
@onready var title_label: Label = $TitleContainer/Title
@onready var subtitle_label: Label = $TitleContainer/Subtitle

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)

	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	controls_btn.pressed.connect(_on_controls)
	settings_btn.pressed.connect(_on_settings)

	# Check for save files
	continue_btn.disabled = not SaveManager.has_save(1)
	if continue_btn.disabled:
		continue_btn.modulate.a = 0.4

	# Adapt for mobile
	_adapt_layout()

	# Title animation
	_animate_title()

func _adapt_layout() -> void:
	if InputManager.is_mobile:
		title_label.add_theme_font_size_override("font_size", 36)
		subtitle_label.add_theme_font_size_override("font_size", 14)

		# Larger buttons for touch
		for btn in [new_game_btn, continue_btn, controls_btn, settings_btn]:
			btn.custom_minimum_size = Vector2(0, 60)

func _animate_title() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	new_game_btn.modulate.a = 0.0
	continue_btn.modulate.a = 0.0
	controls_btn.modulate.a = 0.0
	settings_btn.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.3)
	tween.tween_property(new_game_btn, "modulate:a", 1.0, 0.3)
	tween.tween_property(continue_btn, "modulate:a", 1.0 if not continue_btn.disabled else 0.4, 0.3)
	tween.tween_property(controls_btn, "modulate:a", 1.0, 0.3)
	tween.tween_property(settings_btn, "modulate:a", 1.0, 0.3)

func _on_new_game() -> void:
	# Disable buttons to prevent double-click during transition
	new_game_btn.disabled = true
	continue_btn.disabled = true
	controls_btn.disabled = true
	settings_btn.disabled = true

	GameManager.new_game()
	await SceneManager.change_scene_with_chapter_title(
		"detective_office", 1, "失蹤的記憶"
	)

func _on_continue() -> void:
	if SaveManager.load_game(1):
		new_game_btn.disabled = true
		continue_btn.disabled = true
		controls_btn.disabled = true
		settings_btn.disabled = true
		var location := GameManager.current_location
		await SceneManager.change_scene(location)

func _on_controls() -> void:
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
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_width := minf(760.0, viewport_size.x * 0.92)
	panel.custom_minimum_size = Vector2(panel_width, 0)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(panel_width - 88.0, minf(460.0, maxf(240.0, viewport_size.y - 120.0)))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "操作說明"
	title.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Desktop or mobile controls
	if InputManager.is_mobile:
		_add_section(vbox, "觸控操作")
		_add_control_row(vbox, "互動", "點擊物件")
		_add_control_row(vbox, "鷹眼模式", "畫面上的切換按鈕")
		_add_control_row(vbox, "縮放場景", "雙指捏合")
		_add_control_row(vbox, "長按檢視", "長按 0.5 秒")
		_add_control_row(vbox, "提示", "提示按鈕（閃爍可互動物件）")
	else:
		_add_section(vbox, "鍵盤 + 滑鼠")
		_add_control_row(vbox, "互動 / 推進對話", "滑鼠左鍵")
		_add_control_row(vbox, "鷹眼模式", "E")
		_add_control_row(vbox, "證據板", "Tab")
		_add_control_row(vbox, "物品欄", "I")
		_add_control_row(vbox, "對話加速", "長按滑鼠左鍵")
		_add_control_row(vbox, "跳過打字效果", "點擊滑鼠左鍵")

	_add_section(vbox, "遊戲系統")
	_add_control_row(vbox, "場景移動", "地圖按鈕，消耗 1 行動點")
	_add_control_row(vbox, "鷹眼能量", "啟動後持續消耗，關閉後自動回充")
	_add_control_row(vbox, "審訊生物指標", "鷹眼模式下讀取心率與說謊機率")

	var close_btn := Button.new()
	close_btn.text = "返回"
	close_btn.custom_minimum_size = Vector2(0, 48)
	close_btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	close_btn.pressed.connect(popup_layer.queue_free)
	vbox.add_child(close_btn)

	scroll.add_child(vbox)
	margin.add_child(scroll)
	panel.add_child(margin)
	_add_centered_popup_panel(popup_layer, panel)
	add_child(popup_layer)

func _add_section(parent: VBoxContainer, text: String) -> void:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	parent.add_child(sep)
	var lbl := Label.new()
	lbl.text = "[ %s ]" % text
	lbl.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6))
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(lbl)

func _add_control_row(parent: VBoxContainer, action: String, key: String) -> void:
	var compact := get_viewport().get_visible_rect().size.x < 560.0
	var row: BoxContainer
	if compact:
		row = VBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
	else:
		row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 24)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var action_lbl := Label.new()
	action_lbl.text = action
	action_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	action_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not compact:
		action_lbl.custom_minimum_size = Vector2(180, 0)
	row.add_child(action_lbl)

	var key_lbl := Label.new()
	key_lbl.text = key
	key_lbl.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	key_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if compact else HORIZONTAL_ALIGNMENT_RIGHT
	key_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not compact:
		key_lbl.custom_minimum_size = Vector2(260, 0)
	row.add_child(key_lbl)
	parent.add_child(row)

func _add_centered_popup_panel(popup_layer: CanvasLayer, panel: Control) -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.add_child(panel)
	popup_layer.add_child(center)

func _on_settings() -> void:
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
	var viewport_size := get_viewport().get_visible_rect().size
	panel.custom_minimum_size = Vector2(minf(350.0, viewport_size.x * 0.9), 0)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)

	var title := Label.new()
	title.text = "設定"
	title.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Window Mode
	var window_label := Label.new()
	window_label.text = "視窗模式"
	window_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(window_label)

	var _status_label := Label.new()
	_status_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.2))
	_status_label.add_theme_font_size_override("font_size", 12)
	_status_label.visible = false
	vbox.add_child(_status_label)

	var window_options := OptionButton.new()
	window_options.add_item("視窗", 0)
	window_options.add_item("全螢幕", 1)
	window_options.add_item("無邊框全螢幕", 2)
	window_options.custom_minimum_size = Vector2(0, 36)
	window_options.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))

	var current_wm := DisplayServer.window_get_mode()
	if current_wm == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_options.selected = 1
	elif current_wm == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		window_options.selected = 2
	else:
		window_options.selected = 0

	var status_ref := _status_label
	window_options.item_selected.connect(func(idx: int):
		var prev_mode := DisplayServer.window_get_mode()
		match idx:
			0:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			1:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			2:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		# Check if mode actually changed (embedded window blocks this)
		var new_mode := DisplayServer.window_get_mode()
		if new_mode == prev_mode and idx != 0:
			status_ref.text = "嵌入式視窗不支援此模式，請關閉編輯器的嵌入式遊戲視窗"
			status_ref.visible = true
	)
	vbox.add_child(window_options)

	# Resolution
	var res_label := Label.new()
	res_label.text = "解析度"
	res_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(res_label)

	var res_options := OptionButton.new()
	var resolutions := [
		Vector2i(960, 540),
		Vector2i(1024, 576),
		Vector2i(1280, 720),
		Vector2i(1366, 768),
		Vector2i(1600, 900),
		Vector2i(1920, 1080),
	]
	var current_size := DisplayServer.window_get_size()
	var selected_idx := 2  # default 1280x720
	for i in resolutions.size():
		var r: Vector2i = resolutions[i]
		res_options.add_item("%d x %d" % [r.x, r.y], i)
		if r == current_size:
			selected_idx = i
	res_options.selected = selected_idx
	res_options.custom_minimum_size = Vector2(0, 36)
	res_options.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	res_options.item_selected.connect(func(idx: int):
		var r: Vector2i = resolutions[idx]
		DisplayServer.window_set_size(r)
		var screen_size := DisplayServer.screen_get_size()
		var pos := Vector2i((screen_size.x - r.x) / 2, (screen_size.y - r.y) / 2)
		DisplayServer.window_set_position(pos)
	)
	vbox.add_child(res_options)

	# BGM Volume
	var bgm_label := Label.new()
	bgm_label.text = "背景音樂"
	bgm_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(bgm_label)
	var bgm_slider := HSlider.new()
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.05
	bgm_slider.value = AudioManager.bgm_volume
	bgm_slider.custom_minimum_size = Vector2(0, 30)
	bgm_slider.value_changed.connect(func(val: float): AudioManager.set_bgm_volume(val))
	vbox.add_child(bgm_slider)

	# SFX Volume
	var sfx_label := Label.new()
	sfx_label.text = "音效"
	sfx_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(sfx_label)
	var sfx_slider := HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = AudioManager.sfx_volume
	sfx_slider.custom_minimum_size = Vector2(0, 30)
	sfx_slider.value_changed.connect(func(val: float): AudioManager.set_sfx_volume(val))
	vbox.add_child(sfx_slider)

	# Close button
	var close_btn := Button.new()
	close_btn.text = "返回"
	close_btn.custom_minimum_size = Vector2(0, 48)
	close_btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	close_btn.pressed.connect(popup_layer.queue_free)
	vbox.add_child(close_btn)

	var scroll := ScrollContainer.new()
	var max_scroll_height: float = minf(440.0, maxf(220.0, viewport_size.y - 120.0))
	scroll.custom_minimum_size = Vector2(0, max_scroll_height)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	margin.add_child(scroll)
	panel.add_child(margin)
	_add_centered_popup_panel(popup_layer, panel)
	add_child(popup_layer)
