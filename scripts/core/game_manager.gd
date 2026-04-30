extends Node
## GameManager - Global game state singleton (autoload)
## Manages game state, collected evidence, chapter progression, and decision tracking.

signal evidence_collected(evidence_id: String)
signal chapter_changed(chapter: int)
signal action_points_changed(remaining: int)
signal game_state_changed(state: String)

enum GameState { MAIN_MENU, PLAYING, DIALOGUE, EVIDENCE_BOARD, INTERROGATION, MEMORY_PREVIEW, PAUSED }

# Current game state
var current_state: GameState = GameState.MAIN_MENU
var current_chapter: int = 1
var current_location: String = ""

# Evidence system
var collected_evidence: Array[String] = []
var evidence_connections: Array[Dictionary] = []  # [{from: id, to: id, correct: bool}]

# Time budget system
var action_points: int = 20
var max_action_points: int = 20

# Decision tracking for endings
var decisions: Dictionary = {
	"trusted_zhao_ming": false,
	"interrogation_pressure_ajie": 0,      # 0-100
	"interrogation_pressure_ghost": 0,
	"interrogation_pressure_dr_xiao": 0,
	"identity_exposed_market": false,
	"memory_attitude": "neutral",           # "accept", "deny", "neutral"
	"correct_deductions": 0,
	"total_evidence_collected": 0,
	"accepted_snake_deal": false,
	"rejected_snake_deal": false,
	"black_market_route_opened": false,
	"clinic_route_opened": false,
	"chapter_1_complete": false,
	"chapter_1_route_chosen": "none",
	"echo_trust_axis_seeded": false,
	"black_market_compromise_count": 0,
	"eagle_eye_overuse_count": 0
}

# Character affinity
var character_affinity: Dictionary = {
	"mei_ling": 0,
	"ajie": 0,
	"snake": 0,
	"dr_chen": 0,
	"ghost": 0,
	"zhao_ming": 0,
	"kid": 0,
	"dr_xiao": 0,
	"hao_ran": 0
}

# Dialogue flags - tracks which dialogues have been seen
var dialogue_flags: Dictionary = {}

# Eagle eye (augmented vision)
var eagle_eye_energy: float = 100.0
var eagle_eye_max_energy: float = 100.0
var eagle_eye_active: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func new_game() -> void:
	current_state = GameState.PLAYING
	current_chapter = 1
	current_location = "detective_office"
	collected_evidence.clear()
	evidence_connections.clear()
	action_points = 20
	max_action_points = 20
	dialogue_flags.clear()
	eagle_eye_energy = 100.0
	eagle_eye_active = false
	_reset_decisions()
	_reset_affinity()
	chapter_changed.emit(1)
	game_state_changed.emit("playing")

func _reset_decisions() -> void:
	decisions = {
		"trusted_zhao_ming": false,
		"interrogation_pressure_ajie": 0,
		"interrogation_pressure_ghost": 0,
		"interrogation_pressure_dr_xiao": 0,
		"identity_exposed_market": false,
		"memory_attitude": "neutral",
		"correct_deductions": 0,
		"total_evidence_collected": 0,
		"accepted_snake_deal": false,
		"rejected_snake_deal": false,
		"black_market_route_opened": false,
		"clinic_route_opened": false,
		"chapter_1_complete": false,
		"chapter_1_route_chosen": "none",
		"echo_trust_axis_seeded": false,
		"black_market_compromise_count": 0,
		"eagle_eye_overuse_count": 0
	}

func _reset_affinity() -> void:
	for key in character_affinity:
		character_affinity[key] = 0

# --- Evidence ---

func collect_evidence(evidence_id: String) -> void:
	if evidence_id not in collected_evidence:
		collected_evidence.append(evidence_id)
		decisions["total_evidence_collected"] += 1
		evidence_collected.emit(evidence_id)

func has_evidence(evidence_id: String) -> bool:
	return evidence_id in collected_evidence

func add_evidence_connection(from_id: String, to_id: String, is_correct: bool) -> void:
	evidence_connections.append({"from": from_id, "to": to_id, "correct": is_correct})
	if is_correct:
		decisions["correct_deductions"] += 1

# --- Action Points ---

func spend_action_points(amount: int) -> bool:
	if action_points >= amount:
		action_points -= amount
		action_points_changed.emit(action_points)
		if action_points <= 0:
			_force_chapter_advance()
		return true
	return false

func _force_chapter_advance() -> void:
	if current_chapter < 3:
		advance_chapter()

# --- Chapter ---

func advance_chapter() -> void:
	current_chapter += 1
	action_points = max_action_points
	chapter_changed.emit(current_chapter)
	action_points_changed.emit(action_points)

# --- Eagle Eye ---

func activate_eagle_eye() -> bool:
	if eagle_eye_energy > 0 and not eagle_eye_active:
		eagle_eye_active = true
		decisions["eagle_eye_overuse_count"] = decisions.get("eagle_eye_overuse_count", 0) + 1
		if decisions["eagle_eye_overuse_count"] >= 7:
			set_dialogue_flag("kai_eye_overuse_warning")
		return true
	return false

func deactivate_eagle_eye() -> void:
	eagle_eye_active = false

func consume_eagle_eye_energy(delta: float) -> void:
	if eagle_eye_active:
		consume_eagle_eye_energy_amount(delta * 10.0)  # Legacy continuous drain path

func consume_eagle_eye_energy_amount(amount: float) -> void:
	if eagle_eye_active:
		eagle_eye_energy -= amount
		if eagle_eye_energy <= 0:
			eagle_eye_energy = 0
			deactivate_eagle_eye()

func recharge_eagle_eye(delta: float) -> void:
	if not eagle_eye_active and eagle_eye_energy < eagle_eye_max_energy:
		eagle_eye_energy += delta * 5.0  # Recharges over ~20 seconds
		eagle_eye_energy = min(eagle_eye_energy, eagle_eye_max_energy)

# --- State ---

func set_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(GameState.keys()[new_state].to_lower())

# --- Dialogue Flags ---

func set_dialogue_flag(flag: String, value: bool = true) -> void:
	dialogue_flags[flag] = value
	if flag in decisions and decisions[flag] is bool:
		decisions[flag] = value

func get_dialogue_flag(flag: String) -> bool:
	return dialogue_flags.get(flag, false)

func set_decision(decision_id: String, value: Variant) -> void:
	if decision_id in decisions:
		decisions[decision_id] = value

# --- Ending Calculation ---

func calculate_ending() -> String:
	var evidence_ratio: float = float(decisions["total_evidence_collected"]) / 37.0
	var deduction_score: int = decisions["correct_deductions"]
	var trusted_zhao: bool = decisions["trusted_zhao_ming"]
	var memory_attitude: String = decisions["memory_attitude"]

	# Ending C: Memory Rebirth - player accepts memory manipulation truth
	if memory_attitude == "accept" and deduction_score >= 8:
		return "ending_c_memory_rebirth"

	# Ending A: Justice - high evidence + trusted Zhao Ming
	if evidence_ratio > 0.7 and trusted_zhao and deduction_score >= 6:
		return "ending_a_justice"

	# Ending B: Grey Deal - default / pragmatic choices
	return "ending_b_grey_deal"

# --- Save Data ---

func get_save_data() -> Dictionary:
	return {
		"current_chapter": current_chapter,
		"current_location": current_location,
		"collected_evidence": collected_evidence.duplicate(),
		"evidence_connections": evidence_connections.duplicate(true),
		"action_points": action_points,
		"decisions": decisions.duplicate(true),
		"character_affinity": character_affinity.duplicate(),
		"dialogue_flags": dialogue_flags.duplicate(),
		"eagle_eye_energy": eagle_eye_energy
	}

func load_save_data(data: Dictionary) -> void:
	current_chapter = data.get("current_chapter", 1)
	current_location = data.get("current_location", "detective_office")
	collected_evidence = data.get("collected_evidence", [])
	evidence_connections = data.get("evidence_connections", [])
	action_points = data.get("action_points", 20)
	decisions = data.get("decisions", {})
	character_affinity = data.get("character_affinity", {})
	dialogue_flags = data.get("dialogue_flags", {})
	eagle_eye_energy = data.get("eagle_eye_energy", 100.0)
