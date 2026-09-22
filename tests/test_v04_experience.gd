extends "res://tests/test_playthrough.gd"
## Optional memory inquiries, read-only notebook, preferences and sound/pacing.

func _run() -> void:
	gm = root.get_node("GameManager")
	sm = root.get_node("SceneManager")
	saves = root.get_node("SaveManager")
	Engine.time_scale = 20.0
	var settings_before: Dictionary = saves.reading_settings.duplicate()
	var settings_path: String = saves.READING_SETTINGS_PATH
	var settings_existed := FileAccess.file_exists(settings_path)
	var settings_bytes := FileAccess.get_file_as_bytes(settings_path) if settings_existed else PackedByteArray()
	gm.new_game()
	sm.change_scene("detective_office")
	await _settle()
	await _dialogue()
	var ds = get_first_node_in_group("dialogue_system")
	# Explicit isolated chapter-three fixture; complete new-game paths run separately.
	gm.current_chapter = 3
	gm.set_dialogue_flag("kai_memory_2_seen")
	gm.set_dialogue_flag("trusted_zhao_ming")
	gm.set_dialogue_flag("xiao_confronted")
	gm.collect_evidence("authorization_order")
	for inquiry in [["ch3_kai_zhao_followup", "zhao_signature", "kai_zhao_account_checked"], ["ch3_kai_xiao_followup", "kai_scope", "kai_xiao_account_checked"]]:
		ds.start_dialogue(DialogueDataScript.get_dialogue(inquiry[0]))
		await _dialogue(["end"])
		_check(not gm.get_dialogue_flag(inquiry[2]), "Leaving inquiry records no answer")
		var snapshot: Dictionary = gm.get_save_data()
		gm.load_save_data(snapshot)
		ds.start_dialogue(DialogueDataScript.get_dialogue(inquiry[0]))
		await _dialogue([inquiry[1]])
		_check(gm.get_dialogue_flag(inquiry[2]), "Actual answer records inquiry")
	_check(not gm.get_dialogue_flag("hao_ran_rescued") and not gm.get_dialogue_flag("kai_memory_truth_reviewed"), "Optional inquiries grant neither rescue nor memory completion")
	var account_state: Dictionary = gm.get_save_data()
	for answer in ["signed", "pending"]:
		gm.load_save_data(account_state)
		ds.start_dialogue(DialogueDataScript.get_dialogue("ch3_kai_account_response"))
		await _dialogue(["kai_account_" + answer])
		_check(gm.decisions.kai_account_response == answer, "Responsibility choices remain distinct")
		_check(not gm.can_reach_ending("ending_b_grey_deal"), "Inquiry does not bypass ending requirements")
	for scene_id in ["echo_network_hq", "secret_lab", "memory_space"]:
		var location: Dictionary = CaseDataScript.get_chapter_data(3).locations[scene_id]
		for action in location.story_actions:
			if action.dialogue in ["ch3_kai_zhao_followup", "ch3_kai_xiao_followup", "ch3_kai_account_response"]:
				gm.set_dialogue_flag("kai_memory_2_seen", false)
				if action.dialogue != "ch3_kai_account_response":
					_check(not gm.meets_story_conditions(action), "Inquiry hidden before memory source")
				gm.set_dialogue_flag("kai_memory_2_seen")
	gm.new_game()
	_check(not gm.get_case_summary().contains("回寫權限"), "Summary does not leak future investigation")
	gm.dialogue_history.clear()
	ds.start_dialogue([{"speaker": "kai", "text": "已讀句子。"}, {"speaker": "kai", "text": "未讀秘密。", "set_flag": "unread_effect"}])
	ds._finish_typing()
	ds._finish_typing()
	_check(gm.dialogue_history.size() == 1, "Same page is recorded once")
	var story_before: Dictionary = gm.get_save_data()
	ds._open_notebook()
	await process_frame
	var notebook = get_first_node_in_group("reading_panel")
	_check(notebook != null and gm.current_state == gm.GameState.PAUSED, "Notebook pauses dialogue")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(600, 350)
	ds._input(click)
	_check(ds._current_index == 0 and not gm.get_dialogue_flag("unread_effect"), "Notebook click does not advance underlying dialogue")
	_check(not str(gm.dialogue_history).contains("未讀秘密"), "Unread entry is absent from history")
	gm.eagle_eye_active = true
	gm.eagle_eye_energy = 60.0
	gm.consume_eagle_eye_energy(1.0)
	_check(gm.eagle_eye_energy == 60.0, "Reading does not drain eagle eye")
	gm.eagle_eye_active = false
	gm.eagle_eye_energy = story_before.eagle_eye_energy
	_check(gm.get_save_data() == story_before, "Notebook causes no saved story effects")
	if "--render-check" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/verification/V0.4/notebook.png")
	notebook.queue_free()
	await process_frame
	_check(gm.current_state == gm.GameState.DIALOGUE, "Closing returns to same dialogue")
	ds.end_dialogue()
	# A real on-disk save uses a dedicated slot and preserves pre-existing test data.
	var save_path: String = saves._get_save_path(TEST_SAVE_SLOT)
	test_save_existed = FileAccess.file_exists(save_path)
	if test_save_existed:
		test_save_bytes = FileAccess.get_file_as_bytes(save_path)
	saves.save_game(TEST_SAVE_SLOT)
	gm.new_game()
	_check(saves.load_game(TEST_SAVE_SLOT) and gm.dialogue_history.size() == 1, "Read history survives disk save/load")
	_restore_test_save()
	var legacy: Dictionary = gm.get_save_data()
	legacy.erase("dialogue_history")
	gm.load_save_data(legacy)
	_check(gm.dialogue_history.is_empty(), "Old saves do not invent past conversations")
	for i in 305:
		gm.record_dialogue("凱", str(i))
	_check(gm.dialogue_history.size() == 300 and gm.dialogue_history[0].text == "5", "History bound discards only oldest pages")
	for size_step in 3:
		saves.set_reading_setting("font_step", size_step)
		for speed in 4:
			saves.set_reading_setting("speed", speed)
			ds.start_dialogue([{"speaker": "kai", "text": "這段文字用來核對閱讀設定。"}])
			_check(ds.dialogue_text.get_theme_font_size("normal_font_size") == 24 + size_step * 2, "Font preference applied at entry start")
			if speed == 3:
				ds._process(0.016)
				_check(not ds._is_typing, "Instant text mode completes immediately")
			ds.end_dialogue()
	var config := ConfigFile.new()
	_check(config.load(settings_path) == OK and config.get_value("reading", "font_step") == 2, "Reading preferences persist")
	saves.reading_settings = settings_before
	if settings_existed:
		var restore := FileAccess.open(settings_path, FileAccess.WRITE)
		restore.store_buffer(settings_bytes)
		restore.close()
	else:
		DirAccess.remove_absolute(settings_path)
	gm.action_points = gm.max_action_points
	gm.eagle_eye_energy = 0.0
	var chapter_before: int = gm.current_chapter
	_check(gm.rest() and gm.eagle_eye_energy == gm.eagle_eye_max_energy and gm.current_chapter == chapter_before, "Rest refills energy without advancing story")
	var audio_manager = root.get_node("AudioManager")
	for filename in ["evidence_collect", "scan_confirm", "handover_confirm", "family_memory_fragment", "broken_player_scan", "eagle_eye_glitch_sting", "memory_signature_reveal"]:
		var sound = load("res://assets/audio/sfx/" + filename + ".ogg") as AudioStream
		_check(sound != null and sound.get_length() > 0.0, "SFX decodes: " + filename)
	_check(AudioServer.get_bus_send(AudioServer.get_bus_index("Music")) == "MusicContext" and AudioServer.get_bus_index("MusicContext") < AudioServer.get_bus_index("Music"), "Music routes through an earlier mix bus")
	gm.set_state(gm.GameState.DIALOGUE)
	_check(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MusicContext")) == -5.0, "Dialogue lowers music mix")
	gm.set_state(gm.GameState.PLAYING)
	_check(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MusicContext")) == 0.0, "Music mix restores")
	for ending in ["ending_b_grey_deal", "ending_c_memory_rebirth"]:
		ds.start_dialogue(DialogueDataScript.get_dialogue(ending))
		await _dialogue()
	_check(audio_manager != null, "Audio manager remains available")
	if "--render-check" in OS.get_cmdline_user_args():
		await _render_views()
	root.get_node("AudioManager").stop_bgm(false)
	Engine.time_scale = 1.0
	await create_timer(0.5).timeout
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("V04_EXPERIENCE_" + ("FAIL" if failed else "PASS"))
	call_deferred("quit", 1 if failed else 0)

func _render_views() -> void:
	var input_manager = root.get_node("InputManager")
	var saved_settings: Dictionary = saves.reading_settings.duplicate()
	for config in [[false, Vector2i(1280, 720), "desktop"], [true, Vector2i(854, 480), "small_mobile"]]:
		gm.new_game()
		gm.set_dialogue_flag("visited_detective_office")
		gm.collect_evidence("commission_letter")
		gm.collect_evidence("abyss_receipt")
		input_manager.is_mobile = config[0]
		var viewport := SubViewport.new()
		viewport.size = config[1]
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/locations/chapter1/detective_office.tscn").instantiate()
		viewport.add_child(scene)
		await process_frame
		await process_frame
		var dialogue = scene.find_child("DialogueSystem", true, false)
		saves.reading_settings.font_step = 2
		dialogue.start_dialogue([{"speaker": "kai", "text": "時間不等於身份。我要拿收據回去核對終端，再決定問什麼。"}])
		dialogue._finish_typing()
		dialogue._open_notebook()
		await process_frame
		var notebook = dialogue.get_child(dialogue.get_child_count() - 1)
		var tabs := notebook.find_child("NotebookTabs", true, false) as TabContainer
		for index in 3:
			tabs.current_tab = index
			await process_frame
			await process_frame
			_check(tabs.get_global_rect().end.y <= config[1].y, "Notebook tabs stay in viewport")
			RenderingServer.force_draw(false)
			viewport.get_texture().get_image().save_png("res://docs/verification/V0.4/%s_notebook_%d.png" % [config[2], index])
		notebook.queue_free()
		await process_frame
		dialogue.end_dialogue()
		for cg in ["cg_ending_b_care", "cg_ending_c_awakening"]:
			dialogue.start_dialogue([{"speaker": "narrator", "show_cg": cg, "text": "雨聲停了一會兒。她把水放在你伸手能碰到的地方，等你自己拿起來。"}])
			dialogue._finish_typing()
			await process_frame
			await process_frame
			_check(dialogue._story_cg_overlay.visible and dialogue._story_cg_overlay.texture != null, "Ending CG rendered")
			_check(dialogue._dialogue_text_fits(dialogue._full_text, false), "Large font fits measured page")
			RenderingServer.force_draw(false)
			viewport.get_texture().get_image().save_png("res://docs/verification/V0.4/%s_%s.png" % [config[2], cg])
			dialogue.end_dialogue()
		viewport.queue_free()
		await process_frame
		await process_frame
	saves.reading_settings = saved_settings
	input_manager.is_mobile = false
