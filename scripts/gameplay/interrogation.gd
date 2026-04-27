extends Control
## Interrogation - Special scene for interrogating suspects with pressure system.
## Features pressure gauge, question categories, evidence presentation, and eagle eye integration.

signal interrogation_ended(result: Dictionary)

class_name Interrogation

var character_portrait: TextureRect = null
var character_name_label: Label = null
var pressure_bar: ProgressBar = null
var pressure_label: Label = null
var dialogue_text: RichTextLabel = null
var questions_container: VBoxContainer = null
var evidence_button: Button = null
var biometric_panel: PanelContainer = null
var biometric_label: Label = null

var _character_id: String = ""
var _character_data: Dictionary = {}
var _pressure: int = 0
var _max_pressure: int = 100
var _clam_up_threshold: int = 80   # Suspect clams up above this
var _broke_threshold: int = 70     # Suspect breaks and reveals info at this level
var _questions_asked: Array = []
var _revealed_info: Array = []

# Question format:
# {
#   "text": "Where were you last night?",
#   "type": "gentle" | "neutral" | "aggressive",
#   "pressure_change": int,
#   "response_normal": "I was at home...",
#   "response_pressured": "Fine! I was at the bar!",
#   "response_clammed": "I'm not saying anything.",
#   "reveals": "info_key",  # what info this question can reveal
#   "requires_evidence": "",  # optional evidence needed
#   "requires_pressure": 0    # minimum pressure needed for pressured response
# }

func _ready() -> void:
	visible = false

	# Resolve nodes safely for dynamic instantiation
	character_portrait = get_node_or_null("CharacterPortrait") as TextureRect
	var ui := get_node_or_null("UI")
	if ui:
		character_name_label = ui.get_node_or_null("CharacterName") as Label
		pressure_bar = ui.get_node_or_null("PressureBar") as ProgressBar
		pressure_label = ui.get_node_or_null("PressureLabel") as Label
		dialogue_text = ui.get_node_or_null("DialogueText") as RichTextLabel
		questions_container = ui.get_node_or_null("QuestionsContainer") as VBoxContainer
		evidence_button = ui.get_node_or_null("EvidenceButton") as Button
		biometric_panel = ui.get_node_or_null("BiometricPanel") as PanelContainer
		if biometric_panel:
			biometric_label = biometric_panel.get_node_or_null("BiometricLabel") as Label

	if evidence_button:
		evidence_button.pressed.connect(_on_evidence_pressed)
	if biometric_panel:
		biometric_panel.visible = false

func start_interrogation(character_id: String, data: Dictionary) -> void:
	_character_id = character_id
	_character_data = data
	_pressure = 0
	_questions_asked.clear()
	_revealed_info.clear()

	visible = true
	GameManager.set_state(GameManager.GameState.INTERROGATION)

	# Set up character display
	if character_name_label:
		character_name_label.text = data.get("name", "")
	_clam_up_threshold = data.get("clam_up_threshold", 80)
	_broke_threshold = data.get("broke_threshold", 70)

	# Load portrait
	var tex := _load_character_portrait("default")
	if tex and character_portrait:
		character_portrait.texture = tex

	# Initial dialogue
	if dialogue_text:
		dialogue_text.text = data.get("opening_line", "...")
	_update_pressure_display()
	_show_questions()

func _show_questions() -> void:
	if not questions_container:
		return

	for child in questions_container.get_children():
		child.queue_free()

	var questions: Array = _character_data.get("questions", [])
	for i in questions.size():
		var q: Dictionary = questions[i]

		# Skip already asked questions
		if i in _questions_asked:
			continue

		# Check evidence requirement
		var req_evidence: String = q.get("requires_evidence", "")
		if req_evidence != "" and not GameManager.has_evidence(req_evidence):
			continue

		var btn := Button.new()
		btn.custom_minimum_size = InputManager.get_min_touch_target_size()

		# Color code by type
		var q_type: String = q.get("type", "neutral")
		match q_type:
			"gentle":
				btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
				btn.text = "[溫和] " + q.get("text", "")
			"neutral":
				btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))
				btn.text = "[中性] " + q.get("text", "")
			"aggressive":
				btn.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
				btn.text = "[施壓] " + q.get("text", "")

		btn.pressed.connect(_on_question_pressed.bind(i))
		questions_container.add_child(btn)

	# Add "End Interrogation" button
	var end_btn := Button.new()
	end_btn.text = "結束審問"
	end_btn.custom_minimum_size = InputManager.get_min_touch_target_size()
	end_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	end_btn.pressed.connect(end_interrogation)
	questions_container.add_child(end_btn)

func _on_question_pressed(question_index: int) -> void:
	_questions_asked.append(question_index)
	var questions: Array = _character_data.get("questions", [])
	if question_index >= questions.size():
		return

	var q: Dictionary = questions[question_index]
	var pressure_change: int = q.get("pressure_change", 5)
	_pressure = clampi(_pressure + pressure_change, 0, _max_pressure)
	_update_pressure_display()

	# Determine response
	var response: String
	if _pressure >= _clam_up_threshold:
		response = q.get("response_clammed", "……")
		_update_portrait("angry")
	elif _pressure >= q.get("requires_pressure", 999):
		response = q.get("response_pressured", q.get("response_normal", "..."))
		var reveals: String = q.get("reveals", "")
		if reveals != "":
			_revealed_info.append(reveals)
		_update_portrait("nervous")
	else:
		response = q.get("response_normal", "...")
		_update_portrait("default")

	if dialogue_text:
		dialogue_text.text = response

	# Update biometric if eagle eye is active
	if GameManager.eagle_eye_active:
		_show_biometrics()

	# Refresh questions
	_show_questions()

	# Spend action point
	GameManager.spend_action_points(1)

func _on_evidence_pressed() -> void:
	if not questions_container:
		return

	# Show evidence selection for presentation
	# This would open a simplified evidence picker
	# For now, show collected evidence as buttons
	for child in questions_container.get_children():
		child.queue_free()

	var evidence_list := GameManager.collected_evidence
	for evidence_id in evidence_list:
		var btn := Button.new()
		btn.text = "出示：" + evidence_id
		btn.custom_minimum_size = InputManager.get_min_touch_target_size()
		btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
		btn.pressed.connect(_on_present_evidence.bind(evidence_id))
		questions_container.add_child(btn)

	var back_btn := Button.new()
	back_btn.text = "返回提問"
	back_btn.custom_minimum_size = InputManager.get_min_touch_target_size()
	back_btn.pressed.connect(_show_questions)
	questions_container.add_child(back_btn)

func _on_present_evidence(evidence_id: String) -> void:
	var reactions: Dictionary = _character_data.get("evidence_reactions", {})
	if evidence_id in reactions:
		var reaction: Dictionary = reactions[evidence_id]
		if dialogue_text:
			dialogue_text.text = reaction.get("response", "...")
		_pressure += reaction.get("pressure_change", 0)
		_pressure = clampi(_pressure, 0, _max_pressure)
		_update_pressure_display()

		var reveals: String = reaction.get("reveals", "")
		if reveals != "":
			_revealed_info.append(reveals)
	else:
		if dialogue_text:
			dialogue_text.text = _character_data.get("default_evidence_response", "這跟我有什麼關係？")

	_show_questions()

func _show_biometrics() -> void:
	if not biometric_panel:
		return
	biometric_panel.visible = true
	var vision := get_tree().get_first_node_in_group("augmented_vision")
	if vision and vision.has_method("get_biometric_reading"):
		var reading: Dictionary = vision.get_biometric_reading(_character_id, _pressure)
		biometric_label.text = (
			"心率: %d BPM\n壓力: %d%%\n微表情: %s\n說謊概率: %.0f%%" %
			[reading["heart_rate"], reading["stress_level"],
			 reading["micro_expression"], reading["lying_probability"] * 100]
		)

func _update_pressure_display() -> void:
	if pressure_bar:
		pressure_bar.max_value = _max_pressure
		pressure_bar.value = _pressure

		# Color coding
		var ratio := float(_pressure) / float(_max_pressure)
		if ratio < 0.5:
			pressure_bar.modulate = Color(0.3, 0.9, 0.3)
		elif ratio < 0.75:
			pressure_bar.modulate = Color(0.9, 0.9, 0.3)
		else:
			pressure_bar.modulate = Color(0.9, 0.3, 0.3)

	if pressure_label:
		pressure_label.text = "壓力: %d / %d" % [_pressure, _max_pressure]

func _update_portrait(mood: String) -> void:
	if not character_portrait:
		return

	var tex := _load_character_portrait(mood)
	if tex == null and mood != "default":
		tex = _load_character_portrait("default")
	if tex:
		character_portrait.texture = tex

func _load_character_portrait(mood: String) -> Texture2D:
	for extension in ["png", "svg"]:
		var path := "res://assets/sprites/characters/%s_%s.%s" % [_character_id, mood, extension]
		var tex := load(path) as Texture2D
		if tex:
			return tex
	return null

func end_interrogation() -> void:
	visible = false
	GameManager.set_state(GameManager.GameState.PLAYING)

	# Record pressure in decisions
	var decision_key := "interrogation_pressure_%s" % _character_id
	if decision_key in GameManager.decisions:
		GameManager.decisions[decision_key] = _pressure

	var result := {
		"character": _character_id,
		"final_pressure": _pressure,
		"revealed_info": _revealed_info.duplicate(),
		"clammed_up": _pressure >= _clam_up_threshold,
		"broke": _pressure >= _broke_threshold and _pressure < _clam_up_threshold
	}

	interrogation_ended.emit(result)
