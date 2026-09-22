extends Control
class_name EvidenceBoard

const RuntimeAssetsScript = preload("res://scripts/core/runtime_assets.gd")
## EvidenceBoard - Full-screen evidence board where players connect clues to form deductions.
## Native scrolling and explicit buttons support mouse, keyboard and touch.

signal deduction_made(from_id: String, to_id: String, is_correct: bool)
signal board_closed

const UI_SPRITE_DIR := "res://assets/sprites/ui"
const MEMORY_SIGNATURE_REVEAL_SFX := "res://assets/audio/sfx/memory_signature_reveal.ogg"

# Node references (resolved in _ready, not @onready, for safe dynamic instantiation)
var board_container: Control = null
var cards_layer: Control = null
var scroll_container: ScrollContainer = null
var feedback_label: RichTextLabel = null
var progress_label: Label = null
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
	"eleven_pm_call_log": "rejected_missing_person_report",
	"rejected_missing_person_report": "street_camera_gap",
	"masked_client_receipt": "stranger_photo",
	"clinic_eye_warning_log": "masked_client_receipt",
	"old_city_queue_ticket": "rejected_missing_person_report",
	"clinic_anonymous_case_note": "clinic_eye_warning_log",
	"abyss_surveillance_delay_log": "masked_client_receipt",
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
	"eleven_pm_call_log:rejected_missing_person_report": "deduced_police_suppression",
	"rejected_missing_person_report:street_camera_gap": "deduced_city_system_suppression",
	"masked_client_receipt:stranger_photo": "deduced_ch1_black_market_route",
	"clinic_eye_warning_log:masked_client_receipt": "deduced_ch1_three_evidence_gate",
	"old_city_queue_ticket:rejected_missing_person_report": "deduced_old_city_system_delay",
	"clinic_anonymous_case_note:clinic_eye_warning_log": "deduced_clinic_pattern_warning",
	"abyss_surveillance_delay_log:masked_client_receipt": "deduced_abyss_paid_silence",
}

var _cards: Dictionary = {}  # {evidence_id: CardNode}
var _connecting_from: String = ""
var _reading_eye_active := false

func _process(_delta: float) -> void:
	if not visible or _reading_eye_active == GameManager.eagle_eye_active:
		return
	_reading_eye_active = GameManager.eagle_eye_active
	for evidence_id in _cards:
		var card: PanelContainer = _cards[evidence_id]
		var reading := card.find_child("ReadingText", true, false) as Label
		if reading:
			card.tooltip_text = _get_evidence_reading_text(evidence_id)
			reading.text = _summarize_reading(card.tooltip_text)
			reading.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6) if _reading_eye_active else Color(0.55, 0.62, 0.68))

func _ready() -> void:
	visible = false

	# Resolve nodes safely — supports both .tscn and dynamic instantiation
	scroll_container = get_node_or_null("Scroll") as ScrollContainer
	board_container = get_node_or_null("Scroll/BoardContainer")
	if board_container:
		cards_layer = board_container.get_node_or_null("CardsLayer")

	var ui := get_node_or_null("UI")
	if ui:
		feedback_label = ui.get_node_or_null("Feedback") as RichTextLabel
		progress_label = ui.get_node_or_null("ProgressText") as Label
		progress_bar = ui.get_node_or_null("ProgressBar") as ProgressBar
		close_button = ui.get_node_or_null("CloseButton") as Button

	if close_button:
		close_button.pressed.connect(_on_close)

	resized.connect(_on_board_resized)

func open() -> void:
	visible = true
	GameManager.set_state(GameManager.GameState.EVIDENCE_BOARD)
	_connecting_from = ""
	_refresh_cards()
	_update_progress()
	_set_feedback(_get_ajie_summary())

func close() -> void:
	visible = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	board_closed.emit()

func _refresh_cards() -> void:
	_reading_eye_active = GameManager.eagle_eye_active
	if not cards_layer:
		return

	# Clear existing cards
	for child in cards_layer.get_children():
		cards_layer.remove_child(child)
		child.queue_free()
	_cards.clear()

	# Create cards for collected evidence
	var evidence_list := GameManager.collected_evidence
	var cols := clampi(int((size.x - 48.0) / 240.0), 1, 5)
	var card_width := floorf((size.x - 80.0 - (cols - 1) * 20.0) / cols)
	var card_size := Vector2(card_width, 240)
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

	var rows := int(ceil(float(evidence_list.size()) / cols))
	board_container.custom_minimum_size = Vector2(0, padding + rows * (card_size.y + padding))

func _create_card(evidence_id: String, card_size: Vector2) -> PanelContainer:
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.custom_minimum_size = card_size
	card.size = card_size
	card.add_theme_stylebox_override("panel", _create_card_style(Color(0.0, 0.7, 0.7)))

	# Evidence name label
	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = _load_evidence_icon(evidence_id)
	icon.custom_minimum_size = Vector2(34, 34)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vbox.add_child(icon)

	var name_label := Label.new()
	name_label.text = _get_evidence_display_name(evidence_id)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.0, 0.9, 0.9))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)

	var reading_text := _get_evidence_reading_text(evidence_id)
	if reading_text != "":
		card.tooltip_text = reading_text
		var reading_label := Label.new()
		reading_label.name = "ReadingText"
		reading_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		reading_label.text = _summarize_reading(reading_text)
		reading_label.add_theme_font_size_override("font_size", 14)
		reading_label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6) if GameManager.eagle_eye_active else Color(0.55, 0.62, 0.68))
		reading_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(reading_label)

	card.add_child(vbox)
	card.set_meta("evidence_id", evidence_id)

	var select := Button.new()
	select.name = "SelectEvidence"
	select.mouse_filter = Control.MOUSE_FILTER_PASS
	select.text = "選取"
	select.custom_minimum_size.y = 44
	select.pressed.connect(_handle_connection.bind(evidence_id))
	vbox.add_child(select)

	return card

func _on_board_resized() -> void:
	if visible:
		_connecting_from = ""
		_refresh_cards()
		_set_feedback(_get_ajie_summary())

func _set_feedback(message: String) -> void:
	if feedback_label:
		feedback_label.text = message

func _get_ajie_summary() -> String:
	if not GameManager.get_dialogue_flag("eye_ajie_receipt_scanned"):
		return "先選一項證據閱讀，再選另一項核對關係。尚未支持的猜測可以繼續查，不會扣分。"
	if GameManager.get_dialogue_flag("ajie_terminal_verified"):
		var state := "已修正" if GameManager.decisions.get("ajie_hypothesis_status", "") == "revised" else "已支持"
		return state + "｜收據＋終端佇列：七分鐘是交易重送，不能指認人影。" + ("後室監控另有三分鐘清場紀錄，兩者不能混用。" if GameManager.has_evidence("abyss_surveillance_delay_log") else "監控是否被處理，仍需查後室原件。")
	var topics := {"terminal": "終端是否延遲", "witness": "阿傑是否記錯時間", "monitor": "是否與監控清場有關", "none": "七分鐘時間差的原因"}
	return "待驗證｜%s。收據只有時間差，可回酒吧核對終端重送紀錄。" % topics.get(GameManager.decisions.get("ajie_hypothesis", "none"), "七分鐘時間差的原因")

func _handle_connection(evidence_id: String) -> void:
	if not GameManager.has_evidence(evidence_id):
		return
	if _connecting_from == "":
		# Start connection
		_connecting_from = evidence_id
		if evidence_id in _cards:
			var card: PanelContainer = _cards[evidence_id]
			card.modulate = Color(1.0, 0.75, 0.9)
			(card.find_child("SelectEvidence", true, false) as Button).text = "已選取（再按取消）"
		_set_feedback("已選取：" + _get_evidence_display_name(evidence_id) + "。" + _get_evidence_reading_text(evidence_id))
	else:
		# Complete connection
		var from_id := _connecting_from
		_connecting_from = ""

		if from_id == evidence_id:
			_refresh_card_style(from_id)
			_set_feedback(_get_ajie_summary())
			return

		# Check if connection is valid
		var is_correct := _check_connection(from_id, evidence_id)
		var added := GameManager.add_evidence_connection(from_id, evidence_id, is_correct)

		# Visual feedback
		_refresh_card_style(from_id)

		var pair_text := _get_evidence_display_name(from_id) + " ↔ " + _get_evidence_display_name(evidence_id)
		if is_correct:
			_set_feedback(("已支持：" if added else "已核對過，不重複計數：") + pair_text + "。" + _get_connection_conclusion(from_id, evidence_id))
			# Green flash
			var deduction_flag := _get_connection_flag(from_id, evidence_id)
			if deduction_flag != "":
				GameManager.set_dialogue_flag(deduction_flag)
			if AudioManager and AudioManager.has_method("play_optional_sfx"):
				AudioManager.play_optional_sfx(MEMORY_SIGNATURE_REVEAL_SFX)
			_flash_connection(from_id, evidence_id, Color(0.0, 1.0, 0.3))
		else:
			_set_feedback("尚未支持：" + pair_text + "。現有資料不足以連結，換一組來源或繼續詢問；不扣分。")
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

func _get_connection_conclusion(from_id: String, to_id: String) -> String:
	var conclusions := {
		"commission_letter": "委託對象的姓名與工作身份一致，可追查浩然的工作室。",
		"abyss_receipt": "消費與照片指向同次包廂會面，仍無法辨識面具下的人。",
		"data_chip": "晶片可與設備使用紀錄對讀，需再查記憶提取的用途。",
		"family_memory_clip": "家庭片段與被改造的播放器連起浩然保護家人的動機。",
		"original_backup_hint": "備份座標能對讀加密留言；保管與使用私人內容仍須分開。",
		"broken_memory_player": "播放器與提取設備使用同類協定，可以追問義眼的呼叫來源。",
		"kai_eye_glitch_log": "義眼異常與晶片簽章相符，可解讀共同的回聲線索。",
		"eleven_pm_call_log": "一聲來電與被退回的報案連起失聯、求救與拒絕受理。",
		"rejected_missing_person_report": "報案與監控空窗互相印證調查受到阻礙。",
		"masked_client_receipt": "包廂付款紀錄與照片指向同場交易，可追查黑市入口。",
		"clinic_eye_warning_log": "診所警告與包廂格式連起義眼、浩然失蹤與黑市交易。",
		"old_city_queue_ticket": "等候號碼與退件紀錄核對了美玲報案被拖延的經過。",
		"clinic_anonymous_case_note": "匿名病歷支持義眼污染並非單一個案，不能直接認作浩然。",
		"abyss_surveillance_delay_log": "監控維護與包廂交易指向付費清場；三分鐘不是收據重送的七分鐘。",
		"echo_symbol": "回聲標記與倉庫位置相互指引。",
		"memory_sample": "樣本與受害者名單可核對來源，不等於使用私人記憶的同意。",
		"hao_ran_diary": "日記與帳本連起浩然的工作與交易經過。",
		"zhengtek_memo": "內部備忘錄與通訊頻率顯示企業和回聲網路的聯繫。",
		"overwrite_report": "覆寫研究與資金流向共同顯示企業支持，仍須另查操作責任。",
		"echo_ai_log": "迴響紀錄能與凱的記憶碎片互核，支持繼續追查自己的過去。"
	}
	var source := from_id if valid_connections.get(from_id) == to_id else to_id
	return conclusions.get(source, "兩份紀錄有可核對的關係，仍須保留各自來源與未證實的部分。")

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
		card.modulate = Color.WHITE
		(card.find_child("SelectEvidence", true, false) as Button).text = "選取"

func _create_card_style(border_color: Color) -> StyleBox:
	var texture := RuntimeAssetsScript.load_texture("%s/evidence_card.png" % UI_SPRITE_DIR)
	if texture:
		var generated_style := StyleBoxTexture.new()
		generated_style.texture = texture
		generated_style.region_rect = Rect2(32, 32, 448, 304)
		generated_style.set_texture_margin_all(48)
		generated_style.set_content_margin_all(32)
		generated_style.set_content_margin(SIDE_TOP, 36)
		generated_style.set_content_margin(SIDE_BOTTOM, 12)
		return generated_style

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.15, 0.9)
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	return style

func _update_progress() -> void:
	var total_valid := 0
	for from_id in valid_connections:
		if GameManager.has_evidence(from_id) and GameManager.has_evidence(valid_connections[from_id]):
			total_valid += 1
	var correct_count := 0
	for connection in GameManager.evidence_connections:
		if connection.get("correct", false) and _check_connection(connection.from, connection.to):
			correct_count += 1
	if progress_bar:
		progress_bar.max_value = maxi(1, total_valid)
		progress_bar.value = correct_count
	if progress_label:
		progress_label.text = "現有證據配對：%d / %d" % [correct_count, total_valid]
		progress_label.tooltip_text = "分母只計已取得證據可組成的配對；取得新證據後可能增加。"

func _on_close() -> void:
	close()

func _get_evidence_display_name(evidence_id: String) -> String:
	var EvidenceDataScript: GDScript = load("res://scripts/data/evidence_data.gd")
	return str(EvidenceDataScript.get_evidence(evidence_id).get("name", evidence_id))

func _get_evidence_reading_text(evidence_id: String) -> String:
	var EvidenceDataScript: GDScript = load("res://scripts/data/evidence_data.gd")
	var evidence: Dictionary = EvidenceDataScript.get_evidence(evidence_id)
	if evidence.is_empty():
		return ""
	if GameManager.eagle_eye_active and evidence.get("eye_reading", "") != "":
		return "鷹眼讀取：" + evidence.get("eye_reading", "")
	return evidence.get("description", "")

func _summarize_reading(reading_text: String) -> String:
	var limit := 30
	if reading_text.length() <= limit:
		return reading_text
	return reading_text.substr(0, limit - 1) + "..."

func _load_evidence_icon(evidence_id: String) -> Texture2D:
	var EvidenceDataScript: GDScript = load("res://scripts/data/evidence_data.gd")
	var evidence: Dictionary = EvidenceDataScript.get_evidence(evidence_id)
	var fallback_icon_id: String = evidence.get("icon", evidence_id)
	var preferred_icon_id: String = evidence.get("preferred_icon", "")
	if preferred_icon_id != "":
		var preferred_icon_path := "res://assets/sprites/items/%s.png" % preferred_icon_id
		var preferred_icon := RuntimeAssetsScript.load_texture(preferred_icon_path)
		if preferred_icon:
			return preferred_icon

	var icon_path := "res://assets/sprites/items/%s.png" % fallback_icon_id
	return RuntimeAssetsScript.load_texture(icon_path)
