extends Control
class_name EvidenceBoard
## EvidenceBoard - Full-screen evidence board where players connect clues to form deductions.
## Supports mouse drag and touch drag + pinch zoom.

signal deduction_made(from_id: String, to_id: String, is_correct: bool)
signal board_closed

const UI_SPRITE_DIR := "res://assets/sprites/ui"
const MEMORY_SIGNATURE_REVEAL_SFX := "res://assets/audio/sfx/memory_signature_reveal.ogg"

# Node references (resolved in _ready, not @onready, for safe dynamic instantiation)
var board_container: Control = null
var cards_layer: Control = null
var lines_layer: Control = null
var progress_bar: ProgressBar = null
var close_button: Button = null

# Valid deductions - {from_id: to_id} pairs
var valid_connections: Dictionary = {
	# Chapter 1
	"commission_letter": "work_id",
	"abyss_receipt": "stranger_photo",
	"data_chip": "memory_device_log",
	"comm_recording": "dr_chen_schedule",
	"family_memory_clip": "broken_memory_player",
	"original_backup_hint": "hao_ran_encrypted_message",
	"broken_memory_player": "memory_device_log",
	"kai_eye_glitch_log": "data_chip",
	# Chapter 2
	"echo_symbol": "warehouse_map",
	"memory_sample": "victim_list",
	"hao_ran_diary": "trade_ledger",
	"zhengtek_memo": "comm_frequency",
	"rusty_key": "fake_id_chip",
	# Chapter 3
	"overwrite_report": "zhengtek_funding",
	"dr_xiao_journal": "overwritten_profiles",
	"hao_ran_sos": "memory_sample",
	"lab_keycard": "authorization_order",
	"echo_ai_log": "kai_memory_fragment",
	"dr_xiao_comms": "zhengtek_funding",
}

var valid_connection_flags: Dictionary = {
	"family_memory_clip:broken_memory_player": "deduced_hao_ran_family_motive",
	"original_backup_hint:hao_ran_encrypted_message": "deduced_mei_ling_original_backup",
	"broken_memory_player:memory_device_log": "deduced_player_echo_codec",
	"kai_eye_glitch_log:data_chip": "deduced_eye_echo_signature",
}

var _cards: Dictionary = {}  # {evidence_id: CardNode}
var _dragging_card: Control = null
var _drag_offset: Vector2 = Vector2.ZERO
var _connecting_from: String = ""
var _connection_lines: Array = []
var _zoom_level: float = 1.0

func _ready() -> void:
	visible = false

	# Resolve nodes safely — supports both .tscn and dynamic instantiation
	board_container = get_node_or_null("BoardContainer")
	if board_container:
		cards_layer = board_container.get_node_or_null("CardsLayer")
		lines_layer = board_container.get_node_or_null("LinesLayer")

	var ui := get_node_or_null("UI")
	if ui:
		progress_bar = ui.get_node_or_null("ProgressBar") as ProgressBar
		close_button = ui.get_node_or_null("CloseButton") as Button

	if close_button:
		close_button.pressed.connect(_on_close)

	if InputManager:
		InputManager.pinch_zoom.connect(_on_pinch_zoom)

func open() -> void:
	visible = true
	GameManager.set_state(GameManager.GameState.EVIDENCE_BOARD)
	_refresh_cards()
	_update_progress()

func close() -> void:
	visible = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	board_closed.emit()

func _refresh_cards() -> void:
	if not cards_layer:
		return

	# Clear existing cards
	for child in cards_layer.get_children():
		child.queue_free()
	_cards.clear()

	# Create cards for collected evidence
	var evidence_list := GameManager.collected_evidence
	var cols := 4 if not InputManager.is_mobile else 3
	var card_size := Vector2(180, 120) if not InputManager.is_mobile else Vector2(140, 100)
	var padding := 20.0

	for i in range(evidence_list.size()):
		var evidence_id: String = evidence_list[i]
		var card := _create_card(evidence_id, card_size)

		# Grid layout
		var col: int = i % cols
		var row: int = int(i / cols)
		card.position = Vector2(
			padding + col * (card_size.x + padding),
			padding + row * (card_size.y + padding)
		)

		cards_layer.add_child(card)
		_cards[evidence_id] = card

	# Redraw existing connections
	_redraw_connections()

func _create_card(evidence_id: String, card_size: Vector2) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = card_size
	card.size = card_size
	card.add_theme_stylebox_override("panel", _create_card_style(Color(0.0, 0.7, 0.7)))

	# Evidence name label
	var vbox := VBoxContainer.new()
	var icon := TextureRect.new()
	icon.texture = _load_evidence_icon(evidence_id)
	icon.custom_minimum_size = Vector2(42, 42)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vbox.add_child(icon)

	var name_label := Label.new()
	name_label.text = _get_evidence_display_name(evidence_id)
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)

	card.add_child(vbox)
	card.set_meta("evidence_id", evidence_id)

	# Make draggable
	card.gui_input.connect(_on_card_gui_input.bind(card))

	return card

func _on_card_gui_input(event: InputEvent, card: PanelContainer) -> void:
	var evidence_id: String = card.get_meta("evidence_id")

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_dragging_card = card
				_drag_offset = event.position
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				# Right click to start/complete connection
				_handle_connection(evidence_id)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_dragging_card = null

	elif event is InputEventMouseMotion and _dragging_card == card:
		card.position += event.relative

	# Touch support
	elif event is InputEventScreenTouch:
		if event.pressed:
			if event.double_tap:
				_handle_connection(evidence_id)
			else:
				_dragging_card = card
				_drag_offset = event.position - card.global_position
		else:
			_dragging_card = null

	elif event is InputEventScreenDrag and _dragging_card == card:
		card.global_position = event.position - _drag_offset

func _handle_connection(evidence_id: String) -> void:
	if _connecting_from == "":
		# Start connection
		_connecting_from = evidence_id
		if evidence_id in _cards:
			var card: PanelContainer = _cards[evidence_id]
			card.add_theme_stylebox_override("panel", _create_card_style(Color(1.0, 0.0, 0.6)))
	else:
		# Complete connection
		var from_id := _connecting_from
		_connecting_from = ""

		if from_id == evidence_id:
			_refresh_card_style(from_id)
			return

		# Check if connection is valid
		var is_correct := _check_connection(from_id, evidence_id)
		GameManager.add_evidence_connection(from_id, evidence_id, is_correct)

		# Visual feedback
		_add_connection_line(from_id, evidence_id, is_correct)
		_refresh_card_style(from_id)

		if is_correct:
			# Green flash
			var deduction_flag := _get_connection_flag(from_id, evidence_id)
			if deduction_flag != "":
				GameManager.set_dialogue_flag(deduction_flag)
			if AudioManager and AudioManager.has_method("play_optional_sfx"):
				AudioManager.play_optional_sfx(MEMORY_SIGNATURE_REVEAL_SFX)
			_flash_connection(from_id, evidence_id, Color(0.0, 1.0, 0.3))
		else:
			# Red flash then fade
			_flash_connection(from_id, evidence_id, Color(1.0, 0.2, 0.2))

		deduction_made.emit(from_id, evidence_id, is_correct)
		_update_progress()

func _check_connection(from_id: String, to_id: String) -> bool:
	return (valid_connections.get(from_id) == to_id or
			valid_connections.get(to_id) == from_id)

func _get_connection_flag(from_id: String, to_id: String) -> String:
	var direct_key := "%s:%s" % [from_id, to_id]
	var reverse_key := "%s:%s" % [to_id, from_id]
	return valid_connection_flags.get(direct_key, valid_connection_flags.get(reverse_key, ""))

func _add_connection_line(from_id: String, to_id: String, is_correct: bool) -> void:
	_connection_lines.append({
		"from": from_id,
		"to": to_id,
		"correct": is_correct
	})
	if lines_layer:
		lines_layer.queue_redraw()

func _redraw_connections() -> void:
	if lines_layer:
		lines_layer.queue_redraw()

func _flash_connection(from_id: String, to_id: String, color: Color) -> void:
	for card_id in [from_id, to_id]:
		if card_id in _cards:
			var card: PanelContainer = _cards[card_id]
			var tween := create_tween()
			tween.tween_property(card, "modulate", color, 0.2)
			tween.tween_property(card, "modulate", Color.WHITE, 0.3)

func _refresh_card_style(evidence_id: String) -> void:
	if evidence_id in _cards:
		var card: PanelContainer = _cards[evidence_id]
		card.add_theme_stylebox_override("panel", _create_card_style(Color(0.0, 0.7, 0.7)))

func _create_card_style(border_color: Color) -> StyleBox:
	var texture := _load_runtime_texture("%s/evidence_card.png" % UI_SPRITE_DIR)
	if texture:
		var generated_style := StyleBoxTexture.new()
		generated_style.texture = texture
		generated_style.set_texture_margin_all(24)
		generated_style.set_content_margin_all(8)
		return generated_style

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.15, 0.9)
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	return style

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

func _update_progress() -> void:
	var total_valid := valid_connections.size()
	var correct_count: int = 0
	for conn in GameManager.evidence_connections:
		if conn.get("correct", false):
			correct_count += 1
	if progress_bar:
		progress_bar.max_value = total_valid
		progress_bar.value = correct_count

func _on_close() -> void:
	close()

func _on_pinch_zoom(zoom_factor: float, _center: Vector2) -> void:
	if not visible:
		return
	_zoom_level = clamp(_zoom_level * zoom_factor, 0.5, 2.0)
	if board_container:
		board_container.scale = Vector2(_zoom_level, _zoom_level)

func _get_evidence_display_name(evidence_id: String) -> String:
	var names := {
		# Chapter 1
		"commission_letter": "美玲的委託信",
		"work_id": "浩然的工作證",
		"abyss_receipt": "深淵酒吧的收據",
		"data_chip": "加密的數據晶片",
		"stranger_photo": "陌生人的全息照片",
		"memory_device_log": "記憶提取設備使用紀錄",
		"comm_recording": "損壞的通訊錄音",
		"dr_chen_schedule": "Dr. 陳的預約紀錄",
		"family_memory_clip": "家庭記憶片段",
		"hao_ran_drawer_note": "浩然抽屜裡的維修便條",
		"original_backup_hint": "原始記憶備份提示",
		"hao_ran_encrypted_message": "浩然留給美玲的加密留言",
		"broken_memory_player": "損壞的記憶播放器",
		"kai_eye_glitch_log": "凱的鷹眼異常紀錄",
		# Chapter 2
		"echo_symbol": "回聲網路標記符號",
		"memory_sample": "記憶樣本",
		"warehouse_map": "廢棄倉庫位置地圖",
		"hao_ran_diary": "浩然的個人日記",
		"trade_ledger": "交易帳本副本",
		"zhengtek_memo": "正和科技內部備忘錄",
		"victim_list": "受害者名單",
		"comm_frequency": "回聲網路通訊頻率",
		"rusty_key": "生鏽的電子鑰匙",
		"fake_id_chip": "偽造的身份晶片",
		# Chapter 3
		"overwrite_report": "覆寫技術研究報告",
		"zhengtek_funding": "正和科技資金流向",
		"dr_xiao_journal": "蕭博士個人日誌",
		"hao_ran_sos": "浩然的求救訊息",
		"lab_keycard": "實驗室門禁卡",
		"overwritten_profiles": "被覆寫者前後對比",
		"echo_ai_log": "AI迴響對話紀錄",
		"kai_memory_fragment": "凱的記憶碎片",
		"authorization_order": "正和科技授權令",
		"dr_xiao_comms": "蕭博士與高層通訊",
	}
	return names.get(evidence_id, evidence_id)

func _load_evidence_icon(evidence_id: String) -> Texture2D:
	var EvidenceDataScript: GDScript = load("res://scripts/data/evidence_data.gd")
	var evidence: Dictionary = EvidenceDataScript.get_evidence(evidence_id)
	var fallback_icon_id: String = evidence.get("icon", evidence_id)
	var preferred_icon_id: String = evidence.get("preferred_icon", "")
	if preferred_icon_id != "":
		var preferred_icon_path := "res://assets/sprites/items/%s.png" % preferred_icon_id
		var preferred_icon := _load_runtime_texture(preferred_icon_path)
		if preferred_icon:
			return preferred_icon

	var icon_path := "res://assets/sprites/items/%s.png" % fallback_icon_id
	return _load_runtime_texture(icon_path)
