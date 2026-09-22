extends Node
## SaveManager - Cross-platform save/load system using user:// path.

const SAVE_DIR := "user://saves/"
const SAVE_EXTENSION := ".sav"
const MAX_SAVE_SLOTS := 3

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(slot: int, error: String)

var reading_settings := {"font_step": 0, "speed": 1}
const READING_SETTINGS_PATH := "user://reading.cfg"

func set_reading_setting(key: String, value: int) -> void:
	if key not in reading_settings:
		return
	reading_settings[key] = clampi(value, 0, 2 if key == "font_step" else 3)
	var config := ConfigFile.new()
	for setting in reading_settings:
		config.set_value("reading", setting, reading_settings[setting])
	var error := config.save(READING_SETTINGS_PATH)
	if error != OK:
		push_warning("Unable to save reading settings: " + str(error))

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(READING_SETTINGS_PATH) == OK:
		for key in reading_settings:
			var value: Variant = config.get_value("reading", key, reading_settings[key])
			if value is int:
				reading_settings[key] = clampi(value, 0, 2 if key == "font_step" else 3)
	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(slot: int) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING or SceneManager.is_transitioning():
		save_failed.emit(slot, "請等目前對話或操作結束後再存檔。")
		return
	var save_data := {
		"version": 1,
		"timestamp": Time.get_datetime_string_from_system(),
		"game_data": GameManager.get_save_data()
	}

	var save_path := _get_save_path(slot)
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		save_failed.emit(slot, "Cannot open file for writing")
		return

	file.store_var(save_data)
	file.close()
	save_completed.emit(slot)

func load_game(slot: int) -> bool:
	var save_path := _get_save_path(slot)
	if not FileAccess.file_exists(save_path):
		return false

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return false

	var save_data: Variant = file.get_var()
	file.close()

	if save_data is Dictionary and save_data.has("game_data"):
		GameManager.load_save_data(save_data["game_data"])
		load_completed.emit(slot)
		return true

	return false

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_get_save_path(slot))

func get_save_info(slot: int) -> Dictionary:
	var save_path := _get_save_path(slot)
	if not FileAccess.file_exists(save_path):
		return {}

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return {}

	var save_data: Variant = file.get_var()
	file.close()

	if save_data is Dictionary:
		return {
			"timestamp": save_data.get("timestamp", "Unknown"),
			"chapter": save_data.get("game_data", {}).get("current_chapter", 1),
			"location": save_data.get("game_data", {}).get("current_location", "")
		}

	return {}

func delete_save(slot: int) -> void:
	var save_path := _get_save_path(slot)
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_slot_%d%s" % [slot, SAVE_EXTENSION]
