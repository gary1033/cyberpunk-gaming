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
	GameManager.new_game()
	SceneManager.change_scene_with_chapter_title(
		"detective_office", 1, "失蹤的記憶"
	)

func _on_continue() -> void:
	if SaveManager.load_game(1):
		var location := GameManager.current_location
		SceneManager.change_scene(location)

func _on_settings() -> void:
	# TODO: Settings screen
	pass
