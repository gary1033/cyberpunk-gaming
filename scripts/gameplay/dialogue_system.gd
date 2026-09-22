extends Control

const RuntimeAssetsScript = preload("res://scripts/core/runtime_assets.gd")
## DialogueSystem - Handles dialogue display with typewriter effect, branching choices,
## and character portrait management.

signal dialogue_started
signal dialogue_ended
signal choice_made(choice_index: int)

@export var typewriter_speed: float = 0.03  # Seconds per character
@export var fast_speed: float = 0.01

@onready var dialogue_panel: Control = find_child("DialoguePanel", true, false) as Control
@onready var character_name_label: Label = find_child("NameLabel", true, false) as Label
@onready var dialogue_text: RichTextLabel = find_child("DialogueText", true, false) as RichTextLabel
@onready var portrait_left: TextureRect = find_child("PortraitLeft", true, false) as TextureRect
@onready var portrait_right: TextureRect = find_child("PortraitRight", true, false) as TextureRect
@onready var choices_container: VBoxContainer = find_child("ChoicesContainer", true, false) as VBoxContainer
@onready var choices_scroll: ScrollContainer = find_child("ChoicesScroll", true, false) as ScrollContainer
@onready var continue_indicator: Label = find_child("ContinueIndicator", true, false) as Label
@onready var dialogue_content_margin: MarginContainer = find_child("DialogueContentMargin", true, false) as MarginContainer

const STORY_CG_DIR := "res://assets/sprites/cg"
const DIALOGUE_TEXT_HEIGHT := 96
const CHOICE_PROMPT_TEXT_HEIGHT := 58
const COMPACT_CHOICE_PROMPT_TEXT_HEIGHT := 58
const NO_CHOICE_DIALOGUE_TOP_MARGIN := 28
const NO_CHOICE_DIALOGUE_BOTTOM_MARGIN := 4
const CHOICE_DIALOGUE_TOP_MARGIN := 0
const CHOICE_DIALOGUE_BOTTOM_MARGIN := 0
const NORMAL_CHOICE_BUTTON_HEIGHT := 40
const COMPACT_CHOICE_BUTTON_HEIGHT := 32
const NORMAL_CHOICE_GAP := 5
const COMPACT_CHOICE_GAP := 3
const NORMAL_CHOICE_FONT_SIZE := 18
const COMPACT_CHOICE_FONT_SIZE := 18
const DIALOGUE_SENTENCE_ENDS := "。！？!?\n"
const DIALOGUE_CLOSING_MARKS := "，。、：；！？!?.,;:）)]】」』〉》…"

var _current_dialogue: Array = []  # Array of dialogue entries
var _current_index: int = 0
var _current_entry_pages: Array = []
var _current_page_index: int = 0
var _is_typing: bool = false
var _is_waiting_for_input: bool = false
var _full_text: String = ""
var _visible_chars: int = 0
var _type_timer: float = 0.0
var _page_recorded := false
var _notebook_button: Button
var _story_cg_overlay: TextureRect = null

# Dialogue entry format:
# {
#   "speaker": "mei_ling",
#   "name": "林美玲",
#   "text": "My brother has been missing for three days...",
#   "mood": "worried",
#   "portrait_side": "left",
#   "choices": [
#     {"text": "Tell me more.", "next": "more_info", "flag": null},
#     {"text": "Where was he last seen?", "next": "last_seen", "requires_evidence": null},
#   ],
#   "set_flag": "met_mei_ling",
#   "give_evidence": null
# }

func _ready() -> void:
	_notebook_button = Button.new()
	_notebook_button.name = "NotebookButton"
	_notebook_button.text = "紀錄／閱讀"
	_notebook_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_notebook_button.offset_left = -170
	_notebook_button.offset_right = -24
	_notebook_button.offset_top = 130
	_notebook_button.offset_bottom = 174
	_notebook_button.pressed.connect(_open_notebook)
	add_child(_notebook_button)
	_ensure_story_cg_overlay()
	visible = false
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	choices_container.visible = false
	continue_indicator.visible = false
	continue_indicator.text = "▼"

	# Root Control covers full screen; set to IGNORE so it doesn't block
	# toolbar buttons and other UI when dialogue is active.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	dialogue_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in dialogue_panel.get_children():
		if child is Container:
			child.mouse_filter = Control.MOUSE_FILTER_PASS

func start_dialogue(dialogue_data: Array) -> void:
	if dialogue_data.is_empty():
		return

	_current_dialogue = dialogue_data
	_current_index = 0
	visible = true
	GameManager.set_state(GameManager.GameState.DIALOGUE)
	dialogue_started.emit()
	_show_entry(_current_dialogue[_current_index])

func _show_entry(entry: Dictionary) -> void:
	while not GameManager.meets_story_conditions(entry):
		_current_index += 1
		if _current_index >= _current_dialogue.size():
			end_dialogue()
			return
		entry = _current_dialogue[_current_index]
	dialogue_text.add_theme_font_size_override("normal_font_size", (20 if InputManager.is_mobile else 24) + int(SaveManager.reading_settings.font_step) * 2)
	typewriter_speed = [0.06, 0.03, 0.012, 0.0][int(SaveManager.reading_settings.speed)]
	var entry_text: String = entry.get("text", "")
	if entry.get("show_public_record", false):
		var facts := GameManager.get_public_record_facts()
		entry_text += "\n" + ("\n".join(facts) if not facts.is_empty() else "沒有額外交易或資料外流；仍須對原件與署名負責。")
	_current_entry_pages = _split_dialogue_pages(entry_text, not _get_available_choices(entry.get("choices", [])).is_empty())
	_current_page_index = 0
	_show_entry_page(entry, _current_entry_pages[_current_page_index], true)

func _show_entry_page(entry: Dictionary, page_text: String, apply_effects: bool) -> void:
	_apply_entry_speaker(entry)

	if apply_effects:
		_apply_entry_effects(entry)

	var will_show_choices := _entry_page_will_show_choices(entry)
	_start_typewriter_page(page_text, will_show_choices)

func _apply_entry_speaker(entry: Dictionary) -> void:
	var speaker: String = entry.get("speaker", "")
	character_name_label.text = _get_display_name(entry, speaker)

	var mood: String = entry.get("mood", "default")
	if speaker == "narrator":
		speaker = "kai"
		mood = "thoughtful"
	_update_portrait(speaker, mood, "left")

func _apply_entry_effects(entry: Dictionary) -> void:
	if entry.has("sfx"):
		AudioManager.play_optional_sfx(str(entry.sfx))
	_apply_entry_cg_effect(entry)
	_apply_dialogue_state_changes(entry)

func _apply_entry_cg_effect(entry: Dictionary) -> void:
	var story_cg: String = entry.get("show_cg", "")
	if entry.has("show_item"):
		_show_story_cg(str(entry.show_item), true)
	elif story_cg != "":
		_show_story_cg(story_cg)
	elif entry.get("clear_cg", false):
		_hide_story_cg()

func _apply_dialogue_state_changes(source: Dictionary) -> void:
	if source.get("review_public_record", false):
		GameManager.review_public_record()
	var flag: String = source.get("set_flag", "")
	if flag != "":
		GameManager.set_dialogue_flag(flag)

	var flags: Array = source.get("set_flags", [])
	for flag_id in flags:
		GameManager.set_dialogue_flag(str(flag_id))

	var decision_change: Dictionary = source.get("set_decision", {})
	for decision_id in decision_change:
		GameManager.set_decision(decision_id, decision_change[decision_id])

	var decision_additions: Dictionary = source.get("add_decision", {})
	for decision_id in decision_additions:
		GameManager.set_decision(decision_id, int(GameManager.decisions.get(decision_id, 0)) + int(decision_additions[decision_id]))

	var evidence: String = source.get("give_evidence", "")
	if evidence != "":
		GameManager.collect_evidence(evidence)

func _start_typewriter_page(page_text: String, will_show_choices: bool) -> void:
	_set_dialogue_content_layout(will_show_choices)
	_page_recorded = false
	_full_text = page_text
	dialogue_text.text = _full_text
	dialogue_text.visible_characters = 0
	dialogue_text.custom_minimum_size = Vector2(0, DIALOGUE_TEXT_HEIGHT)
	dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_visible_chars = 0
	_type_timer = 0.0
	_is_typing = true
	_is_waiting_for_input = false
	choices_container.visible = false
	if choices_scroll:
		choices_scroll.visible = false
	continue_indicator.visible = false

func _process(delta: float) -> void:
	if not visible or get_tree().get_first_node_in_group("reading_panel") != null:
		return

	if _is_typing:
		if is_zero_approx(typewriter_speed):
			_finish_typing()
			return
		_type_timer += delta
		var fast_forward := Input.is_action_pressed("interact") or Input.is_key_pressed(KEY_SPACE)
		var speed := fast_speed if fast_forward else typewriter_speed
		if _type_timer >= speed:
			_type_timer = 0.0
			_visible_chars += 1
			dialogue_text.visible_characters = _visible_chars
			if _visible_chars >= _full_text.length():
				_finish_typing()

func _finish_typing() -> void:
	_is_typing = false
	if not _page_recorded:
		GameManager.record_dialogue(character_name_label.text, _full_text)
		_page_recorded = true
	dialogue_text.visible_characters = -1  # Show all

	if _has_more_pages():
		_show_continue_indicator()
		return

	var entry: Dictionary = _current_dialogue[_current_index]
	var choices: Array = _get_available_choices(entry.get("choices", []))

	if choices.is_empty():
		_wait_for_dialogue_advance()
	else:
		_show_entry_choices(choices)

func _show_continue_indicator() -> void:
	_is_waiting_for_input = true
	continue_indicator.visible = true
	continue_indicator.text = "續讀 %d/%d ▸" % [_current_page_index + 1, _current_entry_pages.size()] if _has_more_pages() else "下一段 ▾"

func _wait_for_dialogue_advance() -> void:
	_set_dialogue_content_layout(false)
	_show_continue_indicator()

func _show_entry_choices(choices: Array) -> void:
	_set_dialogue_content_layout(true)
	dialogue_text.size_flags_vertical = Control.SIZE_FILL
	var compact_choices := choices.size() >= 3
	dialogue_text.custom_minimum_size = Vector2(
		0,
		COMPACT_CHOICE_PROMPT_TEXT_HEIGHT if compact_choices else CHOICE_PROMPT_TEXT_HEIGHT
	)
	_show_choices(choices, compact_choices)

func _show_choices(available_choices: Array, compact_layout: bool) -> void:
	_clear_choices()
	choices_container.visible = true
	if choices_scroll:
		choices_scroll.visible = true
		choices_scroll.scroll_vertical = 0
	choices_container.add_theme_constant_override("separation", COMPACT_CHOICE_GAP if compact_layout else NORMAL_CHOICE_GAP)
	var button_height := COMPACT_CHOICE_BUTTON_HEIGHT if compact_layout else NORMAL_CHOICE_BUTTON_HEIGHT
	var font_size := (COMPACT_CHOICE_FONT_SIZE if compact_layout else NORMAL_CHOICE_FONT_SIZE) + int(SaveManager.reading_settings.font_step)

	for available in available_choices:
		var choice: Dictionary = available.get("choice", {})
		var choice_index := int(available.get("index", 0))
		var btn := _create_choice_button(choice, choice_index, button_height, font_size)
		choices_container.add_child(btn)

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _create_choice_button(choice: Dictionary, choice_index: int, button_height: int, font_size: int) -> Button:
	var btn := Button.new()
	btn.text = str(choice.get("text", "..."))
	btn.custom_minimum_size = Vector2(0, button_height if not InputManager.is_mobile else 34)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_choice_pressed.bind(choice_index))
	_apply_choice_button_style(btn, font_size)
	return btn

func _apply_choice_button_style(btn: Button, font_size: int) -> void:
	btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.0, 0.6))
	btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_stylebox_override(
		"normal",
		_create_choice_button_style(Color(0.01, 0.018, 0.026, 0.9), Color(0.0, 0.78, 0.82, 0.74), 1)
	)
	btn.add_theme_stylebox_override(
		"hover",
		_create_choice_button_style(Color(0.015, 0.032, 0.045, 0.98), Color(1.0, 0.0, 0.6, 0.88), 2)
	)
	btn.add_theme_stylebox_override(
		"pressed",
		_create_choice_button_style(Color(0.0, 0.12, 0.14, 0.98), Color(0.0, 0.95, 0.95, 1.0), 2)
	)
	btn.add_theme_stylebox_override(
		"focus",
		_create_choice_button_style(Color(0, 0, 0, 0), Color(0.0, 0.95, 0.95, 0.9), 2)
	)

func _entry_page_will_show_choices(entry: Dictionary) -> bool:
	if _has_more_pages():
		return false
	return not _get_available_choices(entry.get("choices", [])).is_empty()

func _set_dialogue_content_layout(has_visible_choices: bool) -> void:
	if dialogue_content_margin == null:
		return
	dialogue_content_margin.add_theme_constant_override(
		"margin_top",
		CHOICE_DIALOGUE_TOP_MARGIN if has_visible_choices else NO_CHOICE_DIALOGUE_TOP_MARGIN
	)
	dialogue_content_margin.add_theme_constant_override(
		"margin_bottom",
		CHOICE_DIALOGUE_BOTTOM_MARGIN if has_visible_choices else NO_CHOICE_DIALOGUE_BOTTOM_MARGIN
	)

func _create_choice_button_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(3)
	style.shadow_color = Color(0.0, 0.95, 0.95, 0.12)
	style.shadow_size = 6
	style.set_content_margin(SIDE_LEFT, 18)
	style.set_content_margin(SIDE_RIGHT, 18)
	style.set_content_margin(SIDE_TOP, 4)
	style.set_content_margin(SIDE_BOTTOM, 4)
	return style

func _get_display_name(entry: Dictionary, speaker: String) -> String:
	var display_name: String = entry.get("name", "")
	if display_name != "":
		return display_name

	match speaker:
		"narrator", "kai":
			return "凱"
		"mei_ling":
			return "林美玲"
		"ajie":
			return "阿傑"
		"snake":
			return "蛇女"
		"dr_chen":
			return "陳醫師"
		_:
			return str(CharacterData.get_character(speaker).get("name", ""))

func _get_available_choices(choices: Array) -> Array:
	var available_choices: Array = []
	for i in choices.size():
		var choice: Dictionary = choices[i]
		if _is_choice_available(choice):
			available_choices.append({
				"index": i,
				"choice": choice,
			})
	return available_choices

func _is_choice_available(choice: Dictionary) -> bool:
	return GameManager.meets_story_conditions(choice)

func _on_choice_pressed(index: int) -> void:
	if not visible or _is_typing or not choices_container.visible or _current_dialogue.is_empty():
		return
	var entry: Dictionary = _current_dialogue[_current_index]
	var choices: Array = entry.get("choices", [])

	if index >= 0 and index < choices.size():
		var choice: Dictionary = choices[index]
		if not _is_choice_available(choice):
			return
		GameManager.record_dialogue("選擇", str(choice.get("text", "")))
		_apply_choice_effects(choice)
		choice_made.emit(index)
		_follow_choice_next(choice)

func _apply_choice_effects(choice: Dictionary) -> void:
	_apply_dialogue_state_changes(choice)

	var affinity_change: Dictionary = choice.get("affinity", {})
	for character_id in affinity_change:
		if character_id in GameManager.character_affinity:
			GameManager.character_affinity[character_id] += affinity_change[character_id]

func _follow_choice_next(choice: Dictionary) -> void:
	var next: String = choice.get("next", "")
	if next == "end":
		end_dialogue()
	elif next != "":
		_jump_to_label(next)
	else:
		_advance(true)

func _input(event: InputEvent) -> void:
	if not visible or get_tree().get_first_node_in_group("reading_panel") != null:
		return

	if (event is InputEventMouseButton or event is InputEventScreenTouch) and _notebook_button.get_global_rect().has_point(event.position):
		return
	var is_interact := false
	if event is InputEventMouseButton and event.device != InputEvent.DEVICE_ID_EMULATION and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_interact = true
	elif event is InputEventScreenTouch and event.pressed:
		is_interact = true
	elif event is InputEventKey and event.pressed and not event.echo:
		is_interact = event.keycode == KEY_SPACE or event.is_action_pressed("ui_accept")

	if is_interact:
		if _is_typing:
			# Skip typewriter, show all text
			_visible_chars = _full_text.length()
			dialogue_text.visible_characters = -1
			_finish_typing()
			get_viewport().set_input_as_handled()
		elif _is_waiting_for_input:
			_advance()
			get_viewport().set_input_as_handled()

func _advance(choice_selected: bool = false) -> void:
	if _current_dialogue.is_empty():
		return
	if _has_more_pages():
		_current_page_index += 1
		_show_entry_page(_current_dialogue[_current_index], _current_entry_pages[_current_page_index], false)
		return

	var entry: Dictionary = _current_dialogue[_current_index]
	if entry.has("choices") and not choice_selected:
		if _get_available_choices(entry["choices"]).is_empty():
			end_dialogue()
		return
	var next: String = entry.get("next", "")
	if next == "end":
		end_dialogue()
		return
	if next != "":
		_jump_to_label(next)
		return

	_current_index += 1
	if _current_index >= _current_dialogue.size():
		end_dialogue()
	else:
		_show_entry(_current_dialogue[_current_index])

func _has_more_pages() -> bool:
	return _current_page_index + 1 < _current_entry_pages.size()

func _dialogue_text_fits(text: String, has_choices: bool) -> bool:
	var font := dialogue_text.get_theme_font("normal_font")
	var font_size := dialogue_text.get_theme_font_size("normal_font_size")
	var width := maxf(1.0, dialogue_panel.size.x - 4.0)
	var height := CHOICE_PROMPT_TEXT_HEIGHT if has_choices else DIALOGUE_TEXT_HEIGHT
	return font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, width, font_size).y <= height

func _split_dialogue_pages(text: String, has_choices: bool = false) -> Array:
	if text.is_empty():
		return [""]
	var pages: Array = []
	var start := 0
	while start < text.length():
		var end := text.length()
		if not _dialogue_text_fits(text.substr(start), has_choices):
			var low := start + 1
			var high := end
			while low < high:
				var middle := (low + high + 1) / 2
				if _dialogue_text_fits(text.substr(start, middle - start), has_choices):
					low = middle
				else:
					high = middle - 1
			end = _find_dialogue_page_break(text, start, low)
		pages.append(text.substr(start, end - start))
		start = end
	return pages

func _find_dialogue_page_break(text: String, start: int, hard_end: int) -> int:
	# Keep closing quotes with their sentence, and prefer complete sentences.
	while hard_end > start + 1 and hard_end < text.length() and (DIALOGUE_CLOSING_MARKS.contains(text[hard_end]) or "（([【「『〈《".contains(text[hard_end - 1])):
		hard_end -= 1
	for i in range(hard_end - 1, start - 1, -1):
		if DIALOGUE_SENTENCE_ENDS.contains(text[i]):
			var end := i + 1
			while end < hard_end and "」』）)]】〉》".contains(text[end]):
				end += 1
			return end
	return hard_end

func _jump_to_label(label: String) -> void:
	for i in _current_dialogue.size():
		if _current_dialogue[i].get("label", "") == label:
			_current_index = i
			_show_entry(_current_dialogue[_current_index])
			return
	push_error("Dialogue label not found: %s" % label)
	end_dialogue()

func end_dialogue() -> void:
	visible = false
	_current_dialogue.clear()
	_current_index = 0
	_current_entry_pages.clear()
	_current_page_index = 0
	_hide_story_cg()
	GameManager.set_state(GameManager.GameState.PLAYING)
	dialogue_ended.emit()

func _ensure_story_cg_overlay() -> void:
	if _story_cg_overlay:
		return
	_story_cg_overlay = get_node_or_null("StoryCGOverlay") as TextureRect
	if _story_cg_overlay == null:
		_story_cg_overlay = TextureRect.new()
		_story_cg_overlay.name = "StoryCGOverlay"
		_story_cg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		_story_cg_overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_story_cg_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_story_cg_overlay.visible = false
		add_child(_story_cg_overlay)
		move_child(_story_cg_overlay, 0)
	_story_cg_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

func _show_story_cg(cg_id: String, is_item: bool = false) -> void:
	_ensure_story_cg_overlay()
	var folder := "res://assets/sprites/items" if is_item else STORY_CG_DIR
	var texture := RuntimeAssetsScript.load_texture("%s/%s.png" % [folder, cg_id])
	if texture == null:
		return
	_story_cg_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_story_cg_overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if is_item else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if is_item:
		_story_cg_overlay.anchor_left = 0.36
		_story_cg_overlay.anchor_right = 0.64
		_story_cg_overlay.anchor_top = 0.08
		_story_cg_overlay.anchor_bottom = minf(0.48, (dialogue_panel.get_global_rect().position.y - 12.0) / get_viewport_rect().size.y)
	_story_cg_overlay.texture = texture
	_story_cg_overlay.modulate = Color.WHITE
	_story_cg_overlay.visible = true

func _hide_story_cg() -> void:
	if _story_cg_overlay:
		_story_cg_overlay.visible = false
		_story_cg_overlay.texture = null

func _update_portrait(speaker: String, mood: String, _side: String) -> void:
	# Hide both first
	portrait_left.visible = false
	portrait_right.visible = false

	if speaker == "":
		return

	var texture := _load_character_portrait(speaker, mood)
	if texture == null and mood != "default":
		texture = _load_character_portrait(speaker, "default")

	if texture:
		# Show the head and shoulders instead of shrinking the full bust into the portrait cell.
		var headshot := AtlasTexture.new()
		headshot.atlas = texture
		headshot.region = Rect2(Vector2(0.20, 0.075) * texture.get_size(), Vector2(0.60, 0.39) * texture.get_size())
		portrait_left.texture = headshot
		portrait_left.visible = true

func _load_character_portrait(speaker: String, mood: String) -> Texture2D:
	var portrait_path := "res://assets/sprites/characters/%s_%s.png" % [speaker, mood]
	return RuntimeAssetsScript.load_texture(portrait_path)

func _open_notebook() -> void:
	if get_tree().get_first_node_in_group("reading_panel") == null:
		add_child(load("res://scripts/ui/case_notebook.gd").new())
