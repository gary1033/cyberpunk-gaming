extends "res://tests/test_playthrough.gd"
## Real dialogue/menu/input regression checks. State injection is restricted to
## old-save and full-board fixtures; opening and hypothesis paths start new games.

var assertions := 0

func _initialize() -> void:
	if "--render-check" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		root.hide()
	call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
	assertions += 1
	return super._check(condition, message)

func _start_opening(choices: Array = []) -> void:
	gm.new_game()
	sm.change_scene("detective_office")
	await _settle()
	await _dialogue(choices)

func _run() -> void:
	if "--render-check" in OS.get_cmdline_user_args():
		await _render_boards()
		return
	gm = root.get_node("GameManager")
	sm = root.get_node("SceneManager")
	saves = root.get_node("SaveManager")
	var save_path: String = saves._get_save_path(TEST_SAVE_SLOT)
	test_save_existed = FileAccess.file_exists(save_path)
	if test_save_existed:
		test_save_bytes = FileAccess.get_file_as_bytes(save_path)
	Engine.time_scale = 20.0
	for tone in ["mei_ling_case_intro", "mei_ling_prove_case", "mei_ling_found_kai"]:
		for topic in ["mei_ling_abnormal", "mei_ling_workshop", "mei_ling_trust_test"]:
			await _start_opening([tone, topic, "mei_ling_accept"])
			var opening_text := "\n".join(last_dialogue_text)
			_check(opening_text.contains("我弟弟林浩然") and opening_text.contains("三天沒消息"), "Every opening tone establishes the missing person's identity and duration")
			_check(gm.has_evidence("commission_letter") and gm.has_evidence("work_id") and gm.has_evidence("abyss_receipt"), "All nine opening combinations hand over essential clues")
			_check(gm.get_dialogue_flag("accepted_case"), "Common handoff records acceptance")
	# Leaving the initial bar conversation remains a recoverable player choice.
	await _move("abyss_bar", ["end"])
	_check(not gm.has_evidence("stranger_photo"), "Looking around does not silently award a photo")
	await _move("detective_office")
	await _move("abyss_bar")
	await _action("ch1_ajie_followup", [], ["stranger_photo"])
	var before: Dictionary = gm.get_save_data()
	await _action("ch1_ajie_followup")
	_check(before.merged({"dialogue_history": []}, true) == gm.get_save_data().merged({"dialogue_history": []}, true), "Revisiting the witness grants neither extra evidence nor affinity")
	await _move("abyss_bar_backroom")
	await _action("ch1_abyss_backroom_investigation", [], ["masked_client_receipt"])
	await _check_legacy_recovery()
	await _check_branch_endings()
	await _check_snake_negotiation()
	await _check_hypotheses()
	await _check_board()
	_restore_test_save()
	root.get_node("AudioManager").stop_bgm(false)
	Engine.time_scale = 1.0
	await create_timer(0.5).timeout
	print("INVESTIGATION_FLOW_%s: assertions=%d; opening/revisit/branches/hypotheses/legacy/board input" % ["FAIL" if failed else "PASS", assertions])
	quit(1 if failed else 0)

func _check_legacy_recovery() -> void:
	gm.new_game()
	gm.collect_evidence("commission_letter")
	gm.collect_evidence("work_id")
	gm.set_dialogue_flag("visited_detective_office")
	gm.set_dialogue_flag("visited_abyss_bar")
	gm.set_decision("ajie_statement", "coerced")
	gm.set_dialogue_flag("ajie_statement_resolved")
	var legacy: Dictionary = gm.get_save_data()
	legacy.decisions.erase("ajie_hypothesis")
	legacy.decisions.erase("ajie_hypothesis_status")
	gm.load_save_data(legacy)
	sm.change_scene("detective_office")
	await _settle()
	await _action("ch1_case_materials_review", [], ["abyss_receipt"])
	var before: Dictionary = gm.get_save_data()
	await _action("ch1_case_materials_review")
	_check(before.merged({"dialogue_history": []}, true) == gm.get_save_data().merged({"dialogue_history": []}, true), "Old-save handoff recovery is idempotent")
	await _move("abyss_bar")
	await _action("ch1_ajie_followup", [], ["stranger_photo"])
	_check(gm.decisions.ajie_statement == "coerced" and not gm.get_public_record_facts().is_empty(), "Revisit preserves historical coercion")
	saves.save_game(TEST_SAVE_SLOT)
	gm.new_game()
	_check(saves.load_game(TEST_SAVE_SLOT), "Recovered clues survive a real file save/load")
	_check(gm.has_evidence("abyss_receipt") and gm.has_evidence("stranger_photo"), "Old-save clue repair survives loading")
	gm.set_dialogue_flag("case_resolved")
	var completed: Dictionary = gm.get_save_data()
	gm.load_save_data(completed)
	_check(gm.get_dialogue_flag("case_resolved"), "New investigation never revokes a completed save")

func _check_branch_endings() -> void:
	for sample in [
		["ch1_abyss_bar_enter", ["ajie_ask", "ajie_receipt"], "每天來這裡的人太多了", "stranger_photo"],
		["ch1_snake_encounter", ["snake_info", "snake_deal", "snake_deal_accept"], "那真可惜", ""],
		["ch1_snake_data_chip_choice", ["snake_trade_accept"], "這次我就不替你安排了", ""],
		["ch1_original_backup_album", ["backup_reassure"], "愧疚會讓人漏看細節", "original_backup_hint"]
	]:
		gm.new_game()
		gm.collect_evidence("abyss_receipt")
		gm.collect_evidence("data_chip")
		get_first_node_in_group("dialogue_system").start_dialogue(DialogueDataScript.get_dialogue(sample[0]))
		await _dialogue(sample[1])
		_check(not "\n".join(last_dialogue_text).contains(sample[2]), "Unselected response is absent: " + sample[0])
		if sample[3] != "":
			_check(gm.has_evidence(sample[3]), "Branch keeps its common evidence handoff")
		if sample[0] == "ch1_snake_data_chip_choice":
			_check(not gm.get_dialogue_flag("clinic_route_opened"), "Accepted trade does not apply rejected branch effect")

func _check_snake_negotiation() -> void:
	# Reach the chip through the actual map and workshop introduction.
	for introduction in ["snake_deal_accept", "snake_deal_reject", "none"]:
		for outcome in ["snake_trade_accept", "snake_trade_reject"]:
			await _start_opening(["mei_ling_workshop"])
			await _move("abyss_bar", ["end"])
			if introduction != "none":
				await _action("ch1_snake_encounter", ["snake_info", "snake_deal", introduction])
			await _move("east_district_street")
			await _move("hao_ran_workshop")
			_check(gm.has_evidence("data_chip"), "Workshop hands over the actual trade chip")
			await _move("east_district_street")
			await _move("abyss_bar")
			var before: Dictionary = gm.get_save_data().duplicate(true)
			await _action("ch1_snake_data_chip_choice", ["end"])
			_check(before.merged({"dialogue_history": []}, true) == gm.get_save_data().merged({"dialogue_history": []}, true), "Postponing changes no clues, affinity, route, or trade history")
			var spoken := "\n".join(last_dialogue_text)
			_check(spoken.contains("你上次說找到再談") == (introduction == "snake_deal_accept"), "Snake remembers the tentative agreement only when made")
			_check(spoken.contains("不是說不替我跑腿") == (introduction == "snake_deal_reject"), "Snake remembers the refusal without inventing it for first-time visitors")
			_check(current_scene._get_available_story_actions().any(func(action: Dictionary) -> bool: return action.get("dialogue", "") == "ch1_snake_data_chip_choice"), "Postponed trade remains available")
			saves.save_game(TEST_SAVE_SLOT)
			gm.new_game()
			_check(saves.load_game(TEST_SAVE_SLOT), "Postponed trade survives a real file save/load")
			await _settle()
			await _dialogue()
			await _move("detective_office")
			await _move("abyss_bar")
			before = gm.get_save_data().duplicate(true)
			await _action("ch1_snake_data_chip_choice", ["end"])
			_check(before.merged({"dialogue_history": []}, true) == gm.get_save_data().merged({"dialogue_history": []}, true), "Repeated postponement after a revisit remains free")
			await _action("ch1_snake_data_chip_choice", [outcome])
			var accepted: bool = outcome == "snake_trade_accept"
			_check(gm.get_dialogue_flag("accepted_snake_deal") == accepted and gm.get_dialogue_flag("rejected_snake_deal") != accepted, "Only the chosen trade route resolves after postponement")
			_check(gm.get_dialogue_flag("black_market_route_opened") == accepted and gm.get_dialogue_flag("clinic_route_opened") != accepted, "Trade opens only its selected route")
			_check(gm.decisions.black_market_compromise_count == (1 if accepted else 0), "Postponement adds no hidden trade count")
			_check(gm.character_affinity.get("snake", 0) == before.character_affinity.get("snake", 0) + (2 if accepted else -1), "Only the final choice changes affinity")
			_check(gm.has_evidence("data_chip") and _locked_action("ch1_snake_data_chip_choice"), "The original chip remains and completed trade cannot repeat")

func _check_hypotheses() -> void:
	for topic in ["terminal", "witness", "monitor", "none"]:
		await _start_opening(["mei_ling_workshop"])
		await _move("abyss_bar", ["end"])
		await _action("ch1_eye_ajie_statement", ["end" if topic == "none" else "hypothesis_" + topic])
		_check(gm.decisions.ajie_hypothesis == topic and gm.decisions.ajie_hypothesis_status == "pending", "Selected hypothesis stays pending before verification")
		_check(gm.decisions.ajie_statement == "none", "Private speculation never becomes witness testimony")
		var affinity: Dictionary = gm.character_affinity.duplicate()
		await _action("ch1_ajie_terminal_check", ["end"])
		_check(not gm.get_dialogue_flag("ajie_terminal_verified"), "Verification can be postponed")
		await _action("ch1_ajie_terminal_check", ["terminal_overreach"])
		_check(not gm.get_dialogue_flag("ajie_terminal_verified") and gm.character_affinity == affinity and gm.decisions.ajie_statement == "none", "Unsupported private inference is revisable, never a coerced statement")
		saves.save_game(TEST_SAVE_SLOT)
		gm.new_game()
		_check(saves.load_game(TEST_SAVE_SLOT), "Pending hypothesis is saved")
		_check(gm.decisions.ajie_hypothesis == topic, "Loading preserves chosen question")
		await _move("detective_office")
		await _move("abyss_bar")
		await _action("ch1_ajie_terminal_check", ["terminal_confirm"])
		_check(gm.decisions.ajie_hypothesis_status == ("supported" if topic in ["terminal", "none"] else "revised"), "Verification supports or narrows the original hypothesis")
		_check(gm.character_affinity == affinity, "Revising a private guess carries no affinity penalty")
		current_scene._open_evidence_board()
		await process_frame
		var summary_board: Control = current_scene.get_node("EvidenceBoardLayer").get_child(0)
		_check(summary_board.feedback_label.text.contains("已支持" if topic in ["terminal", "none"] else "已修正"), "Evidence board displays the saved conclusion")
		summary_board.close()
		await process_frame
		var outcome := "statement_coerced" if topic == "monitor" else "statement_voluntary"
		await _action("ch1_ajie_statement_check", [outcome])
		_check(_locked_action("ch1_ajie_statement_check"), "Resolved testimony cannot be farmed")
		await _action("ch1_ajie_followup", [], ["stranger_photo"])
		_check("\n".join(last_dialogue_text).contains("名字是你逼我說的") == (topic == "monitor"), "The next witness interaction reflects coercion")
		if topic == "monitor":
			await _action("ch1_ajie_retraction", ["statement_retracted"])
			_check(gm.decisions.ajie_statement == "coerced" and not gm.get_public_record_facts().is_empty(), "Correction never erases coercion")

func _mouse(position: Vector2, button: int, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = button
	event.pressed = pressed
	root.push_input(event, true)
	await process_frame

func _click(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	await _mouse(point, MOUSE_BUTTON_LEFT, true)
	await _mouse(point, MOUSE_BUTTON_LEFT, false)

func _touch(point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame
	await process_frame

func _check_board() -> void:
	# Isolated UI fixture deliberately includes every defined card, not a claim
	# that all definitions are obtainable in a normal route.
	for viewport_size in [Vector2i(1280, 720), Vector2i(854, 480), Vector2i(390, 844)]:
		root.size = viewport_size
		root.content_scale_size = viewport_size
		gm.new_game()
		for evidence_id in load("res://scripts/data/evidence_data.gd").get_all_evidence():
			gm.collect_evidence(evidence_id)
		current_scene._open_evidence_board()
		await process_frame
		await process_frame
		var board: Control = current_scene.get_node("EvidenceBoardLayer").get_child(0)
		_check(board._get_evidence_display_name("ghost_identity_trace") == "身份轉用核對紀錄", "New evidence shows its player-facing name")
		for evidence_id in board._cards:
			var card: Control = board._cards[evidence_id]
			var select: Button = card.find_child("SelectEvidence", true, false)
			_check(card.get_global_rect().encloses(select.get_global_rect()), "Selection button fits card: " + evidence_id)
		var first: Button = board._cards["commission_letter"].find_child("SelectEvidence", true, false)
		var second: Button = board._cards["work_id"].find_child("SelectEvidence", true, false)
		board.scroll_container.ensure_control_visible(first)
		await process_frame
		await _click(first)
		_check(board._connecting_from == "commission_letter", "Pointer actually selects the card at " + str(viewport_size))
		board.scroll_container.ensure_control_visible(second)
		await process_frame
		await _click(second)
		_check(gm.decisions.correct_deductions == 1, "Pointer pair records exactly one deduction")
		await _click(second)
		board.scroll_container.ensure_control_visible(first)
		await process_frame
		await _click(first)
		_check(gm.decisions.correct_deductions == 1 and board.feedback_label.text.contains("不重複"), "Reversed pair reports duplicate without another score")
		var last_id: String = gm.collected_evidence.back()
		var last: Button = board._cards[last_id].find_child("SelectEvidence", true, false)
		var wheel_point: Vector2 = board.scroll_container.get_global_rect().get_center()
		for step in 200:
			if board.scroll_container.get_global_rect().encloses(last.get_global_rect()):
				break
			await _mouse(wheel_point, MOUSE_BUTTON_WHEEL_DOWN, true)
			await _mouse(wheel_point, MOUSE_BUTTON_WHEEL_DOWN, false)
		_check(board.scroll_container.get_global_rect().encloses(last.get_global_rect()), "Mouse wheel reaches last card at " + str(viewport_size))
		await _click(last)
		_check(board._connecting_from == last_id, "Last card pointer selection: selected=%s expected=%s rect=%s scroll=%s" % [board._connecting_from, last_id, last.get_global_rect(), board.scroll_container.scroll_vertical])
		await _click(last)
		_check(board._connecting_from == "", "Selected card can be cancelled")
		Input.emulate_mouse_from_touch = true
		Input.emulate_touch_from_mouse = true
		var touch_point := last.get_global_rect().get_center()
		await _touch(touch_point, true)
		await _touch(touch_point, false)
		_check(board._connecting_from == last_id, "Native touch selects the last card exactly once")
		await _touch(touch_point, true)
		await _touch(touch_point, false)
		_check(board._connecting_from == "", "Native touch cancels selection without a duplicate click")
		var scroll_before: int = board.scroll_container.scroll_vertical
		var swipe_point: Vector2 = board.scroll_container.get_global_rect().get_center()
		await _touch(swipe_point, true)
		var drag := InputEventScreenDrag.new()
		drag.position = swipe_point + Vector2(0, 120)
		drag.relative = Vector2(0, 120)
		Input.parse_input_event(drag)
		await process_frame
		await _touch(drag.position, false)
		_check(board.scroll_container.scroll_vertical < scroll_before, "Native touch drag scrolls the evidence list")
		_check(board._connecting_from == "", "Scrolling does not select an evidence card")
		Input.emulate_touch_from_mouse = false
		board.close()
		await process_frame
	# Legacy duplicate fixture and actual disk roundtrip both share the pair guard.
	var saved: Dictionary = gm.get_save_data()
	saved.evidence_connections.append({"from": "work_id", "to": "commission_letter", "correct": true})
	saved.decisions.correct_deductions = 99
	gm.load_save_data(saved)
	_check(gm.decisions.correct_deductions == 1 and gm.evidence_connections.size() == 1, "Legacy reversed duplicate and inflated counter are normalized")
	saves.save_game(TEST_SAVE_SLOT)
	gm.new_game()
	_check(saves.load_game(TEST_SAVE_SLOT), "Board state loads from disk")
	_check(not gm.add_evidence_connection("work_id", "commission_letter", true) and gm.decisions.correct_deductions == 1, "Pair remains unique after disk load")
	_check(not gm.add_evidence_connection("work_id", "work_id", true) and not gm.add_evidence_connection("unknown", "work_id", true), "Self and absent-evidence connections are rejected")

func _render_boards() -> void:
	gm = root.get_node("GameManager")
	var folder := "res://docs/verification/V0.3/board"
	DirAccess.make_dir_recursive_absolute(folder)
	var geometry: Array = []
	for dimensions in [Vector2i(1280, 720), Vector2i(854, 480), Vector2i(390, 844)]:
		gm.new_game()
		gm.current_chapter = 2
		gm.set_dialogue_flag("visited_bitstorm_cafe")
		for id in load("res://scripts/data/evidence_data.gd").get_all_evidence(): gm.collect_evidence(id)
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var location = load("res://scenes/locations/chapter2/bitstorm_cafe.tscn").instantiate()
		view.add_child(location)
		await process_frame
		location._open_evidence_board()
		await process_frame
		await process_frame
		var board = location.get_node("EvidenceBoardLayer").get_child(0)
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png(folder+"/"+str(dimensions.x)+"x"+str(dimensions.y)+"_top.png")
		var last: Control = board._cards[gm.collected_evidence.back()]
		board.scroll_container.ensure_control_visible(last)
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png(folder+"/"+str(dimensions.x)+"x"+str(dimensions.y)+"_bottom.png")
		geometry.append({"viewport":str(dimensions), "scroll":str(board.scroll_container.get_global_rect()),"last_card":str(last.get_global_rect()),"progress":str(board.progress_label.get_global_rect()),"close":str(board.close_button.get_global_rect())})
		board.close()
		view.queue_free()
		await process_frame
	var file := FileAccess.open(folder+"/geometry.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(geometry,"  "))
	file.close()
	root.get_node("AudioManager").stop_bgm(false)
	await create_timer(0.5).timeout
	print("BOARD_RENDER_DONE")
	quit()
