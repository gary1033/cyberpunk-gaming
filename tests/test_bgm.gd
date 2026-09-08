extends SceneTree
## Godot --headless --path . --script res://tests/test_bgm.gd

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var manager = root.get_node("AudioManager")
	_check(not manager.is_runtime_audio_ready("res://assets/audio/sfx/family_memory_fragment.ogg"), "Short placeholder must not reach the resource loader")
	_check(manager.is_runtime_audio_ready(manager.THEME_BGM), "Real OGG passes the header guard")
	for path in [manager.THEME_BGM, manager.CLUB_BGM, manager.INVESTIGATION_BGM]:
		var stream := load(path) as AudioStreamOggVorbis
		_check(stream != null and stream.get_length() > 60.0, "Full OGG must decode: " + path)
		if stream == null:
			continue
		manager.play_bgm(path, false)
		_check(manager._bgm_player.playing and manager._bgm_player.stream.loop, "BGM starts and loops")
		manager._bgm_player.seek(stream.get_length() - 0.1)
		await create_timer(0.4).timeout
		_check(manager._bgm_player.playing and manager._bgm_player.get_playback_position() < 2.0, "Playback wraps at track end")

	# Real scene entry must select its music, including a directly launched location.
	for entry in [["main_menu", manager.THEME_BGM], ["detective_office", manager.INVESTIGATION_BGM], ["abyss_bar", manager.CLUB_BGM], ["secret_lab", manager.INVESTIGATION_BGM], ["civic_archive", manager.INVESTIGATION_BGM], ["recovery_annex", manager.THEME_BGM]]:
		await root.get_node("SceneManager").change_scene(entry[0])
		_check(manager._current_bgm == entry[1], "Scene BGM: " + entry[0])
	manager.play_bgm(manager.THEME_BGM, false)
	await create_timer(0.2).timeout
	var before: float = manager._bgm_player.get_playback_position()
	manager.play_bgm(manager.THEME_BGM)
	_check(manager._bgm_player.get_playback_position() >= before, "Same track does not restart")
	manager.play_bgm(manager.CLUB_BGM)
	manager.play_bgm(manager.INVESTIGATION_BGM)
	manager.set_bgm_volume(0.0)
	_check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "Mute during crossfade")
	manager.set_bgm_volume(0.25)
	await create_timer(1.2).timeout
	_check(manager._bgm_player.playing and not manager._bgm_player_2.playing and manager._current_bgm == manager.INVESTIGATION_BGM, "Newest rapid request survives old fade")
	_check(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")), linear_to_db(0.25)), "Fade preserves slider volume")
	manager.stop_bgm()
	manager.play_bgm(manager.CLUB_BGM)
	await create_timer(1.2).timeout
	_check(manager._bgm_player.playing and manager._current_bgm == manager.CLUB_BGM, "Old stop cannot stop new music")
	manager.play_bgm(manager.THEME_BGM)
	manager.stop_bgm(false)
	await create_timer(1.2).timeout
	_check(not manager._bgm_player.playing and not manager._bgm_player_2.playing, "Stop cancels both crossfade players")
	if current_scene:
		current_scene.queue_free()
	await process_frame
	print("BGM_%s: checks=%d failures=%s" % ["PASS" if failures.is_empty() else "FAIL", checks, JSON.stringify(failures)])
	quit(0 if failures.is_empty() else 1)
