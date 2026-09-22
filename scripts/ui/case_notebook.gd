extends CanvasLayer
## Read-only notebook: opening it never replays dialogue effects.

var initial_tab := 0
var _previous_state: int

func _ready() -> void:
	layer = 110
	add_to_group("reading_panel")
	_previous_state = GameManager.current_state
	GameManager.set_state(GameManager.GameState.PAUSED)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.04, 0.97)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 24)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var close_button := Button.new()
	close_button.text = "返回遊戲（Esc）"
	close_button.custom_minimum_size.y = 44
	close_button.pressed.connect(queue_free)
	column.add_child(close_button)
	var tabs := TabContainer.new()
	tabs.name = "NotebookTabs"
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(tabs)
	var history: Array[String] = []
	for entry in GameManager.dialogue_history:
		history.append(str(entry.speaker) + "\n" + str(entry.text))
	_add_text_tab(tabs, "對話回看", "\n\n".join(history) if not history.is_empty() else "尚無已讀對話。舊存檔會從這次遊玩開始記錄。")
	_add_text_tab(tabs, "案件摘要", GameManager.get_case_summary())
	var settings := VBoxContainer.new()
	settings.name = "閱讀設定"
	settings.add_theme_constant_override("separation", 16)
	tabs.add_child(settings)
	var note := Label.new()
	note.text = "設定自動保存；字級與速度從下一段對話套用。"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings.add_child(note)
	_add_option(settings, "字級", ["標準", "較大", "最大"], int(SaveManager.reading_settings.font_step), func(index: int): SaveManager.set_reading_setting("font_step", index))
	_add_option(settings, "打字速度", ["慢", "標準", "快", "立即顯示"], int(SaveManager.reading_settings.speed), func(index: int): SaveManager.set_reading_setting("speed", index))
	tabs.current_tab = clampi(initial_tab, 0, 2)
	close_button.grab_focus()

func _add_text_tab(tabs: TabContainer, title: String, text: String) -> void:
	var label := RichTextLabel.new()
	label.name = title
	label.bbcode_enabled = false
	label.text = text
	label.selection_enabled = true
	label.add_theme_font_size_override("normal_font_size", 22 + int(SaveManager.reading_settings.font_step) * 2)
	label.add_theme_constant_override("line_separation", 8)
	tabs.add_child(label)

func _add_option(parent: Control, title: String, options: Array, selected: int, callback: Callable) -> void:
	var label := Label.new()
	label.text = title
	parent.add_child(label)
	var button := OptionButton.new()
	button.custom_minimum_size.y = 44
	for option in options:
		button.add_item(option)
	button.selected = selected
	button.item_selected.connect(callback)
	parent.add_child(button)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()

func _exit_tree() -> void:
	GameManager.set_state(_previous_state)
