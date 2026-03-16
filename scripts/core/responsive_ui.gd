extends Node
## ResponsiveUI - Manages responsive layout for different screen orientations and sizes.

signal orientation_changed(is_portrait: bool)
signal layout_changed(layout: String)

var is_portrait: bool = false
var current_layout: String = "landscape"  # "landscape" or "portrait"

# Layout ratios
const PORTRAIT_SCENE_RATIO := 0.6       # Scene takes 60% in portrait
const PORTRAIT_DIALOGUE_RATIO := 0.4    # Dialogue takes 40% in portrait
const LANDSCAPE_SCENE_RATIO := 0.75     # Scene takes 75% in landscape
const LANDSCAPE_DIALOGUE_RATIO := 0.25  # Dialogue takes 25% in landscape

var _last_screen_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	get_tree().root.size_changed.connect(_on_screen_size_changed)
	# Initial check
	call_deferred("_on_screen_size_changed")

func _on_screen_size_changed() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	if screen_size == _last_screen_size:
		return
	_last_screen_size = screen_size

	var new_portrait := screen_size.y > screen_size.x
	var layout_changed_flag := (new_portrait != is_portrait)
	is_portrait = new_portrait
	current_layout = "portrait" if is_portrait else "landscape"

	if layout_changed_flag:
		orientation_changed.emit(is_portrait)
		layout_changed.emit(current_layout)

func get_scene_rect() -> Rect2:
	var screen_size := get_viewport().get_visible_rect().size
	if is_portrait:
		var h := screen_size.y * PORTRAIT_SCENE_RATIO
		return Rect2(0, 0, screen_size.x, h)
	else:
		var h := screen_size.y * LANDSCAPE_SCENE_RATIO
		return Rect2(0, 0, screen_size.x, h)

func get_dialogue_rect() -> Rect2:
	var screen_size := get_viewport().get_visible_rect().size
	if is_portrait:
		var scene_h := screen_size.y * PORTRAIT_SCENE_RATIO
		var dlg_h := screen_size.y * PORTRAIT_DIALOGUE_RATIO
		return Rect2(0, scene_h, screen_size.x, dlg_h)
	else:
		var scene_h := screen_size.y * LANDSCAPE_SCENE_RATIO
		var dlg_h := screen_size.y * LANDSCAPE_DIALOGUE_RATIO
		return Rect2(0, scene_h, screen_size.x, dlg_h)

func get_toolbar_height() -> float:
	if InputManager.is_mobile:
		return 56.0  # Mobile bottom toolbar
	return 0.0  # No toolbar on desktop

func adapt_font_size(base_size: int) -> int:
	return InputManager.get_adaptive_font_size(base_size)
