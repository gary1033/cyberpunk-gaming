extends CanvasLayer
## AugmentedVision (Eagle Eye) - Toggleable enhanced vision mode with scanline effect.
## Reveals hidden clues and provides biometric readings during interrogation.

signal eagle_eye_activated
signal eagle_eye_deactivated
signal energy_changed(energy: float, max_energy: float)

@onready var overlay: ColorRect = $Overlay
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var toggle_button: Button = $ToggleButton  # Mobile toggle
@onready var scan_label: Label = $ScanLabel

var _shader_material: ShaderMaterial = null

func _ready() -> void:
	layer = 50
	overlay.visible = false
	scan_label.visible = false

	# Mobile toggle button visibility
	toggle_button.visible = InputManager.is_mobile
	toggle_button.pressed.connect(toggle)

	_setup_overlay()
	_update_energy_bar()

func _setup_overlay() -> void:
	# Scanline shader overlay
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.4, 0.4, 0.15)  # Slight cyan tint
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Apply scanline shader if available
	var shader := load("res://assets/shaders/scanline.gdshader") as Shader
	if shader:
		_shader_material = ShaderMaterial.new()
		_shader_material.shader = shader
		overlay.material = _shader_material

func _process(delta: float) -> void:
	if GameManager.eagle_eye_active:
		GameManager.consume_eagle_eye_energy(delta)
		if GameManager.eagle_eye_energy <= 0:
			_deactivate()
	else:
		GameManager.recharge_eagle_eye(delta)

	_update_energy_bar()

func _unhandled_input(event: InputEvent) -> void:
	# Desktop: E key to toggle
	if event.is_action_pressed("toggle_eagle_eye"):
		toggle()

func toggle() -> void:
	if GameManager.eagle_eye_active:
		_deactivate()
	else:
		_activate()

func _activate() -> void:
	if GameManager.eagle_eye_energy <= 5.0:
		# Not enough energy - flash the bar red
		_flash_energy_bar()
		return

	if GameManager.activate_eagle_eye():
		overlay.visible = true
		scan_label.visible = true
		scan_label.text = "[ EAGLE EYE ACTIVE ]"

		# Animate activation
		overlay.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(overlay, "modulate:a", 1.0, 0.3)

		eagle_eye_activated.emit()

func _deactivate() -> void:
	GameManager.deactivate_eagle_eye()

	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		overlay.visible = false
		scan_label.visible = false
	)

	eagle_eye_deactivated.emit()

func _update_energy_bar() -> void:
	if energy_bar:
		energy_bar.max_value = GameManager.eagle_eye_max_energy
		energy_bar.value = GameManager.eagle_eye_energy
		energy_changed.emit(GameManager.eagle_eye_energy, GameManager.eagle_eye_max_energy)

		# Color based on energy level
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
	# Simulated biometric data based on character and pressure
	var readings := {
		"heart_rate": randi_range(70, 120),
		"stress_level": clamp(pressure + randi_range(-10, 10), 0, 100),
		"micro_expression": "neutral",
		"lying_probability": 0.0
	}

	# Each character has different tells
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
			# Dr. Xiao is calm and hard to read
			readings["lying_probability"] = 0.3
			if pressure > 80:
				readings["micro_expression"] = "cracking"
				readings["lying_probability"] = 0.8

	return readings
