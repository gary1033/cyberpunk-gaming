extends TextureRect

const RuntimeAssetsScript = preload("res://scripts/core/runtime_assets.gd")
## One fixed generated chassis; only the ten identical cell interiors change.

const FRAME_PATH := "res://assets/sprites/ui/energy_hud_frame.png"
const FRAME_SIZE := Vector2(512, 96)
const SEGMENT_COUNT := 10
const CELL_ORIGIN := Vector2(120, 36)
const CELL_SIZE := Vector2(29, 26)
const CELL_GAP := 4.0
const SPECTRUM := [Color("f0787d"), Color("f0787d"), Color("f0787d"), Color("edc66c"), Color("edc66c"), Color("66cbb9"), Color("66cbb9"), Color("78b5e5"), Color("78b5e5"), Color("78b5e5")]
var spectrum_enabled := false
var lit_segments: int = SEGMENT_COUNT

func _init() -> void:
	texture = RuntimeAssetsScript.load_texture(FRAME_PATH)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

static func get_segment_count(value: float, maximum: float) -> int:
	if maximum <= 0.0:
		return 0
	return clampi(ceili(clampf(value / maximum, 0.0, 1.0) * SEGMENT_COUNT), 0, SEGMENT_COUNT)

static func get_segment_rect(index: int) -> Rect2:
	return Rect2(CELL_ORIGIN + Vector2(index * (CELL_SIZE.x + CELL_GAP), 0), CELL_SIZE)

func set_energy(value: float, maximum: float) -> void:
	var count := get_segment_count(value, maximum)
	if count != lit_segments:
		lit_segments = count
		queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / FRAME_SIZE)
	var lit_color := Color("06cce5")
	if lit_segments == 2:
		lit_color = Color("ffad33")
	elif lit_segments == 1:
		lit_color = Color("f74e58")
	for index in range(SEGMENT_COUNT):
		if spectrum_enabled:
			lit_color = SPECTRUM[index]
		var origin := get_segment_rect(index).position
		var corners := PackedVector2Array([
			origin + Vector2(4, 0), origin + Vector2(28, 0),
			origin + Vector2(24, 25), origin + Vector2(0, 25)
		])
		var lit := index < lit_segments
		draw_colored_polygon(corners, lit_color if lit else Color("0b2630"))
		if lit:
			draw_line(origin + Vector2(6, 2), origin + Vector2(26, 2), lit_color.lightened(0.55), 1.0)
