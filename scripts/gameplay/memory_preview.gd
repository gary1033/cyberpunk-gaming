extends Control
## MemoryPreview - Mini-game where player views fragmented memory clips and selects key frames.
## Available in chapters 2 and 3.

signal memory_completed(evidence_id: String)
signal memory_failed

class_name MemoryPreview

const UI_SPRITE_DIR := "res://assets/sprites/ui"

var background: ColorRect = null
var generated_overlay: TextureRect = null
var fragment_display: RichTextLabel = null
var choices_container: HBoxContainer = null
var timer_bar: ProgressBar = null
var instruction_label: Label = null

var _fragments: Array = []
var _correct_fragment_index: int = 0
var _current_display_index: int = 0
var _is_playing: bool = false
var _display_timer: float = 0.0
var _display_duration: float = 2.0  # Seconds per fragment
var _result_evidence_id: String = ""

# Memory data format:
# {
#   "evidence_id": "hao_ran_sos",
#   "fragments": [
#     {"text": "一個黑暗的房間... 閃爍的螢幕...", "is_key": false},
#     {"text": "「救救我... 他們要覆寫我的記憶...」", "is_key": true},
#     {"text": "模糊的面孔... 白色實驗衣...", "is_key": false},
#     {"text": "一串數字在眼前閃過: 7749-ECHO", "is_key": false},
#   ]
# }

func _ready() -> void:
	visible = false

	# Resolve nodes safely for dynamic instantiation
	background = get_node_or_null("Background") as ColorRect
	fragment_display = get_node_or_null("FragmentDisplay") as RichTextLabel
	choices_container = get_node_or_null("ChoicesContainer") as HBoxContainer
	timer_bar = get_node_or_null("TimerBar") as ProgressBar
	instruction_label = get_node_or_null("InstructionLabel") as Label

	if instruction_label:
		instruction_label.text = "記憶碎片播放中... 選出關鍵畫面"

	_setup_generated_overlay()

func _setup_generated_overlay() -> void:
	var texture := _load_runtime_texture("%s/memory_preview_overlay.png" % UI_SPRITE_DIR)
	if not texture:
		return

	generated_overlay = TextureRect.new()
	generated_overlay.name = "GeneratedOverlay"
	generated_overlay.texture = texture
	generated_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	generated_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	generated_overlay.modulate = Color(1, 1, 1, 0.28)
	generated_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(generated_overlay)

	if background:
		move_child(generated_overlay, min(background.get_index() + 1, get_child_count() - 1))
	else:
		move_child(generated_overlay, 0)

func _load_runtime_texture(res_path: String) -> Texture2D:
	if not FileAccess.file_exists(res_path):
		return null

	if res_path.get_extension().to_lower() == "png":
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(res_path))
		if error == OK:
			return ImageTexture.create_from_image(image)

	if ResourceLoader.exists(res_path):
		return load(res_path) as Texture2D

	return null

func start_memory(memory_data: Dictionary) -> void:
	_fragments = memory_data.get("fragments", [])
	_result_evidence_id = memory_data.get("evidence_id", "")
	_current_display_index = 0
	_is_playing = true

	# Find correct fragment
	for i in _fragments.size():
		if _fragments[i].get("is_key", false):
			_correct_fragment_index = i
			break

	visible = true
	GameManager.set_state(GameManager.GameState.MEMORY_PREVIEW)
	choices_container.visible = false
	instruction_label.visible = true

	# Start displaying fragments
	_display_next_fragment()

func _display_next_fragment() -> void:
	if _current_display_index >= _fragments.size():
		# All fragments shown, present choices
		_show_choices()
		return

	var fragment: Dictionary = _fragments[_current_display_index]
	fragment_display.text = ""

	# Glitch effect - typewriter with random distortion
	var text: String = fragment.get("text", "")
	_animate_fragment_text(text)

func _animate_fragment_text(text: String) -> void:
	fragment_display.text = ""
	var tween := create_tween()

	# Flash effect
	tween.tween_property(background, "color", Color(0.0, 0.3, 0.3, 0.9), 0.1)
	tween.tween_property(background, "color", Color(0.0, 0.05, 0.1, 0.95), 0.2)

	# Show text character by character
	for i in text.length():
		var char_count := i + 1
		tween.tween_callback(func():
			fragment_display.text = text.substr(0, min(char_count, text.length()))
		)
		tween.tween_interval(0.04)

	# Hold
	tween.tween_interval(1.5)

	# Fade and advance
	tween.tween_property(fragment_display, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		fragment_display.modulate.a = 1.0
		_current_display_index += 1
		_display_next_fragment()
	)

func _show_choices() -> void:
	_is_playing = false
	instruction_label.text = "選擇你認為是關鍵資訊的記憶碎片"
	choices_container.visible = true

	for child in choices_container.get_children():
		child.queue_free()

	for i in _fragments.size():
		var fragment: Dictionary = _fragments[i]
		var btn := Button.new()
		btn.text = "碎片 %d" % (i + 1)
		btn.tooltip_text = fragment.get("text", "").substr(0, 30) + "..."
		btn.custom_minimum_size = InputManager.get_min_touch_target_size()
		btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
		btn.pressed.connect(_on_fragment_selected.bind(i))
		choices_container.add_child(btn)

func _on_fragment_selected(index: int) -> void:
	if index == _correct_fragment_index:
		# Correct choice
		fragment_display.text = "[ 記憶解鎖成功 ]\n\n" + _fragments[_correct_fragment_index].get("text", "")
		fragment_display.add_theme_color_override("default_color", Color(0.0, 1.0, 0.3))

		if _result_evidence_id != "":
			GameManager.collect_evidence(_result_evidence_id)

		var tween := create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(func():
			_close()
			memory_completed.emit(_result_evidence_id)
		)
	else:
		# Wrong choice
		fragment_display.text = "[ 記憶碎片不匹配 ]\n記憶資料已損壞..."
		fragment_display.add_theme_color_override("default_color", Color(1.0, 0.2, 0.2))

		var tween := create_tween()
		tween.tween_interval(1.5)
		tween.tween_callback(func():
			_close()
			memory_failed.emit()
		)

func _close() -> void:
	visible = false
	fragment_display.remove_theme_color_override("default_color")
	GameManager.set_state(GameManager.GameState.PLAYING)
