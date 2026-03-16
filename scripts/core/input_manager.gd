extends Node
## InputManager - Unified input layer for mouse/touch cross-platform support.
## Auto-detects device type and adapts input behavior accordingly.

signal input_mode_changed(mode: String)
signal long_press_triggered(position: Vector2)
signal pinch_zoom(zoom_factor: float, center: Vector2)

enum InputMode { MOUSE, TOUCH }

var current_mode: InputMode = InputMode.MOUSE
var is_mobile: bool = false

# Long press detection
var _touch_start_time: float = 0.0
var _touch_start_pos: Vector2 = Vector2.ZERO
var _is_touching: bool = false
const LONG_PRESS_DURATION: float = 0.5
const LONG_PRESS_MOVE_THRESHOLD: float = 20.0

# Pinch zoom detection
var _touch_points: Dictionary = {}  # {finger_index: position}
var _initial_pinch_distance: float = 0.0
var _is_pinching: bool = false

func _ready() -> void:
	# Detect platform
	is_mobile = _detect_mobile()
	current_mode = InputMode.TOUCH if is_mobile else InputMode.MOUSE

func _detect_mobile() -> bool:
	var os_name := OS.get_name()
	return os_name in ["Android", "iOS"]

func _input(event: InputEvent) -> void:
	# Auto-detect input mode switch
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if current_mode != InputMode.MOUSE:
			current_mode = InputMode.MOUSE
			is_mobile = false
			input_mode_changed.emit("mouse")

	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		if current_mode != InputMode.TOUCH:
			current_mode = InputMode.TOUCH
			is_mobile = true
			input_mode_changed.emit("touch")

	# Handle touch-specific gestures
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)

func _process(delta: float) -> void:
	# Long press check
	if _is_touching and not _is_pinching:
		var elapsed := Time.get_ticks_msec() / 1000.0 - _touch_start_time
		if elapsed >= LONG_PRESS_DURATION:
			long_press_triggered.emit(_touch_start_pos)
			_is_touching = false

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_points[event.index] = event.position

		if event.index == 0:
			_touch_start_time = Time.get_ticks_msec() / 1000.0
			_touch_start_pos = event.position
			_is_touching = true

		# Start pinch if two fingers
		if _touch_points.size() == 2:
			_is_pinching = true
			_is_touching = false
			var points := _touch_points.values()
			_initial_pinch_distance = (points[0] as Vector2).distance_to(points[1] as Vector2)
	else:
		_touch_points.erase(event.index)
		if event.index == 0:
			_is_touching = false
		if _touch_points.size() < 2:
			_is_pinching = false

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	_touch_points[event.index] = event.position

	# Cancel long press if moved too far
	if event.index == 0 and _is_touching:
		if _touch_start_pos.distance_to(event.position) > LONG_PRESS_MOVE_THRESHOLD:
			_is_touching = false

	# Pinch zoom
	if _is_pinching and _touch_points.size() == 2:
		var points := _touch_points.values()
		var current_distance: float = (points[0] as Vector2).distance_to(points[1] as Vector2)
		if _initial_pinch_distance > 0:
			var zoom_factor: float = current_distance / _initial_pinch_distance
			var center: Vector2 = ((points[0] as Vector2) + (points[1] as Vector2)) / 2.0
			pinch_zoom.emit(zoom_factor, center)
		_initial_pinch_distance = current_distance

## Returns the minimum touch target size based on platform
func get_min_touch_target_size() -> Vector2:
	if is_mobile:
		return Vector2(48, 48)
	return Vector2(24, 24)

## Returns appropriate font size based on screen DPI
func get_adaptive_font_size(base_size: int = 18) -> int:
	if is_mobile:
		var screen_dpi := DisplayServer.screen_get_dpi()
		if screen_dpi > 300:
			return int(base_size * 1.5)
		elif screen_dpi > 200:
			return int(base_size * 1.25)
	return base_size
