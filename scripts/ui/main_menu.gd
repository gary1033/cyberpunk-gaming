extends Control
## Main Menu - Title screen with responsive layout for desktop and mobile.

@onready var new_game_btn: Button = $TitleContainer/NewGameButton
@onready var continue_btn: Button = $TitleContainer/ContinueButton
@onready var settings_btn: Button = $TitleContainer/SettingsButton
@onready var title_label: Label = $TitleContainer/Title
@onready var subtitle_label: Label = $TitleContainer/Subtitle

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)

	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
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
		for btn in [new_game_btn, continue_btn, settings_btn]:
			btn.custom_minimum_size = Vector2(0, 60)

func _animate_title() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	new_game_btn.modulate.a = 0.0
	continue_btn.modulate.a = 0.0
	settings_btn.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.3)
	tween.tween_property(new_game_btn, "modulate:a", 1.0, 0.3)
	tween.tween_property(continue_btn, "modulate:a", 1.0 if not continue_btn.disabled else 0.4, 0.3)
	tween.tween_property(settings_btn, "modulate:a", 1.0, 0.3)

func _on_new_game() -> void:
	# Disable buttons to prevent double-click during transition
	new_game_btn.disabled = true
	continue_btn.disabled = true
	settings_btn.disabled = true

	GameManager.new_game()
	await SceneManager.change_scene_with_chapter_title(
		"detective_office", 1, "失蹤的記憶"
	)

func _on_continue() -> void:
	if SaveManager.load_game(1):
		new_game_btn.disabled = true
		continue_btn.disabled = true
		settings_btn.disabled = true
		var location := GameManager.current_location
		await SceneManager.change_scene(location)

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
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(350, 0)

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

	margin.add_child(vbox)
	panel.add_child(margin)
	popup_layer.add_child(panel)
	add_child(popup_layer)
