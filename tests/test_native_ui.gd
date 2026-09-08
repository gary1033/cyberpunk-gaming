extends SceneTree
## GPU smoke check for the actual root window and menu-to-game flow.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	change_scene_to_file("res://scenes/main_menu.tscn")
	await create_timer(4.0).timeout
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://docs/verification/ui_audit_menu.png")
	print("NATIVE_MENU_RENDERED")
	if "--interactive" in OS.get_cmdline_user_args():
		return
	current_scene._on_new_game()
	await create_timer(5.0).timeout
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://docs/verification/ui_audit_opening.png")
	print("NATIVE_OPENING_RENDERED")
	root.get_node("AudioManager").stop_bgm(false)
	await create_timer(0.5).timeout
	quit()
