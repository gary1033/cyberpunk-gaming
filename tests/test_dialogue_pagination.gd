extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	if DisplayServer.get_name() != "headless":
		root.hide()
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var gm = root.get_node("GameManager")
	var all_data := DialogueData._get_all_dialogues()
	gm.new_game()
	var values := {"ajie_statement": "coerced", "market_claim_resolution": "pledge", "backup_handling": "copied", "accepted_snake_deal": true, "memory_trade_method": "intrude", "ghost_identity_choice": "expose", "echo_fate": "release", "hq_entry_route": "corporate", "black_market_compromise_count": 9}
	for key in values:
		gm.set_decision(key, values[key])
	for flag in ["auction_invitation_used", "ajie_statement_retracted", "backup_copy_deleted", "hq_named_lookup_used"]:
		gm.set_dialogue_flag(flag)
	all_data["dynamic_public_record"] = [{"speaker": "narrator", "text": "目前需要列入的行動紀錄：\n" + "\n".join(gm.get_public_record_facts())}]
	var entries := 0
	var choice_count := 0
	var page_count := 0
	var forced: Array = []
	for config in [[false, Vector2i(1280, 720), "desktop"], [true, Vector2i(1280, 720), "mobile"], [true, Vector2i(854, 480), "small_mobile"]]:
		gm.new_game()
		gm.current_chapter = 2
		gm.set_dialogue_flag("visited_bitstorm_cafe")
		root.get_node("InputManager").is_mobile = config[0]
		var view := SubViewport.new()
		view.size = config[1]
		root.add_child(view)
		var scene = load("res://scenes/locations/chapter2/bitstorm_cafe.tscn").instantiate()
		view.add_child(scene)
		await process_frame
		await process_frame
		var ds = get_first_node_in_group("dialogue_system")
		for id in all_data:
			for index in all_data[id].size():
				var source: Dictionary = all_data[id][index]
				var text: String = source.get("text", "")
				var context := "%s/%s/%d" % [config[2], id, index]
				var choices: Array = []
				for choice in source.get("choices", []):
					choices.append({"text": choice.text, "next": "end"})
				var entry := {"speaker": source.get("speaker", "kai"), "text": text}
				if not choices.is_empty():
					entry.choices = choices
				# Audit every text regardless of story flags; no story effects are applied.
				ds.start_dialogue([entry])
				_check("".join(ds._current_entry_pages) == text, "Lossless pages: " + context)
				for page in ds._current_entry_pages.size():
					ds._finish_typing()
					await process_frame
					await process_frame
					_check(ds.dialogue_text.get_content_height() <= ds.dialogue_text.size.y + 1, "Text fits: " + context)
					if page > 0 and not ds._full_text.is_empty():
						_check(not ds.DIALOGUE_CLOSING_MARKS.contains(ds._full_text[0]), "No punctuation orphan: " + context)
					if page + 1 < ds._current_entry_pages.size():
						var tail: String = str(ds._current_entry_pages[page]).strip_edges().rstrip("」』）)]】〉》")
						if not ds._full_text.ends_with("\n") and not tail.is_empty() and not ds.DIALOGUE_SENTENCE_ENDS.contains(tail[-1]):
							forced.append({"context": context, "page": ds._full_text, "text": text, "has_choices": not choices.is_empty(), "fits_normal": ds._dialogue_text_fits(text, false)})
						_check(ds.continue_indicator.text.begins_with("續讀"), "Continuation label: " + context)
					if page + 1 == ds._current_entry_pages.size():
						for button in ds.choices_container.get_children():
							_check(button.size.x <= ds.dialogue_panel.size.x + 1, "Choice width: " + context)
					var full_height: int = ds.dialogue_text.get_content_height()
					ds.dialogue_text.visible_characters = 1
					_check(ds.dialogue_text.get_content_height() == full_height, "Typing preserves wrapping: " + context)
					ds.dialogue_text.visible_characters = -1
					page_count += 1
					if page + 1 < ds._current_entry_pages.size():
						ds._advance()
				entries += 1
				choice_count += choices.size()
				ds.end_dialogue()
		# One touch plus its emulated mouse must only finish typing, not skip a page.
		ds.start_dialogue([{"speaker": "kai", "text": "這是一句完整的對話，請讀完以後再往下看。"}, {"speaker": "kai", "text": "下一段。"}])
		var touch := InputEventScreenTouch.new()
		touch.pressed = true
		ds._input(touch)
		var mouse := InputEventMouseButton.new()
		mouse.device = InputEvent.DEVICE_ID_EMULATION
		mouse.pressed = true
		mouse.button_index = MOUSE_BUTTON_LEFT
		ds._input(mouse)
		_check(ds._current_index == 0 and not ds._is_typing, "Touch is not counted twice")
		ds.end_dialogue()
		view.queue_free()
		await process_frame
	_check(forced.is_empty(), "All shipped dialogue pages end at sentence or paragraph boundaries")
	var folder := "res://docs/verification/V0.3/layout"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var file := FileAccess.open(folder + "/audit.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"dialogues": all_data.size(), "entry_checks": entries, "choice_checks": choice_count, "pages": page_count, "forced_splits": forced, "failures": failures}, "  "))
	root.get_node("AudioManager").stop_bgm(false)
	await create_timer(0.5).timeout
	print("DIALOGUE_PAGINATION_%s: checks=%d entries=%d choices=%d forced=%d" % ["PASS" if failures.is_empty() else "FAIL", checks, entries, choice_count, forced.size()])
	quit(0 if failures.is_empty() else 1)
