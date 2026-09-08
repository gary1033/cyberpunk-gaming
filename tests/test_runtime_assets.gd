extends SceneTree
## Exercise real PCK remaps with no source image/audio, plus unimported PNGs.

const Assets = preload("res://scripts/core/runtime_assets.gd")
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
	var fixture_dir := "user://asset_loader_test_%d/" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(fixture_dir)
	var sample := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	sample.fill(Color(0.1, 0.5, 0.8, 0.5))
	_check(sample.save_png(fixture_dir + "raw.png") == OK, "Create raw PNG")
	_check(ResourceSaver.save(ImageTexture.create_from_image(sample), fixture_dir + "image.tres") == OK, "Create packed texture")
	var sound := AudioStreamWAV.new()
	sound.data = PackedByteArray([0, 0, 0, 0])
	_check(ResourceSaver.save(sound, fixture_dir + "sound.tres") == OK, "Create packed audio")
	var placeholder := FileAccess.open(fixture_dir + "placeholder.ogg", FileAccess.WRITE)
	placeholder.store_buffer("OggS".to_utf8_buffer())
	placeholder.store_8(0)
	placeholder.store_buffer("x".repeat(50).to_utf8_buffer())
	placeholder.close()
	for entry in [["image.png", "image.tres"], ["sound.ogg", "sound.tres"]]:
		var file := FileAccess.open(fixture_dir + entry[0] + ".remap", FileAccess.WRITE)
		file.store_string('[remap]\npath="res://__asset_loader_test/%s"\n' % entry[1])
		file.close()
	var pack := PCKPacker.new()
	_check(pack.pck_start(fixture_dir + "fixture.pck") == OK, "Create PCK")
	for name in ["raw.png", "image.tres", "sound.tres", "image.png.remap", "sound.ogg.remap", "placeholder.ogg"]:
		_check(pack.add_file("res://__asset_loader_test/" + name, fixture_dir + name) == OK, "Pack " + name)
	_check(pack.flush() == OK, "Finish PCK")
	_check(ProjectSettings.load_resource_pack(fixture_dir + "fixture.pck"), "Mount PCK")
	_check(not FileAccess.file_exists("res://__asset_loader_test/image.png"), "Packed texture has no source PNG")
	var texture := Assets.load_texture("res://__asset_loader_test/image.png")
	_check(texture != null and texture.get_size() == Vector2(2, 2), "Load remapped texture without PNG")
	_check(Assets.load_texture("res://__asset_loader_test/image.png") == texture, "Reuse Godot resource cache")
	var raw := Assets.load_texture("res://__asset_loader_test/raw.png")
	_check(raw != null and raw.get_size() == Vector2(2, 2), "Load unimported PNG from PCK bytes")
	_check(Assets.load_texture("") == null, "Empty optional texture")
	_check(Assets.load_texture("res://__asset_loader_test/missing.png") == null, "Missing optional texture")
	_check(Assets.load_texture("res://__asset_loader_test/sound.tres") == null, "Reject wrong resource type")
	var audio = root.get_node("AudioManager")
	_check(not audio.is_runtime_audio_ready("res://__asset_loader_test/placeholder.ogg"), "Reject short OggS impostor")
	_check(not FileAccess.file_exists("res://__asset_loader_test/sound.ogg"), "Packed audio has no source OGG")
	_check(audio.is_runtime_audio_ready("res://__asset_loader_test/sound.ogg"), "Optional audio accepts imported remap")
	audio.play_optional_sfx("res://__asset_loader_test/sound.ogg")
	_check(audio._sfx_players[0].stream != null, "Play remapped optional audio")
	_check(not audio.is_runtime_audio_ready("res://__asset_loader_test/missing.ogg"), "Missing optional audio")
	for player in audio._sfx_players:
		player.stop()
		player.stream = null
	await create_timer(0.5).timeout
	# Only remove exact files made by this run; the mounted PCK may remain locked.
	for name in ["raw.png", "image.tres", "sound.tres", "image.png.remap", "sound.ogg.remap", "placeholder.ogg", "fixture.pck"]:
		DirAccess.remove_absolute(fixture_dir + name)
	DirAccess.remove_absolute(fixture_dir)
	print("RUNTIME_ASSETS_%s: %d checks" % ["PASS" if failures.is_empty() else "FAIL", checks])
	call_deferred("quit", 0 if failures.is_empty() else 1)
