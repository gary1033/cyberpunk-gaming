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
const DEFAULT_DECISIONS: Dictionary = {
	"branch_story_version": 0,
	"chapter_2_route": "none",
	"ch2_medical_priority": "none",
	"ch2_market_access": "none",
	"ch2_market_priority": "none",
	"grid_interpretation": "none",
	"warehouse_priority": "none",
	"archive_route": "none",
	"dispatch_record": "none",
	"xiao_accountability": "none",
	"recovery_channel": "none",
	"recovery_company": "none",
	"continuity_record": "none",
	"ajie_statement": "none",
	"market_claim_resolution": "none",
	"backup_handling": "none",
	"backup_custody": "none",
	"grey_care_terms": "none",
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
	"eagle_eye_overuse_count": 0,
	"chapter_2_complete": false,
	"ch2_evidence_channel": "undecided",
	"hao_ran_rescued": false,
	"family_update_choice": "none",
	"hao_ran_aftercare": "none",
	"memory_trade_method": "none",
	"ghost_identity_choice": "none",
	"ghost_followup_choice": "none",
	"hq_entry_route": "none",
	"public_record_reviewed": false,
	"public_record_facts": [],
	"public_ending_variant": "",
	"helped_ghost": false,
	"echo_fate": "undecided",
	"merged_with_echo": false,
	"memory_restoration_consented": false,
	"public_truth_ready": false,
	"final_resolution": "undecided",
	"resolved_ending": ""
}
var decisions: Dictionary = DEFAULT_DECISIONS.duplicate(true)

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
	decisions.branch_story_version = 1
	_reset_affinity()
	chapter_changed.emit(1)
	game_state_changed.emit("playing")

func _reset_decisions() -> void:
	decisions = DEFAULT_DECISIONS.duplicate(true)

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
	if amount < 0 or action_points < amount or SceneManager.is_transitioning():
		return false
	action_points -= amount
	action_points_changed.emit(action_points)
	return true

func rest() -> bool:
	if SceneManager.is_transitioning() or action_points >= max_action_points:
		return false
	action_points = max_action_points
	action_points_changed.emit(action_points)
	return true

# --- Chapter ---

func can_advance_chapter() -> bool:
	return current_chapter in [1, 2] and get_dialogue_flag("chapter_%d_complete" % current_chapter) and (current_chapter != 2 or is_chapter_branch_complete())

func get_chapter_2_route() -> String:
	var route: String = decisions.chapter_2_route
	if route == "none":
		route = str(decisions.chapter_1_route_chosen)
	if route not in ["clinic", "black_market"]:
		route = "black_market" if decisions.accepted_snake_deal else "clinic"
	return route

func is_chapter_branch_complete() -> bool:
	return int(decisions.branch_story_version) == 0 or get_dialogue_flag("ch2_branch_complete")

func get_chapter_branch_hint() -> String:
	if current_chapter != 2 or int(decisions.branch_story_version) == 0:
		return ""
	if get_dialogue_flag("ch2_branch_complete"):
		return "路線交接已完成；核對倉庫與正和備忘錄後，回網咖確認總部路線。"
	if get_chapter_2_route() == "clinic":
		if not get_dialogue_flag("referral_number_checked"):
			return "被退回的求救：到離線轉介等候站，掃描叫號紙與接收簿。"
		if not get_dialogue_flag("referral_reroute_checked"):
			return "被退回的求救：到市政檔案室掃描撤回回執，再比對改派回條。"
		return "被退回的求救：取得倉庫日記與受害者清單後，回等候站決定交接。"
	if not get_dialogue_flag("auction_batch_checked"):
		return "被標價的人：到拍賣交割後室，掃描銅扣與新舊標籤。"
	if not get_dialogue_flag("auction_access_resolved"):
		return "被標價的人：在交割後室決定如何查閱交割表。"
	return "被標價的人：取得倉庫日記與受害者清單後，回後室決定保帳或追運輸。"

func advance_chapter() -> bool:
	if not can_advance_chapter() or SceneManager.is_transitioning():
		return false
	var next_chapter: int = current_chapter + 1
	var case_data: GDScript = preload("res://scripts/data/case_data.gd")
	var chapter_data: Dictionary = case_data.get_chapter_data(next_chapter)
	return await SceneManager.change_scene_with_chapter_title(
		str(chapter_data.get("starting_location", "")), next_chapter, str(chapter_data.get("title", ""))
	)

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

func perform_eagle_eye_scan(cost: float) -> bool:
	if current_state != GameState.PLAYING or not is_finite(cost) or cost <= 0.0 or eagle_eye_energy < cost:
		return false
	var was_active := eagle_eye_active
	if not was_active:
		activate_eagle_eye()
	consume_eagle_eye_energy_amount(cost)
	if not was_active:
		deactivate_eagle_eye()
	return true

func consume_eagle_eye_energy(delta: float) -> void:
	if eagle_eye_active:
		# Charge partial use immediately; the HUD alone rounds it into ten cells.
		consume_eagle_eye_energy_amount(maxf(delta, 0.0) * 10.0)

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
	if decision_id == "chapter_2_route" and (current_chapter != 2 or get_dialogue_flag("ch2_branch_complete") or value not in ["clinic", "black_market"]):
		return
	if decision_id in decisions:
		decisions[decision_id] = value
		if value is bool:
			dialogue_flags[decision_id] = value

func meets_story_conditions(data: Dictionary) -> bool:
	if data.get("requires_branch_complete", false) and not is_chapter_branch_complete():
		return false
	if data.has("requires_chapter_route") and get_chapter_2_route() != str(data.requires_chapter_route):
		return false
	if data.has("requires_public_liability"):
		var has_liability := not get_public_record_facts().is_empty()
		if get_dialogue_flag("case_resolved") and decisions.get("public_ending_variant", "") != "":
			has_liability = decisions.public_ending_variant == "accountable"
		if bool(data["requires_public_liability"]) != has_liability:
			return false
	var required_decisions: Dictionary = data.get("requires_decisions", {})
	for decision_id in required_decisions:
		if not decisions.has(decision_id) or decisions[decision_id] != required_decisions[decision_id]:
			return false
	var required_flags: Array = data.get("requires_flags", []).duplicate()
	if data.get("requires_flag", "") != "":
		required_flags.append(data["requires_flag"])
	for flag in required_flags:
		if not get_dialogue_flag(str(flag)):
			return false
	for flag in data.get("requires_missing_flags", []):
		if get_dialogue_flag(str(flag)):
			return false
	var required_evidence: Array = data.get("requires_evidences", []).duplicate()
	if data.get("requires_evidence", "") != "":
		required_evidence.append(data["requires_evidence"])
	for evidence_id in required_evidence:
		if not has_evidence(str(evidence_id)):
			return false
	var ending_id: String = data.get("requires_ending", "")
	return ending_id == "" or can_reach_ending(ending_id)

# --- Ending Calculation ---

func get_public_record_facts() -> Array[String]:
	var facts: Array[String] = []
	if get_dialogue_flag("auction_invitation_used"):
		facts.append("使用拍賣交割引介，留下具名查閱紀錄")
	if decisions.get("ajie_statement", "none") == "coerced":
		facts.append("以鷹眼推算向阿傑施壓" + ("（已撤回指認）" if get_dialogue_flag("ajie_statement_retracted") else "（未撤回指認）"))
	if decisions.get("market_claim_resolution", "none") == "pledge":
		facts.append("交給市場的受害者聯絡路由")
	if decisions.get("backup_handling", "none") == "copied":
		facts.append("未經浩然同意複製私人備份" + ("（已交還並刪除私留副本）" if get_dialogue_flag("backup_copy_deleted") else ""))
	if decisions.get("accepted_snake_deal", false):
		facts.append("交給蛇女的晶片副本")
	if decisions.get("memory_trade_method", "none") in ["buy", "intrude"]:
		facts.append("購買市場線索，留下報價權" if decisions.memory_trade_method == "buy" else "侵入市場，留下裝置識別")
	if decisions.get("ghost_identity_choice", "none") == "expose" or get_dialogue_flag("ghost_identity_exposed"):
		facts.append("出賣幽靈身份；補救不撤銷外流")
	if get_dialogue_flag("released_echo_ai") or decisions.get("echo_fate", "undecided") == "release":
		facts.append("釋放受害者私人記憶")
	if decisions.get("hq_entry_route", "none") == "corporate":
		facts.append("使用他人的企業身份通行")
	# Legacy saves can retain a transaction count without the original branch keys.
	if int(decisions.get("black_market_compromise_count", 0)) > 0:
		facts.append("保留的交易次數：" + str(decisions.black_market_compromise_count))
	return facts

func review_public_record() -> void:
	if get_dialogue_flag("final_choice_resolved") or get_dialogue_flag("case_resolved") or not get_dialogue_flag("public_sources_verified"):
		return
	set_decision("public_record_facts", get_public_record_facts())
	set_decision("public_record_reviewed", true)

func calculate_ending() -> String:
	if get_dialogue_flag("case_resolved"):
		return str(decisions.get("resolved_ending", ""))
	if not get_dialogue_flag("final_choice_resolved"):
		return ""
	var endings := {"public": "ending_a_justice", "deal": "ending_b_grey_deal", "memory": "ending_c_memory_rebirth"}
	var ending_id: String = endings.get(decisions.get("final_resolution", "undecided"), "")
	return ending_id if can_reach_ending(ending_id) else ""

func get_ending_requirements(ending_id: String) -> Array[String]:
	var missing: Array[String] = []
	if ending_id not in ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"]:
		missing.append("尚未選擇結局")
		return missing
	if current_chapter != 3:
		missing.append("進入第三章")
	var required_flags := {
		"hao_ran_rescued": "將浩然從提取椅安全救出",
		"xiao_confronted": "完成與蕭博士的對質",
		"core_evidence_secured": "封存伺服器中的核心證據"
	}
	var required_evidence := {
		"overwrite_report": "取得記憶覆寫技術報告",
		"zhengtek_funding": "取得正和科技資金流向",
		"authorization_order": "取得高層授權令"
	}
	if ending_id == "ending_a_justice":
		required_flags.merge({"trusted_zhao_ming": "取得趙明信任", "public_truth_ready": "確認公開證據鏈", "zhao_whistleblower_package": "完成保護證人身份的舉報包"})
		required_flags["public_sources_verified"] = "在總部核對獨立稽核紀錄與三份核心證據"
		if not decisions.get("public_record_reviewed", false) or decisions.get("public_record_facts", []) != get_public_record_facts():
			missing.append("在總部確認最新行動紀錄，交代自己的交易與資料外流")
	elif ending_id == "ending_c_memory_rebirth":
		required_flags.merge({"kai_memory_truth_reviewed": "核對三段真實記憶", "echo_choice_resolved": "回應迴響的要求", "memory_restoration_consented": "同意承擔記憶恢復的代價"})
		if decisions.get("memory_attitude", "neutral") != "accept" or decisions.get("echo_fate", "undecided") != "merge":
			missing.append("選擇與迴響融合並恢復記憶")
	for flag in required_flags:
		if not get_dialogue_flag(flag):
			missing.append(required_flags[flag])
	for evidence_id in required_evidence:
		if not has_evidence(evidence_id):
			missing.append(required_evidence[evidence_id])
	return missing

func can_reach_ending(ending_id: String) -> bool:
	return get_ending_requirements(ending_id).is_empty()

func complete_case(ending_id: String) -> void:
	if ending_id != "" and ending_id == calculate_ending():
		if ending_id == "ending_a_justice" and not get_dialogue_flag("case_resolved"):
			set_decision("public_ending_variant", "joint" if get_public_record_facts().is_empty() else "accountable")
		set_decision("resolved_ending", ending_id)
		set_dialogue_flag("case_resolved")

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
	collected_evidence.assign(data.get("collected_evidence", []))
	evidence_connections.assign(data.get("evidence_connections", []))
	action_points = data.get("action_points", 20)
	_reset_decisions()
	decisions.merge(data.get("decisions", {}), true)
	_reset_affinity()
	character_affinity.merge(data.get("character_affinity", {}), true)
	dialogue_flags = data.get("dialogue_flags", {})
	for decision_id in decisions:
		if decisions[decision_id] is bool:
			if dialogue_flags.has(decision_id):
				decisions[decision_id] = dialogue_flags[decision_id]
			else:
				dialogue_flags[decision_id] = decisions[decision_id]
	decisions["total_evidence_collected"] = collected_evidence.size()
	# Old pending public choices predate source verification and disclosure.
	# Reopen the decision rather than trapping the player behind the new gates.
	if not get_dialogue_flag("case_resolved") and get_dialogue_flag("final_choice_resolved") and decisions.get("final_resolution", "undecided") == "public" and not can_reach_ending("ending_a_justice"):
		set_dialogue_flag("final_choice_resolved", false)
		set_decision("final_resolution", "undecided")
	eagle_eye_active = false
	eagle_eye_energy = data.get("eagle_eye_energy", 100.0)
	set_state(GameState.PLAYING)
