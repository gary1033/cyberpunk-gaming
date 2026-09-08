extends SceneTree
## Run with Godot --headless --path . --script res://tests/test_playthrough.gd.
## Positive paths only use new_game, real map/story buttons, dialogue choices,
## and the evidence board. State injection is restricted to negative checks.

const CaseDataScript = preload("res://scripts/data/case_data.gd")
const DialogueDataScript = preload("res://scripts/data/dialogue_data.gd")
const ENDINGS := ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"]
const TEST_SAVE_SLOT := 8675309
const OPERATION_TIMEOUT_MS := 30000
const AUDIT_OUTPUT_DIR := "res://docs/verification/chapter_branches_2026_09_09/playthrough"

var gm: Node
var sm: Node
var saves: Node
var failed := false
var trace: Array[Dictionary] = []
var ending_under_test := ""
var p1_accountable := false
var eye_corporate := false
var scan_expansion := false
var alternate_scans := false
var saved_fixtures: Dictionary = {}
var test_save_existed := false
var test_save_bytes := PackedByteArray()
var last_dialogue_text: Array[String] = []
var visual_audit := false
var audit_captures: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	gm = root.get_node("GameManager")
	sm = root.get_node("SceneManager")
	saves = root.get_node("SaveManager")
	visual_audit = "--visual-audit" in OS.get_cmdline_user_args()
	# Accelerate presentation timers; no game-state or dialogue effects are skipped.
	Engine.time_scale = 20.0
	var save_path: String = saves._get_save_path(TEST_SAVE_SLOT)
	test_save_existed = FileAccess.file_exists(save_path)
	if test_save_existed:
		test_save_bytes = FileAccess.get_file_as_bytes(save_path)
	for scenario in ["a_accountable", "b_corporate", "c_shared", "c_private"] + ENDINGS:
		p1_accountable = scenario == "a_accountable"
		eye_corporate = scenario == "b_corporate"
		scan_expansion = scenario != "ending_c_memory_rebirth"
		alternate_scans = p1_accountable or eye_corporate or scenario == "c_private"
		var ending_id: String = "ending_a_justice" if p1_accountable else ("ending_b_grey_deal" if eye_corporate else ("ending_c_memory_rebirth" if scenario.begins_with("c_") else scenario))
		ending_under_test = scenario
		trace.clear()
		if not await _playthrough(ending_id):
			break
		if visual_audit:
			var report := FileAccess.open(AUDIT_OUTPUT_DIR + "/route.json", FileAccess.WRITE)
			report.store_string(JSON.stringify(trace, "\t"))
			break
	if not failed and not visual_audit:
		await _negative_checks()
	_restore_test_save()
	Engine.time_scale = 1.0
	root.get_node("AudioManager").stop_bgm(false)
	await create_timer(0.5).timeout # Let the audio thread release playback before exit.
	if failed:
		print("PLAYTHROUGH_FAIL ", JSON.stringify(trace))
		quit(1)
	else:
		print("PLAYTHROUGH_PASS: " + ("GPU A2 new-game route completed; screenshots and action trace saved" if visual_audit else "seven real new-game paths: A1/A2, both B care outcomes, shared/private/skipped C; both chapter-two routes, bidirectional switching, AP/chapters, save/load"))
		quit(0)


func _check(condition: bool, message: String) -> bool:
	if not condition:
		failed = true
		push_error("PLAYTHROUGH [%s] %s" % [ending_under_test, message])
	return condition


func _record(kind: String, detail: String) -> void:
	trace.append({"kind": kind, "detail": detail, "chapter": gm.current_chapter,
		"location": gm.current_location, "ap": gm.action_points,
		"evidence_count": gm.collected_evidence.size(),
		"deductions": gm.decisions.get("correct_deductions", 0)})


func _capture_audit(kind: String) -> void:
	if not visual_audit:
		return
	var key: String = "%s_%s" % [gm.current_location, kind]
	if audit_captures.has(key):
		return
	audit_captures[key] = true
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	var folder := AUDIT_OUTPUT_DIR
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	_check(root.get_texture().get_image().save_png(folder + "/" + key + ".png") == OK, "Audit screenshot saved")


func _settle() -> bool:
	var deadline := Time.get_ticks_msec() + OPERATION_TIMEOUT_MS
	await process_frame
	while sm._is_transitioning:
		if not _check(Time.get_ticks_msec() < deadline, "Scene transition timed out"):
			return false
		await process_frame
	await process_frame
	return true


func _button(node: Node, title: String, prefix: bool = false) -> Button:
	for child in node.get_children():
		if child is Button and (child.text == title or (prefix and child.text.begins_with(title))) and not child.is_queued_for_deletion():
			return child
		var found := _button(child, title, prefix)
		if found != null:
			return found
	return null


func _dialogue(preferred_next: Array = []) -> bool:
	last_dialogue_text.clear()
	var ds := get_first_node_in_group("dialogue_system")
	if not _check(ds != null, "Location has no real DialogueSystem"):
		return false
	var steps := 0
	while is_instance_valid(ds) and ds.visible:
		var shown_text: String = ds._current_dialogue[ds._current_index].get("text", "")
		if shown_text not in last_dialogue_text:
			last_dialogue_text.append(shown_text)
		steps += 1
		if not _check(steps < 2000, "Dialogue exceeded 2000 player advances"):
			return false
		if ds._is_typing:
			ds._finish_typing()
		await _capture_audit("choice" if ds.choices_container.visible else "dialogue")
		if ds._is_waiting_for_input:
			ds._advance()
		else:
			var entry: Dictionary = ds._current_dialogue[ds._current_index]
			var available: Array = ds._get_available_choices(entry.get("choices", []))
			if not _check(not available.is_empty(), "Dialogue stalled without advance or choices"):
				return false
			var selected: Dictionary = available[0]
			for wanted in preferred_next:
				var matched := false
				for candidate in available:
					if candidate.choice.get("next", "") == wanted:
						selected = candidate
						matched = true
						break
				if matched:
					break
			_record("choice", str(selected.choice.get("next", selected.choice.get("text", ""))))
			# Same handler used by the rendered choice buttons, including availability checks.
			ds._on_choice_pressed(int(selected.index))
		await process_frame
	return await _settle()


func _move(target: String, choices: Array = []) -> bool:
	var chapter_before: int = gm.current_chapter
	var ap_before: int = gm.action_points
	var chapter_data: Dictionary = CaseDataScript.get_chapter_data(chapter_before)
	var target_data: Dictionary = chapter_data.get("locations", {}).get(target, {})
	if not _check(not target_data.is_empty(), "Unknown map destination: " + target):
		return false
	current_scene._show_map()
	await _capture_audit("map")
	var popup := current_scene.get_child(current_scene.get_child_count() - 1)
	var destination := _button(popup, str(target_data.get("name", target)))
	if not _check(destination != null and not destination.disabled,
			"Destination unavailable from %s: %s" % [gm.current_location, target]):
		return false
	destination.pressed.emit()
	if not await _settle():
		return false
	if not _check(gm.current_location == target and current_scene.location_id == target,
			"Map did not load destination: " + target):
		return false
	if not _check(gm.current_chapter == chapter_before and gm.action_points == ap_before - 1,
			"Normal map move changed chapter or charged wrong AP"):
		return false
	_record("move", target)
	return await _dialogue(choices)


func _action(dialogue_id: String, choices: Array = [], expected_evidence: Array = []) -> bool:
	var selected: Dictionary = {}
	for action in current_scene._get_available_story_actions():
		if action.get("dialogue", "") == dialogue_id:
			selected = action
			break
	if not _check(not selected.is_empty(), "Story action unavailable: " + dialogue_id):
		return false
	if selected.has("scan_flag") and not gm.get_dialogue_flag(selected.scan_flag):
		var recharge_deadline := Time.get_ticks_msec() + OPERATION_TIMEOUT_MS
		while gm.eagle_eye_energy < float(selected.scan_cost):
			if not _check(Time.get_ticks_msec() < recharge_deadline, "Natural recharge timed out"):
				return false
			await create_timer(0.25).timeout
	# Use the real investigation menu and its connected button, not copied effects.
	current_scene._show_story_actions()
	var popup := current_scene.get_child(current_scene.get_child_count() - 1)
	var action_button := _button(popup, str(selected.get("title", "調查")), selected.has("scan_flag"))
	if not _check(action_button != null and not action_button.disabled, "Missing story button: " + dialogue_id):
		return false
	action_button.pressed.emit()
	_record("action", dialogue_id)
	if not await _dialogue(choices):
		return false
	if selected.has("scan_flag") and not _check(gm.get_dialogue_flag(selected.scan_flag), "Scan must actually charge and retain its result"):
		return false
	for evidence_id in expected_evidence:
		if not _check(gm.has_evidence(evidence_id), "%s did not award %s" % [dialogue_id, evidence_id]):
			return false
	return true


func _locked_action(dialogue_id: String) -> bool:
	var selected: Dictionary = {}
	for action in current_scene._get_location_story_actions():
		if action.get("dialogue", "") == dialogue_id:
			selected = action
			break
	if not _check(not selected.is_empty() and selected not in current_scene._get_available_story_actions(), "Premature action was not gated: " + dialogue_id):
		return false
	var state_before: Dictionary = gm.get_save_data().duplicate(true)
	current_scene._run_story_action(selected)
	if not _check(gm.get_save_data() == state_before and not get_first_node_in_group("dialogue_system").visible,
			"Forced locked story action changed progress: " + dialogue_id):
		return false
	_record("locked_action", dialogue_id)
	return true


func _deduce_available() -> bool:
	current_scene._open_evidence_board()
	var layer := current_scene.get_node("EvidenceBoardLayer")
	var board: Control = layer.get_child(0)
	for from_id in board.valid_connections:
		var to_id: String = board.valid_connections[from_id]
		if not gm.has_evidence(from_id) or not gm.has_evidence(to_id):
			continue
		var already_connected := false
		for connection in gm.evidence_connections:
			if (connection.from == from_id and connection.to == to_id) or (connection.from == to_id and connection.to == from_id):
				already_connected = true
		if already_connected:
			continue
		if not _check(board._cards.has(from_id) and board._cards.has(to_id), "Evidence cards missing from actual board"):
			return false
		var before: int = gm.decisions.get("correct_deductions", 0)
		board._handle_connection(from_id)
		board._handle_connection(to_id)
		if not _check(gm.decisions.get("correct_deductions", 0) == before + 1, "Real deduction did not register"):
			return false
		_record("deduction", "%s:%s" % [from_id, to_id])
	await _capture_audit("evidence_board")
	board.close()
	await process_frame
	return true


func _chapter_one(ending_id: String) -> bool:
	if not await _move("mei_ling_apartment"):
		return false
	for action_id in ["ch1_hao_ran_drawer_search", "ch1_original_backup_album", "ch1_family_memory_clip", "ch1_kai_eye_glitch_scan", "ch1_eleven_pm_call_log"]:
		if not await _action(action_id):
			return false
	if not await _move("east_district_street") or not await _move("old_city_police_outpost"):
		return false
	for action_id in ["ch1_old_city_queue_ticket", "ch1_old_city_police_outpost"]:
		if not await _action(action_id):
			return false
	if not await _move("east_district_street") or not await _action("ch1_street_camera_gap"):
		return false
	if scan_expansion and not await _action("ch1_scan_grid", ["grid_sabotage" if alternate_scans else "grid_infrastructure"]):
		return false
	if not await _move("dr_chen_clinic"):
		return false
	for action_id in ["ch1_clinic_anonymous_case_note", "ch1_dr_chen_clinic_followup"]:
		if not await _action(action_id):
			return false
	if not await _move("east_district_street") or not await _move("hao_ran_workshop"):
		return false
	if not await _deduce_available():
		return false
	for action_id in ["ch1_eye_signature_decode", "ch1_hao_ran_family_motive", "ch1_hao_ran_encrypted_message", "ch1_dr_chen_eye_warning"]:
		if not await _action(action_id):
			return false
	if not await _move("east_district_street") or not await _move("abyss_bar", ["ajie_ask", "ajie_receipt"]):
		return false
	if ending_id != "ending_c_memory_rebirth":
		var statement := "statement_coerced" if p1_accountable else ("statement_withheld" if ending_id == "ending_b_grey_deal" else "statement_voluntary")
		if not await _action("ch1_eye_ajie_statement", [statement]) or not _locked_action("ch1_eye_ajie_statement"):
			return false
		if p1_accountable and not await _action("ch1_ajie_retraction", ["statement_retracted"]):
			return false
	if not await _action("ch1_snake_encounter", ["snake_info", "snake_deal", "snake_deal_accept"]):
		return false
	var snake_choice := "snake_trade_accept" if ending_id == "ending_b_grey_deal" else "snake_trade_reject"
	if not await _action("ch1_snake_data_chip_choice", [snake_choice]):
		return false
	if not _check(gm.get_dialogue_flag("accepted_snake_deal") != gm.get_dialogue_flag("rejected_snake_deal"), "Snake mutually exclusive branches both applied"):
		return false
	if not await _move("abyss_bar_backroom"):
		return false
	for action_id in ["ch1_abyss_surveillance_delay_log", "ch1_abyss_backroom_investigation"]:
		if not await _action(action_id):
			return false
	if not await _deduce_available():
		return false
	if not await _move("abyss_bar") or not await _move("east_district_street") or not await _move("hao_ran_workshop"):
		return false
	var route_choice := "route_black_market" if ending_id == "ending_b_grey_deal" else "route_clinic"
	if not await _action("ch1_three_evidence_inference", [route_choice]):
		return false
	if not _check(gm.decisions.chapter_1_route_chosen == route_choice.trim_prefix("route_"), "Chapter-one route must not fall through into the other route"):
		return false
	return _check(gm.get_dialogue_flag("chapter_1_complete"), "Chapter 1 investigation never completed")


func _next_chapter(expected_chapter: int) -> bool:
	if not _check(gm.can_advance_chapter(), "Completed investigation did not unlock the next chapter"):
		return false
	current_scene._show_map()
	var popup := current_scene.get_child(current_scene.get_child_count() - 1)
	var next_button := _button(popup, "前往下一章", true)
	if not _check(next_button != null and not next_button.disabled, "Map lacks an available next-chapter button"):
		return false
	next_button.pressed.emit()
	if not await _settle():
		return false
	var chapter_data: Dictionary = CaseDataScript.get_chapter_data(expected_chapter)
	if not _check(gm.current_chapter == expected_chapter and gm.current_location == chapter_data.starting_location
			and current_scene.location_id == chapter_data.starting_location and gm.action_points == gm.max_action_points,
			"Chapter transition did not synchronize chapter, starting scene, location, and AP"):
		return false
	_record("chapter", str(expected_chapter))
	return await _dialogue()


func _chapter_two(ending_id: String) -> bool:
	if not await _next_chapter(2):
		return false
	if not _locked_action("ch2_conclude_investigation"):
		return false
	if not _locked_action("ch2_family_update"):
		return false
	if ending_id != "ending_b_grey_deal":
		if not await _action("ch2_kid_encounter", ["kid_echo_info"], ["echo_symbol"]):
			return false
		if not await _action("ch2_kid_encounter", ["kid_market_info", "kid_price", "kid_deal"], ["fake_id_chip"]):
			return false
	if not _check(gm.has_evidence("fake_id_chip") and gm.get_dialogue_flag("has_fake_id"), "Chosen chapter 1 route failed to provide a playable market entrance"):
		return false
	if not await _move("memory_black_market", ["market_special", "market_supplier"]):
		return false
	var trade_choice := "trade_buy" if ending_id == "ending_b_grey_deal" or p1_accountable else "trade_refuse"
	if ending_id == "ending_c_memory_rebirth":
		trade_choice = "trade_intrude"
	var compromises_before: int = gm.decisions.black_market_compromise_count
	if not await _action("ch2_memory_trade_choice", [trade_choice]):
		return false
	var trade_methods := {"trade_buy": "buy", "trade_intrude": "intrude", "trade_refuse": "refuse"}
	var expected_compromises := compromises_before + (1 if trade_choice == "trade_buy" else 0)
	if not _check(gm.decisions.memory_trade_method == trade_methods[trade_choice]
			and gm.decisions.black_market_compromise_count == expected_compromises, "Trade choice applied another branch or did not accumulate its cost"):
		return false
	if ending_id == "ending_b_grey_deal":
		if not await _action("ch2_ghost_encounter", ["ghost_deal"]):
			return false
	elif not await _action("ch2_ghost_encounter", ["ghost_confront"], ["comm_frequency"]):
		return false
	if not await _move("sewer_passage") or not await _move("abandoned_warehouse"):
		return false
	if not _check(gm.get_dialogue_flag("warehouse_investigated") and gm.has_evidence("hao_ran_diary") and gm.has_evidence("victim_list"), "Warehouse investigation did not complete through its dialogue"):
		return false
	if scan_expansion and not await _action("ch2_scan_warehouse_batch", ["batch_provenance" if alternate_scans else "batch_patients"]):
		return false
	if not await _move("sewer_passage"):
		return false
	if ending_id != "ending_c_memory_rebirth":
		if not await _move("memory_black_market"):
			return false
		if not await _action("ch2_eye_market_claim", ["claim_pledge" if p1_accountable else ("claim_refuse" if eye_corporate else "claim_bounded")]):
			return false
		if not await _move("sewer_passage"):
			return false
	var ghost_choice := "ghost_expose" if ending_id == "ending_b_grey_deal" or p1_accountable else "ghost_protect"
	if not await _action("ch2_ghost_identity_reveal", [ghost_choice]):
		return false
	if not _check(gm.get_dialogue_flag("ghost_protected") != gm.get_dialogue_flag("ghost_identity_exposed"), "Both ghost identity outcomes applied"):
		return false
	if ending_id != "ending_c_memory_rebirth":
		if not _locked_action("ch2_ghost_followup"):
			return false
		if not await _action("ch2_ghost_trace", ["trace_wrong", "end"]):
			return false
		if not _check(not gm.get_dialogue_flag("ghost_trace_verified"), "Wrong inference silently verified identity"):
			return false
		if not await _action("ch2_ghost_trace", ["trace_verify"], ["ghost_identity_trace"]):
			return false
		if not _locked_action("ch2_ghost_trace"):
			return false
		if not await _action("ch2_ghost_followup", ["end"]):
			return false
		if not _check(not gm.get_dialogue_flag("ghost_followup_resolved"), "Cancelled followup consumed the choice"):
			return false
		var followup := "followup_repair" if p1_accountable else ("followup_refuse" if ending_id == "ending_b_grey_deal" else "followup_protect")
		if not await _action("ch2_ghost_followup", [followup]) or not _locked_action("ch2_ghost_followup"):
			return false
		if p1_accountable and not _check(gm.get_dialogue_flag("ghost_identity_exposed") and not gm.get_dialogue_flag("ghost_protected") and gm.decisions.black_market_compromise_count >= 2, "Repair erased the identity harm or transaction history"):
			return false
		if not _save_roundtrip():
			return false
	if not await _move("zhengtek_exterior", ["zhao_trust", "zhao_trusted"]):
		return false
	if scan_expansion:
		if not await _action("ch2_scan_dispatch_clock", ["dispatch_redacted" if alternate_scans else "dispatch_sealed"]):
			return false
		if not await _move("civic_archive"):
			return false
		if not await _action("ch2_archive_returned_index", ["index_wrong"]):
			return false
		if not _check(not gm.get_dialogue_flag("archive_index_checked"), "Duplicate forms cannot be counted as separate victims"):
			return false
		if not await _action("ch2_archive_returned_index", ["index_checked"]):
			return false
		if not await _action("ch2_scan_withdrawal_queue", ["archive_observed" if alternate_scans else "archive_frozen"]):
			return false
		if not _save_roundtrip() or not await _move("zhengtek_exterior"):
			return false
	var verify_choice := "verify_private" if ending_id == "ending_b_grey_deal" else "verify_public"
	if not await _action("ch2_verify_zhengtek_memo", [verify_choice]):
		return false
	if not await _deduce_available():
		return false
	if not await _move("bitstorm_cafe"):
		return false
	if ending_id != "ending_c_memory_rebirth":
		var backup_choice := "backup_copied" if p1_accountable else ("backup_discarded" if ending_id == "ending_b_grey_deal" else "backup_sealed")
		if not await _action("ch2_eye_unsent_backup", [backup_choice]) or not _locked_action("ch2_eye_unsent_backup"):
			return false
	if ending_id != "ending_c_memory_rebirth":
		# Leaving the call undecided must not spend its one-time choice.
		if not await _action("ch2_family_update", ["end"]):
			return false
		if not _check(not gm.get_dialogue_flag("family_update_resolved") and gm.decisions.family_update_choice == "none", "Cancelled family call recorded a choice"):
			return false
		var family_choice := "candid" if ending_id == "ending_a_justice" else "guarded"
		if not await _action("ch2_family_update", ["family_update_" + family_choice]):
			return false
		if not _check(gm.decisions.family_update_choice == family_choice, "Family call selected another branch") or not _locked_action("ch2_family_update"):
			return false
	if not await _complete_second_route():
		return false
	if not await _action("ch2_conclude_investigation", ["ch2_confirmed"]):
		return false
	return _check(gm.get_dialogue_flag("chapter_2_complete"), "Chapter 2 did not complete through the investigation action")


func _complete_second_route() -> bool:
	if not _locked_action("ch2_conclude_investigation"):
		return false
	var route: String = gm.get_chapter_2_route()
	if route == "clinic":
		if not await _move("referral_waiting_station"):
			return false
		if not await _action("ch2_referral_number", ["referral_wrong"]) or not await _action("ch2_referral_number", ["referral_correct"]):
			return false
		if not await _move("civic_archive"):
			return false
		if not gm.get_dialogue_flag("eye_withdrawal_scanned") and not await _action("ch2_scan_withdrawal_queue", ["archive_frozen"]):
			return false
		if not await _action("ch2_referral_reassigned", ["referral_reroute_wrong"]) or not await _action("ch2_referral_reassigned", ["referral_reroute_correct"]):
			return false
		if p1_accountable:
			if not await _move("bitstorm_cafe") or not await _action("ch2_branch_direction", ["switch_market", "switched_market"]):
				return false
			if not await _move("memory_black_market") or not await _move("auction_handover_room"):
				return false
			if not await _action("ch2_auction_batch", ["auction_batch_correct"]) or not await _action("ch2_auction_access", ["auction_public"]):
				return false
			if not await _move("sewer_passage") or not await _move("bitstorm_cafe") or not await _action("ch2_branch_direction", ["switch_clinic", "switched_clinic"]):
				return false
			if not _check(gm.get_dialogue_flag("referral_reroute_checked") and gm.decisions.chapter_1_route_chosen == "clinic", "Switching erased route observations or chapter-one history"):
				return false
		if not await _move("referral_waiting_station") or not await _action("ch2_referral_priority", ["medical_batch" if alternate_scans else "medical_patient"]):
			return false
		if not await _move("bitstorm_cafe"):
			return false
	else:
		if not await _move("memory_black_market") or not await _move("auction_handover_room"):
			return false
		if not await _action("ch2_auction_batch", ["auction_batch_wrong"]) or not await _action("ch2_auction_batch", ["auction_batch_correct"]):
			return false
		if not await _action("ch2_auction_access", ["auction_named" if eye_corporate else "auction_public"]):
			return false
		if not await _action("ch2_auction_priority", ["market_dispatch" if alternate_scans else "market_ledger"]):
			return false
		if not await _move("sewer_passage") or not await _move("bitstorm_cafe"):
			return false
	return _check(gm.get_dialogue_flag("ch2_branch_complete"), "Route final event did not unlock chapter completion") and _save_roundtrip() and _locked_action("ch2_branch_direction")


func _chapter_three(ending_id: String) -> bool:
	if not await _next_chapter(3):
		return false
	if not _locked_action("ch3_memory_corridor"):
		return false
	if not await _action("ch3_hq_entry", ["end"]):
		return false
	if not _check(not gm.get_dialogue_flag("hq_entry_resolved"), "Cancelled entry unlocked core investigation"):
		return false
	var expected_route := "corporate" if ending_id == "ending_b_grey_deal" else ("independent" if ending_id == "ending_c_memory_rebirth" else "ghost")
	var entry_choices: Array = ["entry_" + expected_route, "entry_" + expected_route + "_ok"]
	if p1_accountable:
		# A revoked identity must not be offered even when explicitly preferred.
		entry_choices.push_front("entry_corporate")
	if not await _action("ch3_hq_entry", entry_choices):
		return false
	if not _check(gm.decisions.hq_entry_route == expected_route, "Entry route ignored prior choices or repaired credential revocation") or not _locked_action("ch3_hq_entry"):
		return false
	if not _locked_action("ch3_secure_core_evidence"):
		return false
	if not await _action("ch3_memory_corridor", [], ["authorization_order"]) or not await _action("ch3_secure_core_evidence", [], ["zhengtek_funding"]):
		return false
	if not await _move("secret_lab", ["xiao_kai_memory"]):
		return false
	if not _check(gm.has_evidence("overwrite_report") and gm.get_dialogue_flag("xiao_confronted"), "Confrontation did not supply the technical report"):
		return false
	if scan_expansion:
		if not await _action("ch3_scan_override_console"):
			return false
		if not await _action("ch3_xiao_record_challenge", ["challenge_funding"]):
			return false
		if not _check(not gm.get_dialogue_flag("xiao_record_challenge_resolved"), "Wrong evidence must allow another question"):
			return false
		if not await _action("ch3_xiao_record_challenge", ["challenge_disputed" if alternate_scans else "challenge_admitted"]):
			return false
	if not _locked_action("ch3_rescue_hao_ran"):
		return false
	if not await _action("ch3_hao_ran_found"):
		return false
	if not _check(gm.get_dialogue_flag("hao_ran_located") and not gm.get_dialogue_flag("hao_ran_rescued"), "Finding Hao Ran incorrectly counts as completing his rescue"):
		return false
	for candidate in ENDINGS:
		if not _check(not gm.can_reach_ending(candidate), "Ending unlocked before the actual rescue"):
			return false
	if not await _action("ch3_rescue_hao_ran", ["rescue_disconnect"]):
		return false
	if not _check(gm.get_dialogue_flag("hao_ran_rescued"), "Rescue dialogue did not evacuate Hao Ran"):
		return false
	if scan_expansion:
		if not await _move("recovery_annex"):
			return false
		if not await _action("ch3_recovery_quiet", ["quiet_space" if alternate_scans else "quiet_stay"]):
			return false
		if not await _action("ch3_scan_recovery_route", ["recovery_direct" if alternate_scans else "recovery_paper"]):
			return false
		if not _save_roundtrip() or not await _move("secret_lab"):
			return false
	if ending_id != "ending_c_memory_rebirth":
		var custody := "custody_owner" if p1_accountable else ("custody_absent" if ending_id == "ending_b_grey_deal" else "custody_clinic")
		if not await _action("ch3_backup_permission", [custody]) or not _locked_action("ch3_backup_permission"):
			return false
		if p1_accountable and not _check(gm.get_public_record_facts().size() >= 3 and gm.get_dialogue_flag("backup_copy_deleted"), "Repair must retain scan-related disclosure facts"):
			return false
	if not await _move("echo_network_hq"):
		return false
	if ending_id == "ending_a_justice":
		if not _check(not gm.can_reach_ending(ending_id), "Public ending unlocked before source verification"):
			return false
		if not await _action("ch3_verify_public_sources", ["sources_wrong", "end"]):
			return false
		if not _check(not gm.get_dialogue_flag("public_sources_verified"), "Circular source verification accepted"):
			return false
		if not await _action("ch3_verify_public_sources", ["sources_verified"]):
			return false
		if not await _action("ch3_review_public_record", ["end"]):
			return false
		if not _check(not gm.decisions.public_record_reviewed, "Cancelled disclosure signed itself"):
			return false
		if not await _action("ch3_review_public_record", ["record_confirm"]):
			return false
	if ending_id == "ending_a_justice" and not await _action("ch3_zhao_whistleblower"):
		return false
	var memory_choice := "echo_accept_memory" if ending_id == "ending_c_memory_rebirth" else "echo_deny_memory"
	if not await _move("memory_space", [memory_choice]):
		return false
	if not _locked_action("ch3_kai_fragment_3"):
		return false
	for fragment in ["ch3_kai_fragment_1", "ch3_kai_fragment_2", "ch3_kai_fragment_3"]:
		if not await _action(fragment):
			return false
	if scan_expansion and not await _action("ch3_scan_memory_anchor", ["anchor_private" if alternate_scans else "anchor_shared"]):
		return false
	var echo_choice := "echo_contain"
	if ending_id == "ending_b_grey_deal" or p1_accountable:
		echo_choice = "echo_release"
	elif ending_id == "ending_c_memory_rebirth":
		echo_choice = "echo_merge"
	if not await _action("ch3_echo_release_choice", [echo_choice]):
		return false
	if not await _deduce_available():
		return false
	if not await _move("echo_network_hq"):
		return false
	if p1_accountable:
		if not _check(not gm.can_reach_ending(ending_id), "Earlier disclosure covered a later private-memory release"):
			return false
		if not await _action("ch3_review_public_record", ["record_confirm"]):
			return false
	if not await _move("secret_lab") or not await _move("rooftop"):
		return false
	if ending_id == "ending_b_grey_deal":
		var terms := "corporate" if eye_corporate else "independent"
		if not await _action("ch3_grey_care_terms", ["care_" + terms]):
			return false
		if not _check(gm.decisions.grey_care_terms == terms and gm.decisions.final_resolution == "undecided", "Prepared care terms must not choose an ending"):
			return false
	if ending_id != "ending_c_memory_rebirth":
		var aftercare_choices: Array = ["aftercare_ask", "aftercare_record"] if ending_id == "ending_a_justice" else ["aftercare_rest"]
		if not await _action("ch3_hao_ran_aftercare", aftercare_choices):
			return false
		if not _check(gm.get_dialogue_flag("hao_ran_testimony_consented") == (ending_id == "ending_a_justice"), "Rest or skipped care must not grant testimony consent"):
			return false
		if not _locked_action("ch3_hao_ran_aftercare"):
			return false
	if not _check(gm.can_reach_ending(ending_id), "Earned path still lacks ending prerequisites: %s" % str(gm.get_ending_requirements(ending_id))):
		return false
	if not _check(gm.calculate_ending() == "", "An ending was selected automatically before the player's final choice"):
		return false
	var resolution_choices := {"ending_a_justice": "rooftop_public", "ending_b_grey_deal": "rooftop_deal", "ending_c_memory_rebirth": "rooftop_memory"}
	if not await _action("ch3_rooftop_choice", [resolution_choices[ending_id]]):
		return false
	if not _locked_action("ch3_hao_ran_aftercare"):
		return false
	if not _check(gm.calculate_ending() == ending_id and not gm.get_dialogue_flag("case_resolved"), "Final choice selected the wrong ending or finished it before playback"):
		return false
	saved_fixtures[ending_id] = gm.get_save_data().duplicate(true)
	if not _save_roundtrip():
		return false
	if not await _play_ending(ending_id):
		return false
	if ending_id == "ending_c_memory_rebirth":
		var memory_text := "\n".join(last_dialogue_text)
		if not _check(memory_text.contains("生活紀錄") == (scan_expansion and not alternate_scans) and memory_text.contains("密封信") == (scan_expansion and alternate_scans), "C must show only the chosen continuity outcome"):
			return false
	if ending_id == "ending_a_justice":
		var variant := "accountable" if p1_accountable else "joint"
		if not _check(gm.decisions.public_ending_variant == variant, "Public ending variant was not saved"):
			return false
		var public_text := "\n".join(last_dialogue_text)
		var variant_title := "帶罪揭露" if p1_accountable else "共同作證"
		var other_title := "共同作證" if p1_accountable else "帶罪揭露"
		if not _check(variant_title in public_text and other_title not in public_text, "Public variants played together or the earned scene was missing"):
			return false
	if not await _move("office_epilogue"):
		return false
	var expected_epilogues := {
		"ending_a_justice": ["記者", "那通電話之後", "那段錄音我聽過了"],
		"ending_b_grey_deal": ["照護費已經到了", "那時候你可以告訴我", "我睡了一整天"],
		"ending_c_memory_rebirth": ["我叫林美玲", "每隔十分鐘", "那晚太亂了"]
	}
	var family_text := "\n".join(last_dialogue_text)
	for expected_line in expected_epilogues[ending_id]:
		if not _check(expected_line in family_text, "Missing earned family consequence: " + expected_line):
			return false
	if not _check(gm.get_dialogue_flag("epilogue_family_seen"), "Office did not finish its distinct family epilogue"):
		return false
	if not await _action("ch3_epilogue_contacts") or not _locked_action("ch3_epilogue_contacts"):
		return false
	if not _check(("訊息退回了" in "\n".join(last_dialogue_text)) == (ending_id == "ending_b_grey_deal"), "Ghost aftermath ignored identity choice"):
		return false
	_record("ending_complete", ending_id)
	print("PLAYTHROUGH_ROUTE ", JSON.stringify({"ending": ending_id, "steps": trace.size(), "evidence": gm.collected_evidence.size(), "deductions": gm.decisions.correct_deductions, "decisions": gm.decisions, "trace": trace}))
	return true


func _save_roundtrip() -> bool:
	var expected_ending: String = gm.calculate_ending()
	var expected: Dictionary = gm.get_save_data().duplicate(true)
	saves.save_game(TEST_SAVE_SLOT)
	if not _check(saves.has_save(TEST_SAVE_SLOT), "SaveManager failed to create the isolated test save"):
		return false
	gm.new_game()
	if not _check(saves.load_game(TEST_SAVE_SLOT), "SaveManager could not load the just-created save"):
		return false
	var actual: Dictionary = gm.get_save_data()
	for key in ["current_chapter", "current_location", "collected_evidence", "evidence_connections", "action_points", "decisions", "character_affinity"]:
		if not _check(actual[key] == expected[key], "Save/load did not preserve " + key):
			return false
	# Save migration may explicitly materialize boolean decision aliases. Compare
	# their meaning (an absent flag is false), while retaining every original flag.
	var flag_ids: Dictionary = expected.dialogue_flags.duplicate()
	flag_ids.merge(actual.dialogue_flags)
	for flag in flag_ids:
		var expected_value: bool = expected.dialogue_flags.get(flag, expected.decisions.get(flag, false))
		if not _check(actual.dialogue_flags.get(flag, false) == expected_value, "Save/load changed the flag " + flag):
			return false
	return _check(gm.calculate_ending() == expected_ending, "Save/load changed the player's final resolution")


func _play_ending(ending_id: String) -> bool:
	var selected: Dictionary = {}
	for action in current_scene._get_available_story_actions():
		if action.get("use_calculated_ending", false):
			selected = action
			break
	if not _check(not selected.is_empty(), "Final playback action did not unlock"):
		return false
	current_scene._show_story_actions()
	var popup := current_scene.get_child(current_scene.get_child_count() - 1)
	var play_button := _button(popup, str(selected.title))
	if not _check(play_button != null, "Final playback button missing"):
		return false
	play_button.pressed.emit()
	var ds := get_first_node_in_group("dialogue_system")
	if not _check(ds.visible and ds._current_dialogue == DialogueDataScript.get_dialogue(ending_id), "Final action loaded the wrong ending dialogue"):
		return false
	if not _check(not gm.get_dialogue_flag("case_resolved"), "Case resolved before the ending dialogue finished"):
		return false
	if not await _dialogue():
		return false
	return _check(gm.get_dialogue_flag("case_resolved") and gm.decisions.get("resolved_ending", "") == ending_id, "Ending playback did not seal the resolved case")


func _playthrough(ending_id: String) -> bool:
	gm.new_game()
	sm.change_scene("detective_office")
	if not await _settle() or not await _dialogue(["mei_ling_case_intro", "mei_ling_abnormal", "mei_ling_accept"]):
		return false
	if not _check(gm.has_evidence("commission_letter") and gm.has_evidence("work_id") and gm.has_evidence("abyss_receipt"), "Opening path did not supply investigation evidence"):
		return false
	if not await _chapter_one(ending_id):
		return false
	if not await _chapter_two(ending_id):
		return false
	return await _chapter_three(ending_id)


func _negative_checks() -> bool:
	ending_under_test = "negative prerequisites"
	trace.clear()
	for ending_id in ENDINGS:
		for flag in ["hao_ran_rescued", "xiao_confronted", "core_evidence_secured"]:
			var fixture: Dictionary = saved_fixtures[ending_id].duplicate(true)
			fixture.dialogue_flags.erase(flag)
			if fixture.decisions.has(flag):
				fixture.decisions[flag] = false
			if not _blocked_resolution(ending_id, fixture, "missing " + flag):
				return false
		for evidence_id in ["overwrite_report", "zhengtek_funding", "authorization_order"]:
			var fixture: Dictionary = saved_fixtures[ending_id].duplicate(true)
			fixture.collected_evidence.erase(evidence_id)
			if not _blocked_resolution(ending_id, fixture, "missing " + evidence_id):
				return false
		var earlier_chapter: Dictionary = saved_fixtures[ending_id].duplicate(true)
		earlier_chapter.current_chapter = 2
		if not _blocked_resolution(ending_id, earlier_chapter, "still in chapter 2"):
			return false
		var undecided: Dictionary = saved_fixtures[ending_id].duplicate(true)
		undecided.dialogue_flags.erase("final_choice_resolved")
		undecided.decisions.final_resolution = "undecided"
		gm.load_save_data(undecided)
		if not _check(gm.calculate_ending() == "", "No explicit final choice incorrectly falls back to an ending"):
			return false
	var unique_flags := {
		"ending_a_justice": ["trusted_zhao_ming", "public_truth_ready", "zhao_whistleblower_package", "public_sources_verified", "public_record_reviewed"],
		"ending_c_memory_rebirth": ["kai_memory_truth_reviewed", "echo_choice_resolved", "memory_restoration_consented"]}
	for ending_id in unique_flags:
		for flag in unique_flags[ending_id]:
			var fixture: Dictionary = saved_fixtures[ending_id].duplicate(true)
			fixture.dialogue_flags.erase(flag)
			if fixture.decisions.has(flag):
				fixture.decisions[flag] = false
			if not _blocked_resolution(ending_id, fixture, "missing " + flag):
				return false
	var old_pending: Dictionary = saved_fixtures["ending_a_justice"].duplicate(true)
	old_pending.decisions.erase("public_record_reviewed")
	old_pending.decisions.erase("public_record_facts")
	old_pending.dialogue_flags.erase("public_record_reviewed")
	old_pending.dialogue_flags.erase("public_sources_verified")
	gm.load_save_data(old_pending)
	if not _check(not gm.get_dialogue_flag("final_choice_resolved") and gm.decisions.final_resolution == "undecided", "Legacy pending public choice could not return for verification"):
		return false
	old_pending.dialogue_flags["case_resolved"] = true
	old_pending.decisions["resolved_ending"] = "ending_a_justice"
	gm.load_save_data(old_pending)
	if not _check(gm.calculate_ending() == "ending_a_justice", "Legacy completed ending was revoked"):
		return false
	gm.load_save_data(saved_fixtures["ending_a_justice"].duplicate(true))
	gm.dialogue_flags.erase("echo_choice_resolved")
	gm.current_location = "memory_space"
	gm.set_dialogue_flag("visited_memory_space")
	sm.change_scene("memory_space")
	if not await _settle() or not _locked_action("ch3_echo_release_choice"):
		return false
	var excessive_compromise: Dictionary = saved_fixtures["ending_a_justice"].duplicate(true)
	excessive_compromise.decisions.black_market_compromise_count = 2
	if not _blocked_resolution("ending_a_justice", excessive_compromise, "undisclosed legacy transaction history"):
		return false
	for changed_decision in [{"memory_attitude": "deny"}, {"echo_fate": "release"}]:
		var fixture: Dictionary = saved_fixtures["ending_c_memory_rebirth"].duplicate(true)
		fixture.decisions.merge(changed_decision, true)
		if not _blocked_resolution("ending_c_memory_rebirth", fixture, str(changed_decision)):
			return false
	gm.load_save_data(saved_fixtures["ending_c_memory_rebirth"].duplicate(true))
	if not _check(not gm.can_advance_chapter() and not await gm.advance_chapter() and gm.current_chapter == 3, "Game advanced to nonexistent chapter 4"):
		return false
	if not await _action_point_checks():
		return false
	if not await _save_guard_checks():
		return false
	if not await _homecoming_checks():
		return false
	print("PLAYTHROUGH_NEGATIVE_PASS ", JSON.stringify(trace))
	return true


func _homecoming_checks() -> bool:
	ending_under_test = "homecoming branch isolation"
	if not _check(not gm.meets_story_conditions({"requires_decisions": {"unknown_decision": null}}), "Unknown requirement must not match a missing decision"):
		return false
	gm.set_dialogue_flag("case_resolved")
	gm.set_decision("resolved_ending", "ending_a_justice")
	sm.change_scene("office_epilogue")
	if not await _settle() or not await _dialogue():
		return false
	var ending_lines := {"ending_a_justice": "今天有記者", "ending_b_grey_deal": "照護費已經到了", "ending_c_memory_rebirth": "我叫林美玲"}
	var family_lines := {"candid": "那通電話之後", "guarded": "那時候你可以告訴我", "none": "每隔十分鐘"}
	var care_lines := {"rest": "我睡了一整天", "testimony": "那段錄音我聽過了", "none": "那晚太亂了"}
	# Fixtures vary saved choices; dialogue still runs through its real page/choice handlers.
	for ending_id in ENDINGS:
		for family_choice in family_lines:
			for care_choice in care_lines:
				var fixture: Dictionary = saved_fixtures[ending_id].duplicate(true)
				fixture.decisions.resolved_ending = ending_id
				fixture.decisions.family_update_choice = family_choice
				fixture.decisions.hao_ran_aftercare = care_choice
				fixture.dialogue_flags.case_resolved = true
				gm.load_save_data(fixture)
				get_first_node_in_group("dialogue_system").start_dialogue(DialogueDataScript.get_dialogue("ch3_epilogue_family"))
				if not await _dialogue():
					return false
				var shown := "\n".join(last_dialogue_text)
				for group in [[ending_lines, ending_id], [family_lines, family_choice], [care_lines, care_choice]]:
					for key in group[0]:
						if not _check((str(group[0][key]) in shown) == (key == group[1]), "Epilogue mixed mutually exclusive choices: %s / %s / %s" % [ending_id, family_choice, care_choice]):
							return false
				var testimony_followup := "複核完" if ending_id == "ending_a_justice" else ("核心證據一起交出去" if ending_id == "ending_b_grey_deal" else "袋上的使用範圍")
				if not _check((testimony_followup in shown) == (care_choice == "testimony"), "Compound ending/testimony requirement ignored"):
					return false
	_record("homecoming_matrix", "27 saved ending/family/care combinations show only their own consequences")
	return true


func _blocked_resolution(ending_id: String, fixture: Dictionary, reason: String) -> bool:
	gm.load_save_data(fixture)
	if not _check(not gm.can_reach_ending(ending_id) and not gm.get_ending_requirements(ending_id).is_empty()
			and gm.calculate_ending() == "", "%s was not blocked: %s" % [ending_id, reason]):
		return false
	gm.set_dialogue_flag("final_choice_resolved", false)
	gm.set_decision("final_resolution", "undecided")
	# Reopen the actual final dialogue and invoke a now-ineligible original index.
	# This represents a stale/forged button activation after prerequisites changed.
	var ds := get_first_node_in_group("dialogue_system")
	ds.start_dialogue(DialogueDataScript.get_dialogue("ch3_rooftop_choice"))
	for step in 100:
		if ds._is_typing:
			ds._finish_typing()
		if not ds._is_waiting_for_input:
			break
		ds._advance()
		if not _check(ds.visible, "Final choice dialogue ended before exposing its choices"):
			return false
	var resolution_choices := {"ending_a_justice": "rooftop_public", "ending_b_grey_deal": "rooftop_deal", "ending_c_memory_rebirth": "rooftop_memory"}
	var entry: Dictionary = ds._current_dialogue[ds._current_index]
	var choices: Array = entry.get("choices", [])
	var rejected_index := -1
	for index in choices.size():
		if choices[index].get("next", "") == resolution_choices[ending_id]:
			rejected_index = index
	if not _check(rejected_index >= 0 and not ds._is_choice_available(choices[rejected_index]), "Prerequisite failure did not hide the final choice: " + reason):
		return false
	var decisions_before: Dictionary = gm.decisions.duplicate(true)
	var flags_before: Dictionary = gm.dialogue_flags.duplicate(true)
	var entry_before: int = ds._current_index
	ds._on_choice_pressed(rejected_index)
	if not _check(gm.decisions == decisions_before and gm.dialogue_flags == flags_before and ds._current_index == entry_before,
			"Ineligible choice applied effects when invoked directly: " + reason):
		return false
	ds.end_dialogue()
	_record("blocked", ending_id + ": " + reason)
	return true


func _action_point_checks() -> bool:
	ending_under_test = "negative AP and chapters"
	gm.new_game()
	sm.change_scene("detective_office")
	if not await _settle() or not await _dialogue():
		return false
	# Deliberate boundary injection, only in this negative test.
	gm.action_points = 1
	if not await _move("mei_ling_apartment"):
		return false
	if not _check(gm.action_points == 0 and gm.current_chapter == 1, "Spending the last AP advanced the chapter"):
		return false
	current_scene._show_map()
	var popup := current_scene.get_node("LocationMap")
	var office_data: Dictionary = CaseDataScript.get_chapter_data(1).locations.detective_office
	var destination := _button(popup, str(office_data.name))
	if not _check(destination != null and destination.disabled, "AP 0 map destination was not disabled"):
		return false
	var state_before: Dictionary = gm.get_save_data().duplicate(true)
	destination.pressed.emit()
	if not await _settle():
		return false
	if not _check(gm.current_location == state_before.current_location and gm.current_chapter == 1 and gm.action_points == 0,
			"Forced AP 0 map button moved or changed the chapter"):
		return false
	if not _check(not await sm.travel_to_location("detective_office"), "Travel API accepted an AP 0 request"):
		return false
	if not _check(not gm.can_advance_chapter() and not await gm.advance_chapter(), "Incomplete chapter advanced without investigation"):
		return false
	popup = current_scene.get_node_or_null("LocationMap")
	if popup == null:
		current_scene._show_map()
		popup = current_scene.get_node("LocationMap")
	if not _check(_button(popup, "前往下一章", true) == null, "Incomplete chapter showed a next-chapter button"):
		return false
	var rest_button := _button(popup, "休整（恢復全部行動力）")
	if not _check(rest_button != null and not rest_button.disabled, "AP 0 recovery is unavailable"):
		return false
	rest_button.pressed.emit()
	if not await _settle():
		return false
	if not _check(gm.action_points == gm.max_action_points and gm.current_chapter == 1
			and gm.current_location == state_before.current_location and gm.dialogue_flags == state_before.dialogue_flags
			and gm.collected_evidence == state_before.collected_evidence and gm.decisions == state_before.decisions,
			"Rest changed story progress or failed to restore AP"):
		return false
	# A button shown at positive AP must still revalidate after the AP changes.
	popup = current_scene.get_node("LocationMap")
	destination = _button(popup, str(office_data.name))
	if not _check(destination != null and not destination.disabled, "Rest did not refresh map availability"):
		return false
	gm.action_points = 0
	destination.pressed.emit()
	if not await _settle():
		return false
	if not _check(gm.current_location == state_before.current_location and gm.action_points == 0, "Stale enabled map button bypassed AP validation"):
		return false
	_record("boundary", "last AP, forced/stale map buttons, rest, incomplete chapter, and chapter 4")
	return true


func _save_guard_checks() -> bool:
	ending_under_test = "negative save compatibility and guards"
	# An old save can lack newly introduced decision keys and was opened from the
	# main menu. Preserve the real save's typed evidence arrays; the compatibility
	# condition under test is missing new decision keys, not a truncated save.
	var legacy_save: Dictionary = saved_fixtures["ending_a_justice"].duplicate(true)
	legacy_save.decisions = {"memory_attitude": "deny", "black_market_compromise_count": 3}
	legacy_save.dialogue_flags = {"legacy_investigation_seen": true}
	gm.set_state(gm.GameState.MAIN_MENU)
	gm.load_save_data(legacy_save)
	if not _check(gm.current_state == gm.GameState.PLAYING
			and gm.decisions.memory_attitude == "deny" and gm.decisions.black_market_compromise_count == 3
			and gm.decisions.get("echo_fate", "missing") == "undecided"
			and gm.decisions.get("final_resolution", "missing") == "undecided"
			and gm.decisions.get("family_update_choice", "missing") == "none"
			and gm.decisions.get("hao_ran_aftercare", "missing") == "none"
			and gm.decisions.get("resolved_ending", "missing") == ""
			and gm.get_dialogue_flag("legacy_investigation_seen"), "Legacy load did not restore PLAYING and merge new defaults"):
		return false
	_record("save_boundary", "legacy defaults and MAIN_MENU to PLAYING")
	# Missing array fields exercise the loader's declared empty-array defaults.
	# These arrive as untyped Arrays and must be accepted by the typed game state.
	gm.set_state(gm.GameState.MAIN_MENU)
	gm.load_save_data({"current_chapter": 2, "current_location": "bitstorm_cafe",
		"decisions": {"memory_attitude": "deny", "black_market_compromise_count": 3},
		"dialogue_flags": {"legacy_investigation_seen": true}})
	if not _check(gm.current_state == gm.GameState.PLAYING
			and gm.collected_evidence.is_empty() and gm.evidence_connections.is_empty()
			and gm.decisions.memory_attitude == "deny" and gm.decisions.black_market_compromise_count == 3
			and gm.decisions.get("echo_fate", "missing") == "undecided"
			and gm.decisions.get("final_resolution", "missing") == "undecided"
			and gm.decisions.get("resolved_ending", "missing") == ""
			and gm.get_dialogue_flag("legacy_investigation_seen"), "Save load rejected omitted arrays or lost legacy defaults"):
		return false
	_record("save_boundary", "omitted evidence arrays load as typed empty arrays")
	gm.load_save_data(saved_fixtures["ending_a_justice"].duplicate(true))
	sm.change_scene("rooftop")
	if not await _settle():
		return false
	saves.save_game(TEST_SAVE_SLOT)
	var save_path: String = saves._get_save_path(TEST_SAVE_SLOT)
	var bytes_before := FileAccess.get_file_as_bytes(save_path)
	if not _check(not bytes_before.is_empty(), "Save rejection test needs an existing valid save"):
		return false
	var failure_signals: Array[Dictionary] = []
	var on_save_failed: Callable = func(slot: int, error: String):
		failure_signals.append({"slot": slot, "error": error})
	saves.save_failed.connect(on_save_failed)
	var ds := get_first_node_in_group("dialogue_system")
	ds.start_dialogue(DialogueDataScript.get_dialogue("ch3_rooftop_choice"))
	var child_count_before := current_scene.get_child_count()
	current_scene._open_evidence_board()
	current_scene._show_story_actions()
	if not _check(current_scene.get_child_count() == child_count_before and ds.visible and gm.current_state == gm.GameState.DIALOGUE,
			"Overlay entry interrupted dialogue and enabled mid-dialogue saving"):
		return false
	saves.save_game(TEST_SAVE_SLOT)
	var dialogue_rejected := _check(gm.current_state == gm.GameState.DIALOGUE
			and failure_signals.size() == 1 and failure_signals[0].slot == TEST_SAVE_SLOT
			and not str(failure_signals[0].error).is_empty()
			and FileAccess.get_file_as_bytes(save_path) == bytes_before,
			"Saving during dialogue did not signal failure and preserve existing save bytes")
	ds.end_dialogue()
	if not dialogue_rejected:
		saves.save_failed.disconnect(on_save_failed)
		return false
	# Begin a real transition without awaiting its presentation tween, then try
	# to overwrite the same slot while the global game state is still PLAYING.
	sm.change_scene("secret_lab")
	var transition_started := _check(sm.is_transitioning() and gm.current_state == gm.GameState.PLAYING,
			"Save rejection test did not enter a real scene transition")
	saves.save_game(TEST_SAVE_SLOT)
	var transition_rejected := _check(failure_signals.size() == 2
			and failure_signals[1].slot == TEST_SAVE_SLOT and not str(failure_signals[1].error).is_empty()
			and FileAccess.get_file_as_bytes(save_path) == bytes_before,
			"Saving during transition did not signal failure and preserve existing save bytes")
	saves.save_failed.disconnect(on_save_failed)
	if not await _settle():
		return false
	if not transition_started or not transition_rejected:
		return false
	_record("save_boundary", "DIALOGUE and real transition reject writes with save_failed and unchanged bytes")
	return true


func _restore_test_save() -> void:
	if test_save_existed:
		var file := FileAccess.open(saves._get_save_path(TEST_SAVE_SLOT), FileAccess.WRITE)
		if file != null:
			file.store_buffer(test_save_bytes)
			file.close()
	else:
		saves.delete_save(TEST_SAVE_SLOT)
