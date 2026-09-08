extends SceneTree
## Add --rendering-method gl_compatibility --audio-driver Dummy and -- --render-check for screenshots.

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
	var data = load("res://scripts/data/dialogue_data.gd")
	for config in [[false, Vector2i(1280, 720), "desktop"], [true, Vector2i(1280, 720), "mobile"], [true, Vector2i(854, 480), "small_mobile"]]:
		gm.new_game()
		gm.current_chapter = 2
		gm.set_dialogue_flag("visited_bitstorm_cafe")
		gm.set_dialogue_flag("warehouse_investigated")
		gm.collect_evidence("victim_list")
		root.get_node("InputManager").is_mobile = config[0]
		var view := SubViewport.new()
		view.size = config[1]
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var scene = load("res://scenes/locations/chapter2/bitstorm_cafe.tscn").instantiate()
		view.add_child(scene)
		await process_frame
		var ds = get_first_node_in_group("dialogue_system")
		_check(scene._background_texture_rect.size.is_equal_approx(Vector2(config[1])), "Location background fits viewport")
		_check(ds.dialogue_panel.scale == Vector2.ONE, "Text must not shrink with the decorative frame")
		_check(ds.dialogue_text.get_theme_font_size("normal_font_size") >= 20, "Dialogue remains readable on small screens")
		for character_id in CharacterData.get_all_characters():
			ds.start_dialogue([{"speaker": character_id, "text": "肖像與姓名檢查。"}])
			_check(not scene._ap_status_bar.is_visible_in_tree(), "AP HUD does not cover dialogue props")
			_check(not scene._augmented_vision.energy_bar.visible, "Energy HUD does not cover dialogue props")
			_check(not scene._augmented_vision.toggle_button.visible, "Mobile eagle eye button does not cover dialogue CG")
			_check(not ds.character_name_label.text.is_empty(), "Character name fallback: " + character_id)
			_check(ds.portrait_left.texture is AtlasTexture, "Character uses a headshot: " + character_id)
			ds.end_dialogue()
		for dialogue_id in ["ch2_branch_direction", "ch2_referral_number", "ch2_referral_reassigned", "ch2_referral_priority", "ch2_auction_batch", "ch2_auction_access", "ch2_auction_priority", "ch2_family_update", "ch2_memory_trade_choice", "ch2_ghost_trace", "ch2_ghost_followup", "ch3_hq_entry", "ch3_verify_public_sources", "ch3_review_public_record", "ch1_eye_ajie_statement", "ch1_ajie_retraction", "ch2_eye_market_claim", "ch2_eye_unsent_backup", "ch3_backup_permission", "ch3_grey_care_terms", "ch1_scan_grid", "ch2_scan_warehouse_batch", "ch2_scan_withdrawal_queue", "ch2_scan_dispatch_clock", "ch3_xiao_record_challenge", "ch3_scan_recovery_route", "ch3_scan_memory_anchor", "ch3_recovery_quiet", "ch2_archive_returned_index"]:
			gm.set_decision("market_claim_resolution", "bounded")
			gm.set_decision("backup_handling", "sealed")
			gm.set_decision("ghost_identity_choice", "expose")
			gm.set_decision("memory_trade_method", "buy")
			gm.set_dialogue_flag("ghost_identity_exposed")
			gm.set_dialogue_flag("public_sources_verified")
			ds.start_dialogue(data.get_dialogue(dialogue_id))
			for step in 100:
				ds._finish_typing()
				if ds.choices_container.visible:
					break
				ds._advance()
				await process_frame
			await process_frame
			await process_frame
			if dialogue_id in ["ch2_referral_number", "ch2_referral_reassigned", "ch2_auction_batch"]:
				_check(ds._story_cg_overlay != null and ds._story_cg_overlay.visible and ds._story_cg_overlay.texture != null, "Route prop is loaded")
				_check(not ds._story_cg_overlay.get_global_rect().intersects(ds.dialogue_panel.get_global_rect()), "Route prop stays above dialogue")
			var panel: Rect2 = ds.dialogue_panel.get_global_rect().grow(0.5)
			_check(ds.choices_container.visible, "Choices reached: " + dialogue_id)
			_check(ds.dialogue_text.get_content_height() <= ds.dialogue_text.size.y + 1.0, "Choice prompt must not lose its second line")
			_check(panel.encloses(ds.choices_scroll.get_global_rect()), "Scroll area fits the actual frame")
			var buttons: Array = ds.choices_container.get_children()
			for button in buttons:
				_check(button.get_theme_font_size("font_size") >= 18, "Choice font remains readable")
			if buttons.size() <= 3:
				for button in buttons:
					_check(panel.encloses(button.get_global_rect()), "All three choices visible: " + config[2])
			else:
				ds.choices_scroll.scroll_vertical = 10000
				await process_frame
				await process_frame
				_check(ds.choices_scroll.get_global_rect().grow(0.5).encloses(buttons[-1].get_global_rect()), "Fourth choice reachable by scrolling")
			if "--render-check" in OS.get_cmdline_user_args():
				RenderingServer.force_draw(false)
				var folder := "res://docs/verification/chapter_branches_2026_09_09"
				DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
				_check(view.get_texture().get_image().save_png(folder + "/" + config[2] + "_" + dialogue_id + ".png") == OK, "Screenshot saved")
			ds.end_dialogue()
		ds.start_dialogue(data.get_dialogue("ending_a_justice"))
		ds._finish_typing()
		await process_frame
		_check(ds._story_cg_overlay.size.is_equal_approx(Vector2(config[1])), "CG fits viewport instead of its native pixel dimensions")
		_check(ds._story_cg_overlay.visible and ds._story_cg_overlay.texture != null, "Ending uses the generated CG")
		if "--render-check" in OS.get_cmdline_user_args():
			RenderingServer.force_draw(false)
			_check(view.get_texture().get_image().save_png("res://docs/verification/chapter_branches_2026_09_09/" + config[2] + "_public_cg.png") == OK, "Public CG screenshot saved")
		ds.end_dialogue()
		scene._show_map()
		await process_frame
		await process_frame
		await process_frame
		var map_panel: Control = scene.get_node("LocationMap").get_child(1).get_child(0)
		_check(Rect2(Vector2.ZERO, Vector2(config[1])).encloses(map_panel.get_global_rect()), "Map fits viewport including small mobile")
		_check(map_panel.get_global_rect().get_center().distance_to(Vector2(config[1]) * 0.5) < 1.0, "Map is centered")
		var scroll: ScrollContainer = map_panel.get_child(0).get_child(0)
		scroll.scroll_vertical = 10000
		await process_frame
		_check(scroll.get_global_rect().grow(1).encloses(scroll.get_child(0).get_children()[-1].get_global_rect()), "Map cancel remains reachable")
		if "--render-check" in OS.get_cmdline_user_args():
			RenderingServer.force_draw(false)
			view.get_texture().get_image().save_png("res://docs/verification/chapter_branches_2026_09_09/" + config[2] + "_map.png")
		view.queue_free()
		await process_frame
		for sample in [[2, "referral_waiting_station"], [2, "auction_handover_room"], [1, "abyss_bar"], [1, "east_district_street"], [2, "bitstorm_cafe"], [2, "memory_black_market"], [2, "abandoned_warehouse"], [2, "zhengtek_exterior"], [2, "civic_archive"], [3, "secret_lab"], [3, "memory_space"], [3, "recovery_annex"]]:
			gm.new_game()
			gm.current_chapter = sample[0]
			if sample[1] == "auction_handover_room":
				gm.set_decision("chapter_2_route", "black_market")
			gm.set_dialogue_flag("visited_" + sample[1])
			gm.set_dialogue_flag("hao_ran_rescued")
			for action in CaseData.get_chapter_data(sample[0]).locations[sample[1]].story_actions:
				if not action.has("scan_position"):
					continue
				for flag in action.get("requires_flags", []) + [action.get("requires_flag", "")]:
					if flag != "":
						gm.set_dialogue_flag(flag)
				for evidence in action.get("requires_evidences", []) + [action.get("requires_evidence", "")]:
					if evidence != "":
						gm.collect_evidence(evidence)
			var map_view := SubViewport.new()
			map_view.size = config[1]
			map_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(map_view)
			var map_scene = load(root.get_node("SceneManager").scene_paths[sample[1]]).instantiate()
			map_view.add_child(map_scene)
			await process_frame
			map_scene._toggle_eagle_eye()
			await create_timer(0.4).timeout
			var marker: Button = map_scene._scan_markers[0]
			_check(marker.visible and Rect2(Vector2.ZERO, Vector2(config[1])).encloses(marker.get_global_rect()), "New map scan marker is visible and within viewport")
			_check(marker.size.x >= 48 and marker.size.y >= 48, "Scan marker remains a usable touch target")
			_check(marker.get_parent().layer > map_scene._augmented_vision.layer, "Scan label stays above the visual filter")
			_check(not marker.get_global_rect().intersects(map_scene._augmented_vision.energy_bar.get_global_rect()), "Scan marker avoids energy HUD: " + str(sample[1]) + " " + str(config[2]))
			if "--render-check" in OS.get_cmdline_user_args():
				RenderingServer.force_draw(false)
				_check(map_view.get_texture().get_image().save_png("res://docs/verification/chapter_branches_2026_09_09/" + config[2] + "_" + sample[1] + ".png") == OK, "New location screenshot saved")
			if sample[1] == "civic_archive":
				for chapter in [1, 2, 3]:
					for place in CaseData.get_chapter_data(chapter).locations.values():
						for action in place.get("story_actions", []):
							if action.has("scan_flag"):
								gm.set_dialogue_flag(action.scan_flag)
				map_scene._show_scan_journal()
				await process_frame
				await process_frame
				await process_frame
				var journal_panel: Control = map_scene.get_node("ScanJournal").get_child(1).get_child(0)
				_check(Rect2(Vector2.ZERO, Vector2(config[1])).encloses(journal_panel.get_global_rect()), "Ten saved observations fit a scrollable journal")
				var journal_scroll: ScrollContainer = journal_panel.get_child(0).get_child(0)
				journal_scroll.scroll_vertical = 10000
				await process_frame
				_check(journal_scroll.get_global_rect().grow(1).encloses(journal_scroll.get_child(0).get_children()[-1].get_global_rect()), "Journal return button remains reachable")
				if "--render-check" in OS.get_cmdline_user_args():
					RenderingServer.force_draw(false)
					_check(map_view.get_texture().get_image().save_png("res://docs/verification/chapter_branches_2026_09_09/" + config[2] + "_scan_journal.png") == OK, "Journal screenshot saved")
			map_view.queue_free()
			await process_frame
	root.get_node("AudioManager").stop_bgm(false)
	await create_timer(0.5).timeout
	print("DIALOGUE_LAYOUT_%s: checks=%d failures=%s" % ["PASS" if failures.is_empty() else "FAIL", checks, JSON.stringify(failures)])
	quit(0 if failures.is_empty() else 1)
