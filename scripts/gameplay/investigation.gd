extends Node2D
## Investigation - Base class for investigation scenes (locations).
## Manages hotspots, scene interactions, and location navigation.

@export var location_id: String = ""
@export var location_name: String = ""

@onready var background: Sprite2D = $Background if has_node("Background") else null
@onready var hotspots_container: Node2D = $Hotspots if has_node("Hotspots") else null
@onready var dialogue_system: Control = $UI/DialogueSystem if has_node("UI/DialogueSystem") else null
@onready var hud: Control = $UI/HUD if has_node("UI/HUD") else null
@onready var hint_button: Button = $UI/HintButton if has_node("UI/HintButton") else null
@onready var map_button: Button = $UI/MapButton if has_node("UI/MapButton") else null

var _camera: Camera2D = null

func _ready() -> void:
	# Set up camera for zoom support
	_camera = Camera2D.new()
	_camera.make_current()
	add_child(_camera)

	# Mobile hint button
	if hint_button:
		hint_button.visible = InputManager.is_mobile
		hint_button.pressed.connect(_on_hint_pressed)

	if map_button:
		map_button.pressed.connect(_on_map_pressed)

	# Load initial dialogue if this is the first visit
	var chapter_data := CaseData.get_chapter_data(GameManager.current_chapter)
	var loc_data: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	var initial_dialogue: String = loc_data.get("initial_dialogue", "")

	if initial_dialogue != "" and not GameManager.get_dialogue_flag("visited_" + location_id):
		GameManager.set_dialogue_flag("visited_" + location_id)
		var dlg_data := DialogueData.get_dialogue(initial_dialogue)
		if dlg_data.size() > 0 and dialogue_system:
			# Delay to let scene initialize
			await get_tree().create_timer(0.5).timeout
			dialogue_system.start_dialogue(dlg_data)

	# Set up pinch zoom for mobile
	if InputManager:
		InputManager.pinch_zoom.connect(_on_pinch_zoom)

func _on_hint_pressed() -> void:
	Hotspot.pulse_all_hotspots(get_tree())

func _on_map_pressed() -> void:
	_show_location_map()

func _show_location_map() -> void:
	# Show available locations for current chapter
	var chapter_data := CaseData.get_chapter_data(GameManager.current_chapter)
	var current_loc: Dictionary = chapter_data.get("locations", {}).get(location_id, {})
	var connections: Array = current_loc.get("connections", [])

	# Create a simple popup with location buttons
	var popup := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.12, 0.95)
	style.border_color = Color(0.0, 0.7, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	popup.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)

	var title := Label.new()
	title.text = "前往..."
	title.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	for conn_id in connections:
		var loc: Dictionary = chapter_data.get("locations", {}).get(conn_id, {})

		# Check requirements
		var req_flag: String = loc.get("requires_flag", "")
		if req_flag != "" and not GameManager.get_dialogue_flag(req_flag):
			continue

		var btn := Button.new()
		btn.text = loc.get("name", conn_id)
		btn.custom_minimum_size = InputManager.get_min_touch_target_size()
		btn.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
		btn.pressed.connect(func():
			popup.queue_free()
			GameManager.spend_action_points(1)
			await SceneManager.change_scene(conn_id)
		)
		vbox.add_child(btn)

	var close_btn := Button.new()
	close_btn.text = "取消"
	close_btn.custom_minimum_size = InputManager.get_min_touch_target_size()
	close_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	close_btn.pressed.connect(popup.queue_free)
	vbox.add_child(close_btn)

	popup.add_child(vbox)

	# Center on screen
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.custom_minimum_size = Vector2(300, 0)

	# Add to UI layer
	var canvas := CanvasLayer.new()
	canvas.layer = 90
	canvas.add_child(popup)
	add_child(canvas)

func _on_pinch_zoom(zoom_factor: float, _center: Vector2) -> void:
	if _camera:
		_camera.zoom = _camera.zoom * zoom_factor
		_camera.zoom = _camera.zoom.clamp(Vector2(0.5, 0.5), Vector2(2.0, 2.0))
