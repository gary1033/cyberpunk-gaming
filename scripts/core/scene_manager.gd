extends Node
## SceneManager - Handles scene transitions with fade effects.

signal scene_changed(scene_name: String)
signal transition_started
signal transition_finished

const FADE_DURATION: float = 0.5

var _transition_overlay: ColorRect = null
var _is_transitioning: bool = false

# Scene path mapping
var scene_paths: Dictionary = {
	# Main
	"main_menu": "res://scenes/main_menu.tscn",
	"game": "res://scenes/game.tscn",
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
	"memory_black_market": "res://scenes/locations/chapter2/memory_black_market.tscn",
	"abandoned_warehouse": "res://scenes/locations/chapter2/abandoned_warehouse.tscn",
	"zhengtek_exterior": "res://scenes/locations/chapter2/zhengtek_exterior.tscn",
	"sewer_passage": "res://scenes/locations/chapter2/sewer_passage.tscn",
	"bitstorm_cafe": "res://scenes/locations/chapter2/bitstorm_cafe.tscn",
	# Chapter 3
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

func change_scene(scene_name: String) -> void:
	if _is_transitioning:
		return

	if scene_name not in scene_paths:
		push_error("SceneManager: Unknown scene '%s'" % scene_name)
		return

	_is_transitioning = true
	transition_started.emit()

	# Fade to black
	var tween := create_tween()
	tween.tween_property(_transition_overlay, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished

	# Change the scene
	var error := get_tree().change_scene_to_file(scene_paths[scene_name])
	if error != OK:
		push_error("SceneManager: Failed to load scene '%s'" % scene_name)
		_is_transitioning = false
		return

	GameManager.current_location = scene_name

	# Wait one frame for scene to initialize
	await get_tree().process_frame

	# Fade from black
	var tween2 := create_tween()
	tween2.tween_property(_transition_overlay, "modulate:a", 0.0, FADE_DURATION)
	await tween2.finished

	_is_transitioning = false
	scene_changed.emit(scene_name)
	transition_finished.emit()

func change_scene_with_chapter_title(scene_name: String, chapter_num: int, chapter_title: String) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	transition_started.emit()

	# Fade to black
	var tween := create_tween()
	tween.tween_property(_transition_overlay, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished

	# Show chapter title
	var title_label := _show_chapter_title(chapter_num, chapter_title)
	await get_tree().create_timer(2.5).timeout

	# Clean up title label before scene change
	if is_instance_valid(title_label):
		title_label.queue_free()

	# Change scene
	if scene_name not in scene_paths:
		push_error("SceneManager: Unknown scene '%s'" % scene_name)
		_is_transitioning = false
		return

	var error := get_tree().change_scene_to_file(scene_paths[scene_name])
	if error != OK:
		push_error("SceneManager: Failed to load scene '%s'" % scene_name)
		_is_transitioning = false
		return

	GameManager.current_location = scene_name

	await get_tree().process_frame

	# Fade from black
	var tween2 := create_tween()
	tween2.tween_property(_transition_overlay, "modulate:a", 0.0, FADE_DURATION)
	await tween2.finished

	_is_transitioning = false
	scene_changed.emit(scene_name)
	transition_finished.emit()

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
