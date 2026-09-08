extends SceneTree
## Logic: Godot --headless --path . --script res://tests/test_energy_hud.gd
## Pixels: Godot --rendering-method gl_compatibility --audio-driver Dummy --path .
##         --script res://tests/test_energy_hud.gd -- --render-check
## The render check hides its main window and captures a plain SubViewport.

const WIDGET_PATH := "res://scripts/ui/segmented_energy_bar.gd"
const FRAME_PATH := "res://assets/sprites/ui/energy_hud_frame.png"
const OUTPUT_DIR := "res://docs/verification/energy_hud_2026_09_08"
const FRAME_SIZE := Vector2i(512, 96)
const AP_SEGMENTS := [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10]

var gm: Node
var sm: Node
var widget_script: GDScript
var failures: Array[String] = []
var check_count := 0
var pixel_checked := false


func _initialize() -> void:
	if DisplayServer.get_name() != "headless":
		root.hide()
	call_deferred("_run")


func _check(condition: bool, message: String) -> bool:
	check_count += 1
	if not condition:
		failures.append(message)
		push_error("ENERGY_HUD: " + message)
	return condition


func _run() -> void:
	gm = root.get_node("GameManager")
	sm = root.get_node("SceneManager")
	if not _check(ResourceLoader.exists(WIDGET_PATH) and ResourceLoader.exists(FRAME_PATH), "Widget and imported frame must exist"):
		_finish()
		return
	widget_script = load(WIDGET_PATH)
	_check_conversion()
	await _check_consumers()
	if "--render-check" in OS.get_cmdline_user_args():
		if _check(DisplayServer.get_name() != "headless", "Pixel verification requires a real renderer; headless only supports dummy on this Godot build"):
			await _check_rendered_pixels()
	if current_scene != null:
		current_scene.queue_free()
	await process_frame
	_finish()


func _finish() -> void:
	root.get_node("AudioManager").stop_bgm(false)
	await create_timer(0.5).timeout # Let the audio thread release playback before exit.
	print("ENERGY_HUD_%s: checks=%d pixels=%s failures=%s" % [
		"PASS" if failures.is_empty() else "FAIL", check_count,
		"verified" if pixel_checked else "not_run", JSON.stringify(failures)])
	call_deferred("quit", 0 if failures.is_empty() else 1)


# Bug regression: zero must be empty, and any positive fraction must light a cell.
func _check_conversion() -> void:
	var cases := [
		[-1.0, 100.0, 0], [0.0, 100.0, 0], [0.00001, 100.0, 1],
		[9.999, 100.0, 1], [10.0, 100.0, 1], [10.001, 100.0, 2],
		[19.999, 100.0, 2], [20.0, 100.0, 2], [20.001, 100.0, 3],
		[90.0, 100.0, 9], [90.001, 100.0, 10], [100.0, 100.0, 10],
		[150.0, 100.0, 10], [10.0, 0.0, 0], [10.0, -1.0, 0]
	]
	for sample in cases:
		_check(widget_script.get_segment_count(sample[0], sample[1]) == sample[2],
			"Segment boundary %s/%s should be %s" % sample)
	var widget: TextureRect = widget_script.new()
	root.add_child(widget)
	_check(widget.texture != null, "Fixed frame texture loads")
	var original_texture: Texture2D = widget.texture
	for count in range(11):
		widget.set_energy(count, 10)
		_check(widget.lit_segments == count, "Widget supports state %d" % count)
		_check(widget.texture == original_texture, "Widget does not swap its frame at state %d" % count)
	widget.queue_free()


func _energy_is(expected: float, message: String) -> void:
	_check(is_equal_approx(float(gm.eagle_eye_energy), expected), message)


# Bug regression: both real HUD consumers share the fixed-frame implementation.
func _check_consumers() -> void:
	gm.new_game()
	gm.set_dialogue_flag("visited_detective_office")
	gm.set_dialogue_flag("visited_mei_ling_apartment")
	if not _check(await sm.change_scene("detective_office"), "Real location loads"):
		return
	var location: Node = current_scene
	var vision: Node = location._augmented_vision
	# Drive the actual process callback with exact deltas, avoiding frame-rate noise.
	vision.set_process(false)
	var ap_widget: TextureRect = location._ap_status_bar
	var eye_widget: TextureRect = vision.energy_bar_texture
	_check(eye_widget.spectrum_enabled and not ap_widget.spectrum_enabled, "Only eagle eye uses the new spectrum; AP keeps its palette")
	if not _check(ap_widget != null and eye_widget != null, "Both real HUD widgets exist"):
		return
	if not _check(ap_widget.get_script() == widget_script and eye_widget.get_script() == widget_script,
			"AP and eagle eye instantiate SegmentedEnergyBar"):
		return
	var ap_texture: Texture2D = ap_widget.texture
	var eye_texture: Texture2D = eye_widget.texture
	if not _check(ap_texture != null and eye_texture != null, "Both consumers have frame textures"):
		return
	_check(ap_texture.get_image().get_data() == eye_texture.get_image().get_data(), "Both consumers use identical frame pixels")
	for remaining in range(20, -1, -1):
		gm.action_points = remaining
		gm.action_points_changed.emit(remaining)
		_check(ap_widget.lit_segments == AP_SEGMENTS[remaining], "AP %d has correct lit cells" % remaining)
		_check(ap_widget.texture == ap_texture, "AP %d preserves texture identity" % remaining)
	gm.action_points = 20
	gm.action_points_changed.emit(20)
	gm.eagle_eye_energy = 100.0
	vision._activate()
	vision._update_energy_bar()
	_check(gm.eagle_eye_active and vision.energy_bar.visible and not location._ap_widget.visible, "Activation displays eagle energy and hides AP")
	vision._process(0.75)
	_energy_is(92.5, "Partial use is charged immediately")
	_check(eye_widget.lit_segments == 10, "Partial use retains the ten-cell display until its boundary")
	vision._process(0.25)
	_energy_is(90.0, "First complete second consumes exactly ten energy")
	_check(eye_widget.lit_segments == 9, "First second removes one lit cell")
	for remaining in range(80, -1, -10):
		vision._process(1.0)
		_energy_is(float(remaining), "Energy drains to %d after a complete second" % remaining)
		_check(eye_widget.lit_segments == remaining / 10, "Eagle eye %d shows correct cells" % remaining)
		_check(eye_widget.texture == eye_texture, "Eagle eye %d preserves texture identity" % remaining)
	_check(not gm.eagle_eye_active, "Exhausted energy deactivates eagle eye")
	await create_timer(0.35).timeout
	_check(not vision.energy_bar.visible and location._ap_widget.visible, "Exhaustion restores AP display after fade")
	vision._process(2.0)
	_energy_is(10.0, "Inactive energy recharges five units per second")
	_check(eye_widget.lit_segments == 1, "Recharging from zero lights the first cell")
	vision._activate()
	_check(gm.eagle_eye_active, "Exactly one cell can activate eagle eye")
	vision._process(1.0)
	_energy_is(0.0, "The final cell can be spent")
	_check(not gm.eagle_eye_active and eye_widget.lit_segments == 0, "Final-cell depletion renders zero")
	vision._process(0.01)
	vision._activate()
	_check(gm.eagle_eye_active, "A positive partial cell can activate eagle eye")
	vision._deactivate()
	vision._process(100.0)
	_energy_is(100.0, "Recharge clamps at maximum")
	# Bug regression: repeated subsecond toggles used to reset the drain timer.
	for cycle in range(10):
		vision._activate()
		vision._process(0.4)
		vision._deactivate()
		vision._process(0.1)
	_energy_is(65.0, "Ten short toggles pay four seconds of use minus one second of recharge")
	_check(eye_widget.lit_segments == 7, "Short toggles cannot keep a full energy bar")
	# Persist the fraction through the existing save format; no local timer debt.
	vision._activate()
	vision._process(0.0375)
	vision._deactivate()
	var fractional_save: Dictionary = gm.get_save_data()
	gm.eagle_eye_energy = 100.0
	gm.load_save_data(fractional_save)
	_energy_is(64.625, "Save/load cannot discard fractional energy spent by short toggles")
	gm.eagle_eye_energy = 60.0
	vision._activate()
	vision._deactivate()
	vision._activate()
	await create_timer(0.5).timeout
	_check(gm.eagle_eye_active and vision.overlay.visible and vision.energy_bar.visible and vision.scan_label.visible,
		"Rapid off/on is not hidden by the previous fade callback")
	_check(vision.overlay.modulate.a > 0.9 and not location._ap_widget.visible, "Rapid off/on restores visible overlay opacity and HUD selection")
	vision._process(0.37)
	var before_travel: float = gm.eagle_eye_energy
	if not _check(await sm.change_scene("mei_ling_apartment"), "Active eagle eye can change real location"):
		return
	location = current_scene
	vision = location._augmented_vision
	vision.set_process(false)
	_check(gm.eagle_eye_energy <= before_travel, "Scene travel never restores energy spent by partial use")
	var after_travel: float = gm.eagle_eye_energy
	vision._process(0.23)
	_energy_is(after_travel - 2.3, "New scene continues charging partial use")
	eye_widget = vision.energy_bar_texture
	_check(gm.eagle_eye_active and vision.overlay.visible and vision.energy_bar.visible and vision.scan_label.visible,
		"New scene restores all active eagle-eye visuals")
	_check(not location._ap_widget.visible, "New scene does not show AP over an active eagle-eye bar")
	_check(eye_widget.lit_segments == widget_script.get_segment_count(gm.eagle_eye_energy, gm.eagle_eye_max_energy),
		"New scene shows the existing global energy")
	_check(eye_widget.texture.get_image().get_data() == eye_texture.get_image().get_data(), "Scene change preserves the same frame pixels")
	vision._deactivate()
	await create_timer(0.3).timeout
	_check(not vision.energy_bar.visible and location._ap_widget.visible, "Deactivation in the new scene restores AP")
	gm.eagle_eye_energy = 0.0
	vision._activate()
	_check(not gm.eagle_eye_active, "Zero energy cannot activate eagle eye")
	await create_timer(0.7).timeout


# The mask is an independent specification, not the widget's own geometry helper.
func _cell_at(x: int, y: int) -> int:
	if y < 36 or y >= 62:
		return -1
	for index in range(10):
		var left := 120 + index * 33
		if x >= left and x < left + 29:
			return index
	return -1


func _pixel_difference(before: Image, after: Image) -> Dictionary:
	var cell_changes: Array[int] = []
	cell_changes.resize(10)
	cell_changes.fill(0)
	var outside_changes := 0
	for y in range(FRAME_SIZE.y):
		for x in range(FRAME_SIZE.x):
			if before.get_pixel(x, y) == after.get_pixel(x, y):
				continue
			var cell := _cell_at(x, y)
			if cell < 0:
				outside_changes += 1
			else:
				cell_changes[cell] += 1
	return {"outside_cells": outside_changes, "cell_changed_pixels": cell_changes}


# Bug regression: changing energy must never replace or recolor the frame/icon.
func _check_rendered_pixels() -> void:
	var viewport := SubViewport.new()
	viewport.size = FRAME_SIZE
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var widget: TextureRect = widget_script.new()
	widget.position = Vector2.ZERO
	widget.spectrum_enabled = true
	widget.size = Vector2(FRAME_SIZE)
	viewport.add_child(widget)
	var snapshots: Array[Image] = []
	var report := {"display_driver": DisplayServer.get_name(), "frame_size": [512, 96], "states": [], "comparisons": []}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for count in range(11):
		widget.set_energy(count, 10)
		await process_frame
		await process_frame
		RenderingServer.force_draw(false)
		var snapshot: Image = viewport.get_texture().get_image()
		if not _check(snapshot != null and not snapshot.is_empty() and snapshot.get_size() == FRAME_SIZE, "Renderer captures state %d" % count):
			viewport.queue_free()
			return
		snapshot.convert(Image.FORMAT_RGBA8)
		snapshots.append(snapshot)
		var filename := "energy_%02d.png" % count
		_check(snapshot.save_png(OUTPUT_DIR.path_join(filename)) == OK, "Rendered state %d is retained" % count)
		report["states"].append({"lit_segments": count, "file": filename})
	# The empty frame must itself be visible, ruling out blank framebuffer passes.
	var cell_colors: Array[Color] = []
	for index in range(10):
		var color := snapshots[10].get_pixel(130 + index * 33, 48)
		cell_colors.append(color)
	var bands: Array[Color] = [cell_colors[0], cell_colors[3], cell_colors[5], cell_colors[7]]
	_check(bands[0] != bands[1] and bands[0] != bands[2] and bands[0] != bands[3] and bands[1] != bands[2] and bands[1] != bands[3] and bands[2] != bands[3], "Eagle eye has four distinct color bands")
	_check(cell_colors == [bands[0], bands[0], bands[0], bands[1], bands[1], bands[2], bands[2], bands[3], bands[3], bands[3]], "Four bands divide ten cells symmetrically 3/2/2/3")
	var visible_pixels := 0
	for y in range(FRAME_SIZE.y):
		for x in range(FRAME_SIZE.x):
			if _cell_at(x, y) < 0 and snapshots[0].get_pixel(x, y).a > 0.5:
				visible_pixels += 1
	_check(visible_pixels > 1000, "Framebuffer contains the fixed frame and icon")
	for count in range(1, 11):
		var compared := _pixel_difference(snapshots[0], snapshots[count])
		_check(compared["outside_cells"] == 0, "State %d changes no frame/icon pixels" % count)
		for index in range(10):
			_check((compared["cell_changed_pixels"][index] > 0) == (index < count), "State %d lights exactly its first %d cells (cell %d)" % [count, count, index])
		var adjacent := _pixel_difference(snapshots[count - 1], snapshots[count])
		_check(adjacent["outside_cells"] == 0, "Adjacent state %d preserves the entire outer frame" % count)
		if count >= 4:
			for index in range(10):
				_check((adjacent["cell_changed_pixels"][index] > 0) == (index == count - 1), "High-energy transition %d changes only its new cell (cell %d)" % [count, index])
		report["comparisons"].append({"state": count, "from_zero": compared, "from_previous": adjacent})
	var contact_sheet := Image.create(512, 96 * 11, false, Image.FORMAT_RGBA8)
	for count in range(11):
		contact_sheet.blit_rect(snapshots[count], Rect2i(Vector2i.ZERO, FRAME_SIZE), Vector2i(0, (10 - count) * 96))
	_check(contact_sheet.save_png(OUTPUT_DIR.path_join("all_states_10_to_0.png")) == OK, "All-state visual comparison is retained")
	report["outside_frame_visible_pixels"] = visible_pixels
	report["failures"] = failures.duplicate()
	var report_file := FileAccess.open(OUTPUT_DIR.path_join("pixel_comparison.json"), FileAccess.WRITE)
	if _check(report_file != null, "Pixel comparison report can be written"):
		report_file.store_string(JSON.stringify(report, "\t"))
		report_file.close()
	pixel_checked = true
	viewport.queue_free()
