extends CanvasLayer
## AugmentedVision (Eagle Eye) - Toggleable enhanced vision mode.
## Builds its own runtime UI so every location can mount it safely.

signal eagle_eye_activated
signal eagle_eye_deactivated
signal energy_changed(energy: float, max_energy: float)

const EAGLE_EYE_OVERLAY_PATH := "res://assets/sprites/ui/eagle_eye_scan_overlay_ch1.png"

var overlay: ColorRect = null
var generated_overlay: TextureRect = null
var energy_bar: ProgressBar = null
var toggle_button: Button = null
var scan_label: Label = null
var focus_reticle: ColorRect = null

var _shader_material: ShaderMaterial = null

func _ready() -> void:
	layer = 50
	_ensure_runtime_nodes()
	_setup_shader_fallback()
	_setup_generated_overlay()
	_update_energy_bar()

func _ensure_runtime_nodes() -> void:
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

	if focus_reticle == null:
		focus_reticle = ColorRect.new()
		focus_reticle.name = "FallbackFocusReticle"
		focus_reticle.color = Color(0.0, 0.95, 0.95, 0.16)
		focus_reticle.custom_minimum_size = Vector2(180, 2)
		focus_reticle.set_anchors_preset(Control.PRESET_CENTER)
		focus_reticle.offset_left = -90
		focus_reticle.offset_right = 90
		focus_reticle.offset_top = -1
		focus_reticle.offset_bottom = 1
		focus_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		focus_reticle.visible = false
		add_child(focus_reticle)

	if energy_bar == null:
		energy_bar = ProgressBar.new()
		energy_bar.name = "EnergyBar"
		energy_bar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		energy_bar.offset_left = -260
		energy_bar.offset_right = -24
		energy_bar.offset_top = 18
		energy_bar.offset_bottom = 38
		energy_bar.show_percentage = false
		energy_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(energy_bar)

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
		GameManager.consume_eagle_eye_energy(delta)
		if GameManager.eagle_eye_energy <= 0:
			_deactivate()
	else:
		GameManager.recharge_eagle_eye(delta)

	_update_energy_bar()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_eagle_eye"):
		toggle()

func toggle() -> void:
	if GameManager.eagle_eye_active:
		_deactivate()
	else:
		_activate()

func _activate() -> void:
	if GameManager.eagle_eye_energy <= 5.0:
		_flash_energy_bar()
		return

	if GameManager.activate_eagle_eye():
		_set_overlay_visible(true)
		scan_label.text = "[ EAGLE EYE ACTIVE ]"

		overlay.modulate.a = 0.0
		if generated_overlay:
			generated_overlay.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
		if generated_overlay and generated_overlay.texture:
			tween.parallel().tween_property(generated_overlay, "modulate:a", 0.34, 0.3)

		eagle_eye_activated.emit()

func _deactivate() -> void:
	GameManager.deactivate_eagle_eye()

	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.2)
	if generated_overlay:
		tween.parallel().tween_property(generated_overlay, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		_set_overlay_visible(false)
	)

	eagle_eye_deactivated.emit()

func _set_overlay_visible(is_visible: bool) -> void:
	if overlay:
		overlay.visible = is_visible
	if generated_overlay:
		generated_overlay.visible = is_visible and generated_overlay.texture != null
	if focus_reticle:
		focus_reticle.visible = is_visible
	if scan_label:
		scan_label.visible = is_visible

func _update_energy_bar() -> void:
	if energy_bar:
		energy_bar.max_value = GameManager.eagle_eye_max_energy
		energy_bar.value = GameManager.eagle_eye_energy
		energy_changed.emit(GameManager.eagle_eye_energy, GameManager.eagle_eye_max_energy)

		var ratio := GameManager.eagle_eye_energy / GameManager.eagle_eye_max_energy
		if ratio > 0.5:
			energy_bar.modulate = Color(0.0, 0.9, 0.9)
		elif ratio > 0.2:
			energy_bar.modulate = Color(0.9, 0.9, 0.0)
		else:
			energy_bar.modulate = Color(0.9, 0.2, 0.2)

func _flash_energy_bar() -> void:
	if energy_bar:
		var tween := create_tween()
		tween.tween_property(energy_bar, "modulate", Color(1.0, 0.0, 0.0), 0.15)
		tween.tween_property(energy_bar, "modulate", Color.WHITE, 0.15)
		tween.tween_property(energy_bar, "modulate", Color(1.0, 0.0, 0.0), 0.15)
		tween.tween_property(energy_bar, "modulate", Color.WHITE, 0.15)

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
