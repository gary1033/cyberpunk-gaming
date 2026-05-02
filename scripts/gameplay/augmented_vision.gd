extends CanvasLayer
## AugmentedVision (Eagle Eye) - Toggleable enhanced vision mode.
## Builds its own runtime UI so every location can mount it safely.

signal eagle_eye_activated
signal eagle_eye_deactivated
signal energy_changed(energy: float, max_energy: float)

const EAGLE_EYE_OVERLAY_PATH := "res://assets/sprites/ui/eagle_eye_scan_overlay_ch1.png"
const EAGLE_EYE_RETICLE_PATH := "res://assets/sprites/ui/eagle_eye_focus_reticle_ch1.png"
const EAGLE_EYE_GLITCH_NOISE_PATH := "res://assets/sprites/ui/eagle_eye_glitch_noise_ch1.png"
const EAGLE_EYE_ACTIVATION_CUTIN_PATH := "res://assets/sprites/cg/eagle_eye_activation_cutin_ch1.png"
const EAGLE_EYE_GLITCH_STING_SFX := "res://assets/audio/sfx/eagle_eye_glitch_sting.ogg"
const ENERGY_BAR_STATE_DIR := "res://assets/sprites/ui"
const EAGLE_EYE_ENERGY_BAR_RECT := Rect2(-536.0, 20.0, 512.0, 96.0)

var overlay: ColorRect = null
var generated_overlay: TextureRect = null
var generated_reticle: TextureRect = null
var glitch_noise: TextureRect = null
var activation_cutin: TextureRect = null
var energy_bar: Control = null
var energy_bar_texture: TextureRect = null
var toggle_button: Button = null
var scan_label: Label = null
var focus_reticle: ColorRect = null

var _shader_material: ShaderMaterial = null
var _drain_timer: float = 0.0
var _energy_pulse_phase: float = 0.0
var _current_energy_state: int = -1
var _reticle_position: Vector2 = Vector2.ZERO
var _reticle_target_position: Vector2 = Vector2.ZERO
var _reticle_initialized: bool = false
var _reticle_scan_timer: float = 0.0
var _last_focused_hotspot: Node = null

const EAGLE_EYE_SEGMENT_COUNT := 10
const EAGLE_EYE_DRAIN_INTERVAL := 1.0
const EAGLE_EYE_RETICLE_SIZE := Vector2(192, 192)
const EAGLE_EYE_RETICLE_SCAN_RADIUS := 72.0

func _ready() -> void:
	layer = 50
	_ensure_runtime_nodes()
	_setup_shader_fallback()
	_setup_generated_overlay()
	_update_energy_bar()

func _ensure_runtime_nodes() -> void:
	_ensure_overlay_nodes()
	_ensure_reticle_nodes()
	_ensure_activation_cutin()
	_ensure_energy_bar()
	_ensure_status_controls()

func _ensure_overlay_nodes() -> void:
	if overlay == null:
		overlay = ColorRect.new()
		overlay.name = "Overlay"
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.color = Color(0.0, 0.45, 0.55, 0.18)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.visible = false
		add_child(overlay)

	if generated_overlay == null:
		generated_overlay = TextureRect.new()
		generated_overlay.name = "GeneratedOverlay"
		generated_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		generated_overlay.stretch_mode = TextureRect.STRETCH_SCALE
		generated_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		generated_overlay.modulate = Color(1, 1, 1, 0.34)
		generated_overlay.visible = false
		add_child(generated_overlay)

	if glitch_noise == null:
		glitch_noise = TextureRect.new()
		glitch_noise.name = "GlitchNoise"
		glitch_noise.set_anchors_preset(Control.PRESET_FULL_RECT)
		glitch_noise.stretch_mode = TextureRect.STRETCH_SCALE
		glitch_noise.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glitch_noise.modulate = Color(1, 1, 1, 0.0)
		glitch_noise.visible = false
		add_child(glitch_noise)

func _ensure_reticle_nodes() -> void:
	if generated_reticle == null:
		generated_reticle = TextureRect.new()
		generated_reticle.name = "GeneratedFocusReticle"
		generated_reticle.set_anchors_preset(Control.PRESET_TOP_LEFT)
		generated_reticle.custom_minimum_size = EAGLE_EYE_RETICLE_SIZE
		generated_reticle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		generated_reticle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		generated_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		generated_reticle.modulate = Color(1, 1, 1, 0.0)
		generated_reticle.visible = false
		add_child(generated_reticle)

	if focus_reticle == null:
		focus_reticle = ColorRect.new()
		focus_reticle.name = "FallbackFocusReticle"
		focus_reticle.color = Color(0.0, 0.95, 0.95, 0.16)
		focus_reticle.custom_minimum_size = Vector2(180, 2)
		focus_reticle.set_anchors_preset(Control.PRESET_TOP_LEFT)
		focus_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		focus_reticle.visible = false
		add_child(focus_reticle)

func _ensure_activation_cutin() -> void:
	if activation_cutin == null:
		activation_cutin = TextureRect.new()
		activation_cutin.name = "ActivationCutin"
		activation_cutin.set_anchors_preset(Control.PRESET_FULL_RECT)
		activation_cutin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		activation_cutin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		activation_cutin.modulate = Color(1, 1, 1, 0.0)
		activation_cutin.visible = false
		add_child(activation_cutin)

func _ensure_energy_bar() -> void:
	if energy_bar == null:
		energy_bar = Control.new()
		energy_bar.name = "EnergyBar"
		energy_bar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		energy_bar.offset_left = EAGLE_EYE_ENERGY_BAR_RECT.position.x
		energy_bar.offset_top = EAGLE_EYE_ENERGY_BAR_RECT.position.y
		energy_bar.offset_right = EAGLE_EYE_ENERGY_BAR_RECT.position.x + EAGLE_EYE_ENERGY_BAR_RECT.size.x
		energy_bar.offset_bottom = EAGLE_EYE_ENERGY_BAR_RECT.position.y + EAGLE_EYE_ENERGY_BAR_RECT.size.y
		energy_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		energy_bar.visible = false
		add_child(energy_bar)
		_build_energy_texture_widget()

func _ensure_status_controls() -> void:
	if scan_label == null:
		scan_label = Label.new()
		scan_label.name = "ScanLabel"
		scan_label.text = "[ EAGLE EYE ACTIVE ]"
		scan_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		scan_label.offset_left = 24
		scan_label.offset_top = 18
		scan_label.offset_right = 420
		scan_label.offset_bottom = 48
		scan_label.add_theme_color_override("font_color", Color(0.0, 0.95, 0.95, 0.9))
		scan_label.add_theme_font_size_override("font_size", 14)
		scan_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		scan_label.visible = false
		add_child(scan_label)

	if toggle_button == null:
		toggle_button = Button.new()
		toggle_button.name = "ToggleButton"
		toggle_button.text = "鷹眼"
		toggle_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		toggle_button.offset_left = -116
		toggle_button.offset_right = -24
		toggle_button.offset_top = 48
		toggle_button.offset_bottom = 92
		toggle_button.visible = InputManager.is_mobile
		toggle_button.pressed.connect(toggle)
		add_child(toggle_button)

func _build_energy_texture_widget() -> void:
	if energy_bar == null:
		return

	energy_bar_texture = TextureRect.new()
	energy_bar_texture.name = "TechEnergyTexture"
	energy_bar_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	energy_bar_texture.stretch_mode = TextureRect.STRETCH_SCALE
	energy_bar_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	energy_bar_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	energy_bar_texture.texture = _load_energy_state_texture(EAGLE_EYE_SEGMENT_COUNT)
	_current_energy_state = EAGLE_EYE_SEGMENT_COUNT
	energy_bar.add_child(energy_bar_texture)

func _get_energy_state_path(state: int) -> String:
	return "%s/energy_bar_%02d.png" % [ENERGY_BAR_STATE_DIR, clampi(state, 1, EAGLE_EYE_SEGMENT_COUNT)]

func _get_energy_state_index(energy: float, max_energy: float) -> int:
	if max_energy <= 0.0:
		return 1
	var ratio := clampf(energy / max_energy, 0.0, 1.0)
	if ratio >= 1.0:
		return EAGLE_EYE_SEGMENT_COUNT
	return clampi(floori(ratio * EAGLE_EYE_SEGMENT_COUNT), 1, EAGLE_EYE_SEGMENT_COUNT)

func _load_energy_state_texture(state: int) -> Texture2D:
	return _load_runtime_texture(_get_energy_state_path(state))

func _set_energy_state_texture(state: int) -> void:
	if energy_bar_texture == null:
		return
	state = clampi(state, 1, EAGLE_EYE_SEGMENT_COUNT)
	if state == _current_energy_state and energy_bar_texture.texture != null:
		return
	var texture := _load_energy_state_texture(state)
	if texture:
		energy_bar_texture.texture = texture
		_current_energy_state = state

func _setup_shader_fallback() -> void:
	if overlay == null:
		return

	var shader := load("res://assets/shaders/scanline.gdshader") as Shader
	if shader:
		_shader_material = ShaderMaterial.new()
		_shader_material.shader = shader
		overlay.material = _shader_material

func _setup_generated_overlay() -> void:
	if generated_overlay == null:
		return

	var texture := _load_runtime_texture(EAGLE_EYE_OVERLAY_PATH)
	if texture:
		generated_overlay.texture = texture
	var reticle_texture := _load_runtime_texture(EAGLE_EYE_RETICLE_PATH)
	if reticle_texture:
		generated_reticle.texture = reticle_texture
	var glitch_texture := _load_runtime_texture(EAGLE_EYE_GLITCH_NOISE_PATH)
	if glitch_texture:
		glitch_noise.texture = glitch_texture
	var cutin_texture := _load_runtime_texture(EAGLE_EYE_ACTIVATION_CUTIN_PATH)
	if cutin_texture:
		activation_cutin.texture = cutin_texture

func _load_runtime_texture(res_path: String) -> Texture2D:
	if not FileAccess.file_exists(res_path):
		return null

	if res_path.get_extension().to_lower() == "png":
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(res_path))
		if error == OK:
			return ImageTexture.create_from_image(image)

	if ResourceLoader.exists(res_path):
		return load(res_path) as Texture2D

	return null

func _process(delta: float) -> void:
	if GameManager.eagle_eye_active:
		_drain_timer += delta
		while _drain_timer >= EAGLE_EYE_DRAIN_INTERVAL:
			_drain_timer -= EAGLE_EYE_DRAIN_INTERVAL
			GameManager.consume_eagle_eye_energy_amount(GameManager.eagle_eye_max_energy / float(EAGLE_EYE_SEGMENT_COUNT))
		if GameManager.eagle_eye_energy <= 0:
			_deactivate()
		_update_reticle_motion(delta)
		_scan_hotspots_under_reticle(delta)
	else:
		_drain_timer = 0.0
		GameManager.recharge_eagle_eye(delta)

	_animate_energy_widget(delta)
	_update_energy_bar()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_eagle_eye"):
		toggle()
		return

	if not GameManager.eagle_eye_active:
		return

	if event is InputEventMouseMotion:
		_set_reticle_target(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_reticle_target(event.position)
	elif event is InputEventScreenDrag:
		_set_reticle_target(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_set_reticle_target(event.position)

func toggle() -> void:
	if GameManager.eagle_eye_active:
		_deactivate()
	else:
		_activate()

func _activate() -> void:
	if GameManager.eagle_eye_energy <= GameManager.eagle_eye_max_energy / float(EAGLE_EYE_SEGMENT_COUNT):
		_flash_energy_bar()
		return

	if GameManager.activate_eagle_eye():
		_drain_timer = 0.0
		_center_reticle_if_needed()
		_set_overlay_visible(true)
		scan_label.text = "[ EAGLE EYE ACTIVE ]"

		overlay.modulate.a = 0.0
		if generated_overlay:
			generated_overlay.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
		if generated_overlay and generated_overlay.texture:
			tween.parallel().tween_property(generated_overlay, "modulate:a", 0.34, 0.3)
		if generated_reticle and generated_reticle.texture:
			tween.parallel().tween_property(generated_reticle, "modulate:a", 0.9, 0.3)
		_play_activation_cutin()

		eagle_eye_activated.emit()

func _deactivate() -> void:
	GameManager.deactivate_eagle_eye()
	_drain_timer = 0.0
	_last_focused_hotspot = null

	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.2)
	if generated_overlay:
		tween.parallel().tween_property(generated_overlay, "modulate:a", 0.0, 0.2)
	if generated_reticle:
		tween.parallel().tween_property(generated_reticle, "modulate:a", 0.0, 0.2)
	if glitch_noise:
		tween.parallel().tween_property(glitch_noise, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		_set_overlay_visible(false)
	)

	eagle_eye_deactivated.emit()

func _set_overlay_visible(is_visible: bool) -> void:
	if overlay:
		overlay.visible = is_visible
	if generated_overlay:
		generated_overlay.visible = is_visible and generated_overlay.texture != null
	if generated_reticle:
		generated_reticle.visible = is_visible and generated_reticle.texture != null
	if focus_reticle:
		focus_reticle.visible = is_visible and (not generated_reticle or generated_reticle.texture == null)
	if glitch_noise:
		glitch_noise.visible = false
	if activation_cutin:
		activation_cutin.visible = false
	if scan_label:
		scan_label.visible = is_visible
	if energy_bar:
		energy_bar.visible = is_visible
	if is_visible:
		_apply_reticle_position(_reticle_position)

func trigger_glitch_pulse() -> void:
	var was_active := GameManager.eagle_eye_active
	if AudioManager and AudioManager.has_method("play_optional_sfx"):
		AudioManager.play_optional_sfx(EAGLE_EYE_GLITCH_STING_SFX)
	_set_overlay_visible(true)
	if scan_label:
		scan_label.text = "[ ECHO SIGNATURE DESYNC ]"
	if generated_overlay and generated_overlay.texture:
		generated_overlay.modulate.a = maxf(generated_overlay.modulate.a, 0.34)
	if generated_reticle and generated_reticle.texture:
		generated_reticle.modulate.a = maxf(generated_reticle.modulate.a, 0.9)

	if not glitch_noise or glitch_noise.texture == null:
		_flash_energy_bar()
		if not was_active:
			var fallback_tween := create_tween()
			fallback_tween.tween_interval(0.35)
			fallback_tween.tween_callback(func(): _set_overlay_visible(false))
		return

	glitch_noise.visible = true
	glitch_noise.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(glitch_noise, "modulate:a", 0.58, 0.08)
	tween.tween_property(glitch_noise, "modulate:a", 0.16, 0.14)
	tween.tween_property(glitch_noise, "modulate:a", 0.42, 0.08)
	tween.tween_property(glitch_noise, "modulate:a", 0.0, 0.18)
	tween.tween_callback(func():
		if scan_label:
			scan_label.text = "[ EAGLE EYE ACTIVE ]"
		if not was_active:
			_set_overlay_visible(false)
	)

func _play_activation_cutin() -> void:
	if not activation_cutin or activation_cutin.texture == null:
		return
	activation_cutin.visible = true
	activation_cutin.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(activation_cutin, "modulate:a", 0.68, 0.08)
	tween.tween_property(activation_cutin, "modulate:a", 0.0, 0.22)
	tween.tween_callback(func():
		if activation_cutin:
			activation_cutin.visible = false
	)

func _center_reticle_if_needed() -> void:
	if _reticle_initialized:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	_reticle_position = viewport_size * 0.5
	_reticle_target_position = _reticle_position
	_reticle_initialized = true
	_apply_reticle_position(_reticle_position)

func _set_reticle_target(screen_position: Vector2) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_reticle_target_position = Vector2(
		clampf(screen_position.x, EAGLE_EYE_RETICLE_SIZE.x * 0.5, viewport_size.x - EAGLE_EYE_RETICLE_SIZE.x * 0.5),
		clampf(screen_position.y, EAGLE_EYE_RETICLE_SIZE.y * 0.5, viewport_size.y - EAGLE_EYE_RETICLE_SIZE.y * 0.5)
	)
	if not _reticle_initialized:
		_reticle_position = _reticle_target_position
		_reticle_initialized = true
	_apply_reticle_position(_reticle_position)

func _update_reticle_motion(delta: float) -> void:
	if not _reticle_initialized:
		_center_reticle_if_needed()
		return
	_reticle_position = _reticle_position.lerp(_reticle_target_position, clampf(delta * 12.0, 0.0, 1.0))
	_apply_reticle_position(_reticle_position)

func _apply_reticle_position(screen_position: Vector2) -> void:
	if generated_reticle:
		generated_reticle.offset_left = screen_position.x - EAGLE_EYE_RETICLE_SIZE.x * 0.5
		generated_reticle.offset_right = screen_position.x + EAGLE_EYE_RETICLE_SIZE.x * 0.5
		generated_reticle.offset_top = screen_position.y - EAGLE_EYE_RETICLE_SIZE.y * 0.5
		generated_reticle.offset_bottom = screen_position.y + EAGLE_EYE_RETICLE_SIZE.y * 0.5
	if focus_reticle:
		focus_reticle.offset_left = screen_position.x - 90
		focus_reticle.offset_right = screen_position.x + 90
		focus_reticle.offset_top = screen_position.y - 1
		focus_reticle.offset_bottom = screen_position.y + 1

func _scan_hotspots_under_reticle(delta: float) -> void:
	_reticle_scan_timer += delta
	if _reticle_scan_timer < 0.18:
		return
	_reticle_scan_timer = 0.0

	var closest_hotspot: Node = null
	var closest_distance := EAGLE_EYE_RETICLE_SCAN_RADIUS
	for hotspot in get_tree().get_nodes_in_group("hotspots"):
		if not (hotspot is Node2D):
			continue
		if not (hotspot as Node2D).visible:
			continue
		var hotspot_screen_pos := (hotspot as Node2D).get_global_transform_with_canvas().origin
		var distance := hotspot_screen_pos.distance_to(_reticle_position)
		if distance <= closest_distance:
			closest_distance = distance
			closest_hotspot = hotspot

	if closest_hotspot != null and closest_hotspot != _last_focused_hotspot:
		_last_focused_hotspot = closest_hotspot
		_pulse_scanned_hotspot(closest_hotspot)

func _pulse_scanned_hotspot(hotspot: Node) -> void:
	var sprite := hotspot.get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "modulate", Color(0.0, 0.95, 0.95, 1.0), 0.08)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.22)

func _update_energy_bar() -> void:
	if energy_bar:
		energy_changed.emit(GameManager.eagle_eye_energy, GameManager.eagle_eye_max_energy)
		_set_energy_state_texture(_get_energy_state_index(GameManager.eagle_eye_energy, GameManager.eagle_eye_max_energy))

func _animate_energy_widget(delta: float) -> void:
	if not energy_bar:
		return
	_energy_pulse_phase += delta * 5.0
	var state := _get_energy_state_index(GameManager.eagle_eye_energy, GameManager.eagle_eye_max_energy)
	var low_energy_pulse := 0.0
	if GameManager.eagle_eye_active and state <= 3:
		low_energy_pulse = 0.06 + sin(_energy_pulse_phase) * 0.04
	energy_bar.modulate = Color(1.0, 1.0, 1.0, clampf(0.94 + sin(_energy_pulse_phase * 0.5) * 0.04 + low_energy_pulse, 0.88, 1.0))

func _flash_energy_bar() -> void:
	if energy_bar:
		energy_bar.visible = true
		var tween := create_tween()
		tween.tween_property(energy_bar, "modulate", Color(1.0, 0.22, 0.12), 0.15)
		tween.tween_property(energy_bar, "modulate", Color.WHITE, 0.15)
		tween.tween_property(energy_bar, "modulate", Color(1.0, 0.22, 0.12), 0.15)
		tween.tween_property(energy_bar, "modulate", Color.WHITE, 0.15)
		tween.tween_callback(func():
			if not GameManager.eagle_eye_active:
				energy_bar.visible = false
		)

## Get biometric reading for interrogation (returns dict with lie indicators)
func get_biometric_reading(character_id: String, pressure: int) -> Dictionary:
	var readings := {
		"heart_rate": randi_range(70, 120),
		"stress_level": clamp(pressure + randi_range(-10, 10), 0, 100),
		"micro_expression": "neutral",
		"lying_probability": 0.0
	}

	match character_id:
		"ajie":
			if pressure > 60:
				readings["micro_expression"] = "nervous"
				readings["lying_probability"] = 0.7
				readings["heart_rate"] = randi_range(100, 130)
		"ghost":
			if pressure > 40:
				readings["micro_expression"] = "hostile"
				readings["lying_probability"] = 0.5
		"dr_xiao":
			readings["lying_probability"] = 0.3
			if pressure > 80:
				readings["micro_expression"] = "cracking"
				readings["lying_probability"] = 0.8

	return readings
