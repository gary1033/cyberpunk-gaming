extends Node2D
## GameScene - Main game scene manager. Loads the first location for the current chapter.

func _ready() -> void:
	var chapter_data := CaseData.get_chapter_data(GameManager.current_chapter)
	var start_loc: String = chapter_data.get("starting_location", "detective_office")
	await SceneManager.change_scene(start_loc)
