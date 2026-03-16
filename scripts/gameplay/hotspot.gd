extends Area2D
## Hotspot - Base class for interactive objects in investigation scenes.
## Supports mouse hover highlighting and touch-friendly interaction.

signal interacted
signal examined

@export var hotspot_name: String = ""
@export var description: String = ""
@export var interaction_type: InteractionType = InteractionType.EXAMINE
@export var evidence_id: String = ""  # If set, collecting this hotspot gives evidence
@export var requires_eagle_eye: bool = false  # Only visible in eagle eye mode
@export var dialogue_data: Array = []  # Optional dialogue to trigger
@export var one_time: bool = false  # Can only be interacted with once
@export var action_point_cost: int = 1

enum InteractionType { EXAMINE, COLLECT, TALK, EXIT }

var _is_hovered: bool = false
var _is_interacted: bool = false
var _original_modulate: Color = Color.WHITE
var _highlight_color: Color = Color(0.0, 0.9, 0.9, 1.0)  # Cyan neon

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var label: Label = $Label if has_node("Label") else null
@onready var collision: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

func _ready() -> void:
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Set up label
	if label:
		label.text = hotspot_name
		label.visible = false

	# Handle eagle eye visibility
	if requires_eagle_eye:
		visible = false
		GameManager.game_state_changed.connect(_on_game_state_changed)

	# Ensure minimum touch target size on mobile
	_adjust_collision_for_touch()

func _adjust_collision_for_touch() -> void:
	if not InputManager.is_mobile or collision == null:
		return

	var shape := collision.shape
	if shape is RectangleShape2D:
		var min_size := InputManager.get_min_touch_target_size()
		if shape.size.x < min_size.x:
			shape.size.x = min_size.x
		if shape.size.y < min_size.y:
			shape.size.y = min_size.y

func _on_mouse_entered() -> void:
	if _is_interacted and one_time:
		return
	_is_hovered = true

	# Highlight effect
	if sprite:
		_original_modulate = sprite.modulate
		sprite.modulate = _highlight_color

	# Show name label on desktop
	if not InputManager.is_mobile and label:
		label.visible = true

func _on_mouse_exited() -> void:
	_is_hovered = false
	if sprite:
		sprite.modulate = _original_modulate
	if label:
		label.visible = false

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if _is_interacted and one_time:
		return

	var clicked := false

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked = true
	elif event is InputEventScreenTouch and event.pressed:
		clicked = true

	if clicked:
		interact()

func interact() -> void:
	if _is_interacted and one_time:
		return

	# Check action points
	if action_point_cost > 0:
		if not GameManager.spend_action_points(action_point_cost):
			return

	match interaction_type:
		InteractionType.EXAMINE:
			examined.emit()
			if dialogue_data.size() > 0:
				_start_dialogue()
		InteractionType.COLLECT:
			_collect()
		InteractionType.TALK:
			if dialogue_data.size() > 0:
				_start_dialogue()
		InteractionType.EXIT:
			interacted.emit()

	if one_time:
		_is_interacted = true
		if sprite:
			sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)

func _collect() -> void:
	if evidence_id != "":
		GameManager.collect_evidence(evidence_id)
	interacted.emit()

	# Visual feedback
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): visible = false)

func _start_dialogue() -> void:
	# Find the dialogue system in the scene tree
	var dialogue_system := get_tree().get_first_node_in_group("dialogue_system")
	if dialogue_system and dialogue_system.has_method("start_dialogue"):
		dialogue_system.start_dialogue(dialogue_data)

func _on_game_state_changed(_state: String) -> void:
	if requires_eagle_eye:
		visible = GameManager.eagle_eye_active

## Pulse all hotspots in scene (for mobile hint button)
static func pulse_all_hotspots(scene_tree: SceneTree) -> void:
	var hotspots := scene_tree.get_nodes_in_group("hotspots")
	for hotspot in hotspots:
		if hotspot is Hotspot and hotspot.visible:
			var hs: Hotspot = hotspot
			if hs.sprite:
				var tween := hs.create_tween()
				tween.tween_property(hs.sprite, "modulate", Color(0.0, 0.9, 0.9), 0.3)
				tween.tween_property(hs.sprite, "modulate", Color.WHITE, 0.3)
				tween.tween_property(hs.sprite, "modulate", Color(0.0, 0.9, 0.9), 0.3)
				tween.tween_property(hs.sprite, "modulate", Color.WHITE, 0.3)

class_name Hotspot
