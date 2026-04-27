extends Control
## DialogueSystem - Handles dialogue display with typewriter effect, branching choices,
## and character portrait management.

signal dialogue_started
signal dialogue_ended
signal choice_made(choice_index: int)

@export var typewriter_speed: float = 0.03  # Seconds per character
@export var fast_speed: float = 0.01

@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var character_name_label: Label = $DialoguePanel/VBox/NameLabel
@onready var dialogue_text: RichTextLabel = $DialoguePanel/VBox/DialogueText
@onready var portrait_left: TextureRect = $PortraitLeft
@onready var portrait_right: TextureRect = $PortraitRight
@onready var choices_container: VBoxContainer = $DialoguePanel/VBox/ChoicesContainer
@onready var continue_indicator: Label = $DialoguePanel/VBox/ContinueIndicator

var _current_dialogue: Array = []  # Array of dialogue entries
var _current_index: int = 0
var _is_typing: bool = false
var _is_waiting_for_input: bool = false
var _full_text: String = ""
var _visible_chars: int = 0
var _type_timer: float = 0.0

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
	visible = false
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
	# Character name
	character_name_label.text = entry.get("name", "")

	# Portrait
	var speaker: String = entry.get("speaker", "")
	var mood: String = entry.get("mood", "default")
	var side: String = entry.get("portrait_side", "left")
	if speaker == "narrator":
		speaker = "kai"
		mood = "thoughtful"
		side = "right"
	_update_portrait(speaker, mood, side)

	# Set flag if specified
	var flag: String = entry.get("set_flag", "")
	if flag != "":
		GameManager.set_dialogue_flag(flag)

	var decision_change: Dictionary = entry.get("set_decision", {})
	for decision_id in decision_change:
		GameManager.set_decision(decision_id, decision_change[decision_id])

	# Give evidence if specified
	var evidence: String = entry.get("give_evidence", "")
	if evidence != "":
		GameManager.collect_evidence(evidence)

	# Start typewriter effect
	_full_text = entry.get("text", "")
	dialogue_text.text = _full_text
	dialogue_text.visible_characters = 0
	_visible_chars = 0
	_is_typing = true
	_is_waiting_for_input = false
	choices_container.visible = false
	continue_indicator.visible = false

func _process(delta: float) -> void:
	if not visible:
		return

	if _is_typing:
		_type_timer += delta
		var speed := fast_speed if Input.is_action_pressed("interact") else typewriter_speed
		if _type_timer >= speed:
			_type_timer = 0.0
			_visible_chars += 1
			dialogue_text.visible_characters = _visible_chars
			if _visible_chars >= _full_text.length():
				_finish_typing()

func _finish_typing() -> void:
	_is_typing = false
	dialogue_text.visible_characters = -1  # Show all

	var entry: Dictionary = _current_dialogue[_current_index]
	var choices: Array = entry.get("choices", [])

	if choices.is_empty():
		# No choices, wait for click to continue
		_is_waiting_for_input = true
		continue_indicator.visible = true
	else:
		# Show choices
		_show_choices(choices)

func _show_choices(choices: Array) -> void:
	# Clear old choices
	for child in choices_container.get_children():
		child.queue_free()

	choices_container.visible = true

	for i in choices.size():
		var choice: Dictionary = choices[i]

		# Check if choice requires evidence
		var requires: String = choice.get("requires_evidence", "")
		if requires != "" and not GameManager.has_evidence(requires):
			continue

		# Check if choice requires a flag
		var requires_flag: String = choice.get("requires_flag", "")
		if requires_flag != "" and not GameManager.get_dialogue_flag(requires_flag):
			continue

		var btn := Button.new()
		btn.text = choice.get("text", "...")
		btn.custom_minimum_size = InputManager.get_min_touch_target_size()
		btn.pressed.connect(_on_choice_pressed.bind(i))

		# Style the button for cyberpunk look
		btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.0, 0.6))

		choices_container.add_child(btn)

func _on_choice_pressed(index: int) -> void:
	var entry: Dictionary = _current_dialogue[_current_index]
	var choices: Array = entry.get("choices", [])

	if index < choices.size():
		var choice: Dictionary = choices[index]

		# Set any flags from this choice
		var flag: String = choice.get("set_flag", "")
		if flag != "":
			GameManager.set_dialogue_flag(flag)

		var decision_change: Dictionary = choice.get("set_decision", {})
		for decision_id in decision_change:
			GameManager.set_decision(decision_id, decision_change[decision_id])

		# Affect affinity
		var affinity_change: Dictionary = choice.get("affinity", {})
		for character_id in affinity_change:
			if character_id in GameManager.character_affinity:
				GameManager.character_affinity[character_id] += affinity_change[character_id]

		choice_made.emit(index)

		# Navigate to next dialogue
		var next: String = choice.get("next", "")
		if next == "end":
			end_dialogue()
		elif next != "":
			_jump_to_label(next)
		else:
			_advance()

func _input(event: InputEvent) -> void:
	if not visible:
		return

	var is_interact := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_interact = true
	elif event is InputEventScreenTouch and event.pressed:
		is_interact = true

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

func _advance() -> void:
	_current_index += 1
	if _current_index >= _current_dialogue.size():
		end_dialogue()
	else:
		_show_entry(_current_dialogue[_current_index])

func _jump_to_label(label: String) -> void:
	for i in _current_dialogue.size():
		if _current_dialogue[i].get("label", "") == label:
			_current_index = i
			_show_entry(_current_dialogue[_current_index])
			return
	# Label not found, just advance
	_advance()

func end_dialogue() -> void:
	visible = false
	_current_dialogue.clear()
	_current_index = 0
	GameManager.set_state(GameManager.GameState.PLAYING)
	dialogue_ended.emit()

func _update_portrait(speaker: String, mood: String, side: String) -> void:
	# Hide both first
	portrait_left.visible = false
	portrait_right.visible = false

	if speaker == "":
		return

	var texture := _load_character_portrait(speaker, mood)
	if texture == null and mood != "default":
		texture = _load_character_portrait(speaker, "default")

	if texture:
		if side == "left":
			portrait_left.texture = texture
			portrait_left.visible = true
		else:
			portrait_right.texture = texture
			portrait_right.visible = true

func _load_character_portrait(speaker: String, mood: String) -> Texture2D:
	for extension in ["png", "svg"]:
		var portrait_path := "res://assets/sprites/characters/%s_%s.%s" % [speaker, mood, extension]
		var texture := _load_runtime_texture(portrait_path)
		if texture:
			return texture
	return null

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
