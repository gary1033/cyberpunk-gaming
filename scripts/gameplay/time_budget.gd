extends Control
## TimeBudget - Displays and manages action points per chapter.

@onready var ap_label: Label = $APLabel
@onready var ap_bar: ProgressBar = $APBar
@onready var warning_label: Label = $WarningLabel

func _ready() -> void:
	GameManager.action_points_changed.connect(_on_ap_changed)
	warning_label.visible = false
	_update_display()

func _update_display() -> void:
	if ap_label:
		ap_label.text = "行動點: %d / %d" % [GameManager.action_points, GameManager.max_action_points]
	if ap_bar:
		ap_bar.max_value = GameManager.max_action_points
		ap_bar.value = GameManager.action_points

		var ratio := float(GameManager.action_points) / float(GameManager.max_action_points)
		if ratio > 0.5:
			ap_bar.modulate = Color(0.0, 0.9, 0.9)
		elif ratio > 0.25:
			ap_bar.modulate = Color(0.9, 0.6, 0.0)
		else:
			ap_bar.modulate = Color(0.9, 0.2, 0.2)

func _on_ap_changed(remaining: int) -> void:
	_update_display()

	# Warning when low
	if remaining <= 5 and remaining > 0:
		_show_warning("行動點即將耗盡！")
	elif remaining <= 0:
		_show_warning("行動點已耗盡，即將進入下一章...")

func _show_warning(text: String) -> void:
	if warning_label:
		warning_label.text = text
		warning_label.visible = true
		warning_label.modulate.a = 0.0

		var tween := create_tween()
		tween.tween_property(warning_label, "modulate:a", 1.0, 0.3)
		tween.tween_interval(2.0)
		tween.tween_property(warning_label, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func(): warning_label.visible = false)
