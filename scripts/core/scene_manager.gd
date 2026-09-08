extends Node
## SceneManager - Handles scene transitions with fade effects.

signal scene_changed(scene_name: String)
signal transition_started
signal transition_finished
signal transition_failed(scene_name: String)

const FADE_DURATION: float = 0.5
const CaseDataScript: GDScript = preload("res://scripts/data/case_data.gd")

var _transition_overlay: ColorRect = null
var _is_transitioning: bool = false

# Scene path mapping
var scene_paths: Dictionary = {
	# Main
	"main_menu": "res://scenes/main_menu.tscn",
	# Chapter 1
	"detective_office": "res://scenes/locations/chapter1/detective_office.tscn",
	"mei_ling_apartment": "res://scenes/locations/chapter1/mei_ling_apartment.tscn",
	"abyss_bar": "res://scenes/locations/chapter1/abyss_bar.tscn",
	"hao_ran_workshop": "res://scenes/locations/chapter1/hao_ran_workshop.tscn",
	"east_district_street": "res://scenes/locations/chapter1/east_district_street.tscn",
	"old_city_police_outpost": "res://scenes/locations/chapter1/old_city_police_outpost.tscn",
	"dr_chen_clinic": "res://scenes/locations/chapter1/dr_chen_clinic.tscn",
	"abyss_bar_backroom": "res://scenes/locations/chapter1/abyss_bar_backroom.tscn",
	# Chapter 2
	"referral_waiting_station": "res://scenes/locations/chapter2/referral_waiting_station.tscn",
	"auction_handover_room": "res://scenes/locations/chapter2/auction_handover_room.tscn",
	"civic_archive": "res://scenes/locations/chapter2/civic_archive.tscn",
	"memory_black_market": "res://scenes/locations/chapter2/memory_black_market.tscn",
	"abandoned_warehouse": "res://scenes/locations/chapter2/abandoned_warehouse.tscn",
	"zhengtek_exterior": "res://scenes/locations/chapter2/zhengtek_exterior.tscn",
	"sewer_passage": "res://scenes/locations/chapter2/sewer_passage.tscn",
	"bitstorm_cafe": "res://scenes/locations/chapter2/bitstorm_cafe.tscn",
	# Chapter 3
	"recovery_annex": "res://scenes/locations/chapter3/recovery_annex.tscn",
	"echo_network_hq": "res://scenes/locations/chapter3/echo_network_hq.tscn",
	"secret_lab": "res://scenes/locations/chapter3/secret_lab.tscn",
	"memory_space": "res://scenes/locations/chapter3/memory_space.tscn",
	"rooftop": "res://scenes/locations/chapter3/rooftop.tscn",
	"office_epilogue": "res://scenes/locations/chapter3/office_epilogue.tscn",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_transition_overlay()

func _create_transition_overlay() -> void:
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color.BLACK
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.modulate.a = 0.0
	_transition_overlay.z_index = 100

	# Full screen coverage
	_transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Add to a CanvasLayer so it's always on top
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 128
	canvas_layer.add_child(_transition_overlay)
	add_child(canvas_layer)

func is_transitioning() -> bool:
	return _is_transitioning

func change_scene(scene_name: String) -> bool:
	return await _change_scene(scene_name)

func travel_to_location(scene_name: String) -> bool:
	if _is_transitioning:
		return false
	if GameManager.action_points < 1:
		transition_failed.emit(scene_name)
		return false
	var chapter_data: Dictionary = CaseDataScript.get_chapter_data(GameManager.current_chapter)
	var locations: Dictionary = chapter_data.get("locations", {})
	var source: Dictionary = locations.get(GameManager.current_location, {})
	var destination: Dictionary = locations.get(scene_name, {})
	if scene_name not in source.get("connections", []) or destination.is_empty():
		transition_failed.emit(scene_name)
		return false
	if not GameManager.meets_story_conditions(destination):
		transition_failed.emit(scene_name)
		return false
	return await _change_scene(scene_name, 0, "", 1)

func change_scene_with_chapter_title(scene_name: String, chapter_num: int, chapter_title: String) -> bool:
	if _is_transitioning or chapter_num not in [1, 2, 3]:
		return false
	var is_new_game: bool = chapter_num == 1 and GameManager.current_chapter == 1
	if not is_new_game and (chapter_num != GameManager.current_chapter + 1 or not GameManager.can_advance_chapter()):
		return false
	var chapter_data: Dictionary = CaseDataScript.get_chapter_data(chapter_num)
	if scene_name != str(chapter_data.get("starting_location", "")):
		return false
	return await _change_scene(scene_name, chapter_num, chapter_title)

func _change_scene(scene_name: String, chapter_num: int = 0, chapter_title: String = "", action_point_cost: int = 0) -> bool:
	if _is_transitioning:
		return false
	if scene_name not in scene_paths:
		transition_failed.emit(scene_name)
		return false
	var path: String = str(scene_paths[scene_name])
	if not ResourceLoader.exists(path, "PackedScene"):
		transition_failed.emit(scene_name)
		return false
	var packed_scene: PackedScene = load(path) as PackedScene
	if packed_scene == null or not packed_scene.can_instantiate():
		transition_failed.emit(scene_name)
		return false

	_is_transitioning = true
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_started.emit()
	var fade_out := create_tween()
	fade_out.tween_property(_transition_overlay, "modulate:a", 1.0, FADE_DURATION)
	await fade_out.finished

	if chapter_num > 0:
		var title_label := _show_chapter_title(chapter_num, chapter_title)
		await get_tree().create_timer(2.5).timeout
		title_label.queue_free()

	var error := get_tree().change_scene_to_packed(packed_scene)
	if error == OK:
		# Commit only after the scene swap is accepted, before the new scene's _ready.
		GameManager.current_location = scene_name
		if chapter_num > 0:
			var chapter_data: Dictionary = CaseDataScript.get_chapter_data(chapter_num)
			GameManager.current_chapter = chapter_num
			GameManager.max_action_points = int(chapter_data.get("action_points", 20))
			GameManager.action_points = GameManager.max_action_points
			GameManager.chapter_changed.emit(chapter_num)
		elif action_point_cost > 0:
			GameManager.action_points -= action_point_cost
		if chapter_num > 0 or action_point_cost > 0:
			GameManager.action_points_changed.emit(GameManager.action_points)
		await get_tree().scene_changed
	else:
		push_warning("SceneManager: Failed to load scene '%s'" % scene_name)

	# Also uncover the original scene on failure, so the player can retry.
	var fade_in := create_tween()
	fade_in.tween_property(_transition_overlay, "modulate:a", 0.0, FADE_DURATION)
	await fade_in.finished
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
	if error == OK:
		scene_changed.emit(scene_name)
	else:
		transition_failed.emit(scene_name)
	transition_finished.emit()
	return error == OK

func _show_chapter_title(chapter_num: int, title: String) -> Label:
	var label := Label.new()
	label.text = "Chapter %d\n%s" % [chapter_num, title]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))  # Cyan neon
	_transition_overlay.add_child(label)

	# Fade in the title
	label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.8)
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)

	return label
