extends SceneTree
## Scan charging, retained results, branch consequences, and live evidence readings.

var checks := 0
var failures: Array[String] = []
var gm: Node
var ds: Node

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func _finish_dialogue(target: String) -> String:
	var seen: Array[String] = []
	for step in 500:
		if not ds.visible:
			return "\n".join(seen)
		seen.append(ds._full_text)
		ds._finish_typing()
		if ds.choices_container.visible:
			var choices: Array = ds._get_available_choices(ds._current_dialogue[ds._current_index].get("choices", []))
			var selected: Dictionary = choices[0]
			for candidate in choices:
				if candidate.choice.get("next", "") == target:
					selected = candidate
					break
			ds._on_choice_pressed(selected.index)
		else:
			ds._advance()
		await process_frame
	_check(false, "Dialogue must terminate")
	return ""

func _check_chapter_routes() -> void:
	gm.current_chapter = 2
	gm.set_dialogue_flag("chapter_2_complete")
	_check(not gm.can_advance_chapter(), "New games cannot bypass unfinished route")
	var legacy: Dictionary = gm.get_save_data().duplicate(true)
	legacy.decisions.erase("branch_story_version")
	gm.load_save_data(legacy)
	_check(gm.can_advance_chapter(), "Unversioned old saves keep chapter access")
	gm.new_game()
	gm.current_chapter = 2
	gm.set_decision("chapter_1_route_chosen", "clinic")
	ds.start_dialogue(DialogueData.get_dialogue("ch2_branch_direction"))
	await _finish_dialogue("end")
	_check(gm.get_chapter_2_route() == "clinic", "Cancelled switch preserves route")
	gm.set_decision("chapter_2_route", "black_market")
	_check(gm.get_chapter_2_route() == "black_market" and gm.decisions.chapter_1_route_chosen == "clinic", "Switch preserves chapter one history")
	gm.set_dialogue_flag("auction_invitation_used")
	gm.set_decision("chapter_2_route", "clinic")
	_check(not gm.get_public_record_facts().is_empty(), "Switch keeps named access liability")
	ds.start_dialogue(DialogueData.get_dialogue("ch2_referral_priority"))
	await _finish_dialogue("end")
	_check(not gm.is_chapter_branch_complete(), "Cancelled handover does not complete route")
	gm.set_dialogue_flag("ch2_branch_complete")
	gm.set_decision("chapter_2_route", "black_market")
	_check(gm.get_chapter_2_route() == "clinic", "Committed route cannot switch")
	var saved: Dictionary = gm.get_save_data().duplicate(true)
	gm.new_game()
	gm.load_save_data(saved)
	_check(gm.is_chapter_branch_complete() and gm.get_chapter_2_route() == "clinic", "Save roundtrip preserves route commitment")

func _run() -> void:
	gm = root.get_node("GameManager")
	gm.new_game()
	gm.set_dialogue_flag("visited_abyss_bar")
	gm.collect_evidence("abyss_receipt")
	await root.get_node("SceneManager").change_scene("abyss_bar")
	ds = get_first_node_in_group("dialogue_system")
	await _check_chapter_routes()
	gm.new_game()
	gm.collect_evidence("abyss_receipt")
	var location := current_scene
	location._augmented_vision.set_process(false)
	ds = get_first_node_in_group("dialogue_system")
	var action: Dictionary
	for candidate in location._get_available_story_actions():
		if candidate.get("id", "") == "scan_ajie_receipt":
			action = candidate
	_check(not action.is_empty(), "Scan action is connected to the real location")
	gm.eagle_eye_energy = 19.0
	var before: Dictionary = gm.get_save_data().duplicate(true)
	location._run_story_action(action)
	_check(gm.get_save_data() == before and not ds.visible, "Insufficient energy changes no progress")
	gm.eagle_eye_energy = 20.0
	location._run_story_action(action)
	_check(gm.eagle_eye_energy == 0.0 and not gm.eagle_eye_active and ds.visible, "One-shot scan charges exactly 20 and returns to normal mode")
	await _finish_dialogue("end")
	_check(gm.get_dialogue_flag("eye_ajie_receipt_scanned") and not gm.get_dialogue_flag("ajie_statement_resolved"), "Cancel preserves scan but not an unchosen decision")
	var saved: Dictionary = gm.get_save_data().duplicate(true)
	gm.new_game()
	gm.load_save_data(saved)
	location._run_story_action(action)
	_check(ds.visible and gm.eagle_eye_energy == 0.0, "Saved scan can be reopened at zero energy after load")
	await _finish_dialogue("statement_coerced")
	var finished: Dictionary = gm.get_save_data().duplicate(true)
	location._run_story_action(action)
	_check(gm.get_save_data() == finished, "Resolved scan cannot apply a second choice")
	gm.eagle_eye_energy = 20.0
	gm.activate_eagle_eye()
	_check(gm.perform_eagle_eye_scan(20.0) and gm.eagle_eye_energy == 0.0 and not gm.eagle_eye_active, "An active scan exhausts energy correctly")
	gm.eagle_eye_energy = 100.0
	for invalid in [-1.0, 0.0, INF, NAN, 101.0]:
		_check(not gm.perform_eagle_eye_scan(invalid) and gm.eagle_eye_energy == 100.0, "Invalid scan cost cannot add or spend energy")
	gm.set_state(gm.GameState.DIALOGUE)
	_check(not gm.perform_eagle_eye_scan(20.0), "Double scan during dialogue is rejected")

	for sample in [
		["ch1_eye_ajie_statement", "statement_voluntary", "ajie_statement", "voluntary"],
		["ch1_eye_ajie_statement", "statement_coerced", "ajie_statement", "coerced"],
		["ch1_eye_ajie_statement", "statement_withheld", "ajie_statement", "withheld"],
		["ch2_eye_market_claim", "claim_bounded", "market_claim_resolution", "bounded"],
		["ch2_eye_market_claim", "claim_pledge", "market_claim_resolution", "pledge"],
		["ch2_eye_market_claim", "claim_refuse", "market_claim_resolution", "refuse"],
		["ch2_eye_unsent_backup", "backup_sealed", "backup_handling", "sealed"],
		["ch2_eye_unsent_backup", "backup_copied", "backup_handling", "copied"],
		["ch2_eye_unsent_backup", "backup_discarded", "backup_handling", "discarded"],
		["ch1_scan_grid", "grid_infrastructure", "grid_interpretation", "infrastructure"],
		["ch1_scan_grid", "grid_sabotage", "grid_interpretation", "sabotage"],
		["ch2_scan_warehouse_batch", "batch_patients", "warehouse_priority", "patients"],
		["ch2_scan_warehouse_batch", "batch_provenance", "warehouse_priority", "provenance"],
		["ch2_scan_withdrawal_queue", "archive_frozen", "archive_route", "frozen"],
		["ch2_scan_withdrawal_queue", "archive_observed", "archive_route", "observed"],
		["ch2_scan_dispatch_clock", "dispatch_sealed", "dispatch_record", "sealed"],
		["ch2_scan_dispatch_clock", "dispatch_redacted", "dispatch_record", "redacted"],
		["ch3_scan_recovery_route", "recovery_paper", "recovery_channel", "paper"],
		["ch3_scan_recovery_route", "recovery_direct", "recovery_channel", "direct"],
		["ch3_scan_memory_anchor", "anchor_shared", "continuity_record", "shared"],
		["ch3_scan_memory_anchor", "anchor_private", "continuity_record", "private"],
		["ch3_recovery_quiet", "quiet_stay", "recovery_company", "stay"],
		["ch3_recovery_quiet", "quiet_space", "recovery_company", "space"]
	]:
		gm.new_game()
		gm.collect_evidence("victim_list")
		gm.set_decision("memory_trade_method", "buy")
		ds.start_dialogue(DialogueData.get_dialogue(sample[0]))
		await _finish_dialogue(sample[1])
		_check(gm.decisions[sample[2]] == sample[3], "Branch records only the selected outcome: " + sample[1])
	gm.new_game()
	gm.set_decision("market_claim_resolution", "refuse")
	_check(not gm.meets_story_conditions({"requires_decisions": {"market_claim_resolution": "bounded"}}), "Refusing a contract cannot unlock independent care")
	for care in ["independent", "corporate"]:
		gm.set_decision("market_claim_resolution", "bounded")
		ds.start_dialogue(DialogueData.get_dialogue("ch3_grey_care_terms"))
		await _finish_dialogue("care_" + care)
		_check(gm.decisions.grey_care_terms == care and gm.decisions.final_resolution == "undecided", "Care terms do not automatically choose B")
		ds.start_dialogue(DialogueData.get_dialogue("ending_b_grey_deal"))
		var ending_text: String = await _finish_dialogue("end")
		_check(ending_text.contains("第三方接手") == (care == "independent"), "B renders only the chosen care outcome")
	for handling in ["sealed", "copied", "discarded"]:
		gm.new_game()
		gm.set_decision("backup_handling", handling)
		var outcome := "custody_clinic" if handling == "sealed" else ("custody_owner" if handling == "copied" else "custody_absent")
		ds.start_dialogue(DialogueData.get_dialogue("ch3_backup_permission"))
		await _finish_dialogue(outcome)
		_check(gm.decisions.backup_custody == outcome.trim_prefix("custody_"), "Backup permission respects earlier handling: " + handling)
		if handling == "copied":
			_check(gm.get_dialogue_flag("backup_copy_deleted") and not gm.get_public_record_facts().is_empty(), "Deleting a private copy retains the original liability")
	gm.new_game()
	gm.set_decision("ajie_statement", "coerced")
	gm.set_decision("market_claim_resolution", "pledge")
	gm.set_decision("backup_handling", "copied")
	gm.set_dialogue_flag("public_sources_verified")
	gm.review_public_record()
	var old_facts: Array = gm.decisions.public_record_facts.duplicate()
	gm.set_dialogue_flag("backup_copy_deleted")
	_check(old_facts != gm.get_public_record_facts(), "Later repair requires an updated public record")
	gm.set_dialogue_flag("ajie_statement_retracted")
	_check(gm.get_public_record_facts().size() == 3, "Repair never erases earlier coercion or leaks")
	gm.collect_evidence("commission_letter")
	location._open_evidence_board()
	await process_frame
	var board: Node = get_first_node_in_group("evidence_board")
	if board == null:
		board = location.get_node("EvidenceBoardLayer").get_child(0)
	var card: Control = board._cards["commission_letter"]
	card.position = Vector2(120, 90)
	gm.activate_eagle_eye()
	board._process(0.0)
	_check(card.tooltip_text.begins_with("鷹眼讀取："), "An already-open board updates when eagle eye activates")
	gm.deactivate_eagle_eye()
	board._process(0.0)
	_check(not card.tooltip_text.begins_with("鷹眼讀取：") and card.position == Vector2(120, 90), "Deactivation updates text without resetting dragged cards")
	board.close()
	await _check_map_scans()
	_write_inventory()
	root.get_node("AudioManager").stop_bgm(false)
	await create_timer(0.5).timeout
	print("EAGLE_EYE_BRANCHES_%s: checks=%d failures=%s" % ["PASS" if failures.is_empty() else "FAIL", checks, JSON.stringify(failures)])
	quit(0 if failures.is_empty() else 1)

func _check_map_scans() -> void:
	for sample in [[2, "civic_archive", "archive_frozen"], [3, "recovery_annex", "recovery_paper"]]:
		gm.new_game()
		gm.current_chapter = sample[0]
		gm.set_dialogue_flag("visited_" + sample[1])
		var loc_data: Dictionary = CaseData.get_chapter_data(sample[0]).locations[sample[1]]
		if sample[0] == 3:
			_check(not gm.meets_story_conditions(loc_data), "Recovery annex stays locked until rescue")
			gm.set_dialogue_flag("hao_ran_rescued")
		await root.get_node("SceneManager").change_scene(sample[1])
		var scene := current_scene
		scene._augmented_vision.set_process(false)
		ds = get_first_node_in_group("dialogue_system")
		_check(scene._base_background_texture != null and scene._scan_markers.size() == 1, "New map has real artwork and one scan marker")
		var marker: Button = scene._scan_markers[0]
		var action: Dictionary = marker.get_meta("action")
		scene._process(0.0)
		_check(not marker.visible, "Marker is hidden outside eagle eye")
		gm.eagle_eye_energy = 20.0
		gm.activate_eagle_eye()
		scene._process(0.0)
		_check(marker.visible, "Marker appears while scanning")
		marker.pressed.emit()
		scene._process(0.0)
		_check(ds.visible and not marker.visible and gm.eagle_eye_energy == 0.0 and gm.get_dialogue_flag(action.scan_flag), "Clicking marker spends exactly once and hides it during dialogue")
		await _finish_dialogue("end")
		var saved: Dictionary = gm.get_save_data().duplicate(true)
		gm.new_game()
		gm.load_save_data(saved)
		scene._run_story_action(action)
		_check(ds.visible and gm.eagle_eye_energy == 0.0, "Deferred map scan reopens free after save/load")
		await _finish_dialogue(sample[2])
		gm.eagle_eye_energy = 100.0
		gm.activate_eagle_eye()
		scene._process(0.0)
		_check(not marker.visible and action not in scene._get_available_story_actions(), "Resolved map marker and menu action both disappear")
		var journal_flags: Dictionary = gm.dialogue_flags.duplicate(true)
		scene._show_scan_journal()
		var journal: Node = scene.get_node_or_null("ScanJournal")
		_check(journal != null and not gm.eagle_eye_active and gm.eagle_eye_energy == 100.0, "Saved journal stops active scanning and never charges")
		_check(gm.dialogue_flags == journal_flags, "Reading saved observations cannot unlock new clues")
		var journal_text := ""
		for label in journal.find_children("*", "Label", true, false):
			journal_text += label.text
		_check(journal_text.contains(action.scan_summary), "Journal retains the completed scan's actual observation")
		journal.queue_free()
		await process_frame
		scene._show_story_actions()
		scene._show_story_actions()
		var menus := 0
		for child in scene.get_children():
			if str(child.name).begins_with("StoryActions"):
				menus += 1
		_check(menus == 1, "Repeated investigation input opens one menu")
		scene.get_node("StoryActions").queue_free()
		await process_frame
	gm.new_game()
	var challenge: Array = DialogueData.get_dialogue("ch3_xiao_record_challenge")
	var proof_choice: Dictionary = challenge[0].choices[1]
	_check(not gm.meets_story_conditions(proof_choice), "Local scan alone cannot invent the municipal receipt")
	gm.set_dialogue_flag("eye_withdrawal_scanned")
	_check(gm.meets_story_conditions(proof_choice), "Preserved receipt unlocks the documented question")
	ds.start_dialogue(challenge)
	await _finish_dialogue("challenge_admitted")
	_check(gm.decisions.xiao_accountability == "admitted", "Documented question records the admission")

func _write_inventory() -> void:
	var result := {"readings": [], "eye_only_metadata": [], "scan_actions": [], "narrative_effect_actions": [], "scene_hotspot_nodes": 0, "runtime_scan_markers": 0, "location_count": 0}
	var location_script = load("res://scripts/ui/location_base.gd")
	var all_evidence := EvidenceData.get_all_evidence()
	for id in all_evidence:
		var item: Dictionary = all_evidence[id]
		if item.has("eye_reading"):
			result.readings.append({"id": id, "name": item.name, "chapter": item.chapter, "text": item.eye_reading})
		if item.get("eagle_eye_only", false):
			result.eye_only_metadata.append(id)
	for chapter in [1, 2, 3]:
		var locations: Dictionary = CaseData.get_chapter_data(chapter).locations
		for id in locations:
			result.location_count += 1
			var scene_path: String = root.get_node("SceneManager").scene_paths[id]
			var packed: PackedScene = load(scene_path)
			var state := packed.get_state()
			for index in state.get_node_count():
				if state.get_node_type(index) == "Area2D":
					result.scene_hotspot_nodes += 1
			for action in locations[id].get("story_actions", []):
				if action.has("scan_position"):
					result.runtime_scan_markers += 1
				if location_script.EAGLE_EYE_ANOMALY_ACTIONS.has(action.id):
					result.narrative_effect_actions.append({"location": id, "name": locations[id].name, "title": action.title})
				if action.has("scan_cost"):
					result.scan_actions.append({"chapter": chapter, "location": id, "name": locations[id].name, "action": action})
	_check(result.scan_actions.size() == 12 and result.runtime_scan_markers == 12 and result.location_count == 22, "Twelve scans across twenty-two maps have real scene markers")
	_check(result.readings.size() == 29, "All chapters have evidence readings: 15 existing plus 14 added")
	var folder := "res://docs/verification/chapter_branches_2026_09_09"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var file := FileAccess.open(folder + "/inventory.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t"))
