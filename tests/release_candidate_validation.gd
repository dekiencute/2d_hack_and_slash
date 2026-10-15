extends SceneTree
## External check of the actual embedded Windows PCK. Does not execute Windows code.
var checks := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(value: bool, description: String) -> void:
	checks += 1
	if value:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func inventory(directory: String, files: Array[Dictionary]) -> void:
	var access := DirAccess.open(directory)
	if access == null:
		return
	for name in access.get_files():
		var path := directory.path_join(name)
		files.append({"path": path, "bytes": FileAccess.get_file_as_bytes(path).size(), "sha256": FileAccess.get_sha256(path)})
	for name in access.get_directories():
		inventory(directory.path_join(name), files)

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Supply absolute pack expectations JSON and output inventory JSON after --")
		quit(1)
		return
	var spec = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	check(OS.has_feature("private_qa") == bool(spec.private_qa), "export has the expected private QA feature marker")
	var main: String = ProjectSettings.get_setting("application/run/main_scene")
	check(main == "res://pixel_art/arena.tscn", "embedded Windows pack starts the pixel arena")
	check(ProjectSettings.get_setting("application/config/name") == "Stylebreaker", "exported game title is Stylebreaker")
	check(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "export retains nearest filtering")
	check(ProjectSettings.get_setting("rendering/2d/snap/snap_2d_transforms_to_pixel"), "export retains pixel transform snapping")
	for path in spec.expected_assets:
		check(ResourceLoader.exists(path), "required asset included: " + path)
	var absent := true
	for path in spec.forbidden_assets + spec.forbidden_paths:
		absent = absent and not ResourceLoader.exists(path) and not FileAccess.file_exists(path)
	check(absent, "unused uploaded options, authoring files and development previews are excluded")
	var packed := load(main) as PackedScene
	check(packed != null, "startup scene dependencies load from embedded pack")
	if packed == null:
		quit(1)
		return
	var arena = packed.instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	await process_frame
	check(paused and arena.wave == 0 and arena.hud.menu_title.text == "STYLEBREAKER", "export reaches real title gate")
	check(arena.has_node("PixelPresentation/Forest") and arena.has_node("PixelPresentation/PixelCamera"), "export creates shared forest and integer camera")
	check(arena.get_node("PixelPresentation").forest.get_child_count() == 10, "export retains all ten forest depth groups")
	var frames: SpriteFrames = arena.player.sprite.sprite_frames
	var player_textures := true
	for animation in frames.get_animation_names():
		for i in range(frames.get_frame_count(animation)):
			var texture := frames.get_frame_texture(animation, i) as AtlasTexture
			player_textures = player_textures and texture != null and texture.atlas.resource_path.begins_with("res://assets/Art/Character/")
	check(player_textures, "export actually uses uploaded player atlases")
	check(ResourceLoader.exists("res://levels/main.tscn"), "previous arena remains available as fallback")
	var keys := {"move_left": KEY_A, "move_right": KEY_D, "jump": KEY_SPACE, "dash": KEY_SHIFT, "light_attack": KEY_J, "heavy_attack": KEY_K, "reset": KEY_R, "pause": KEY_ESCAPE, "mute": KEY_M, "fullscreen": KEY_F11, "ui_accept": KEY_ENTER}
	for action in keys:
		var found := false
		for event in InputMap.action_get_events(action):
			found = found or (event is InputEventKey and (event.physical_keycode == keys[action] or event.keycode == keys[action]))
		check(found, action + " keyboard binding")
	var buttons := {"jump": JOY_BUTTON_A, "dash": JOY_BUTTON_B, "light_attack": JOY_BUTTON_X, "heavy_attack": JOY_BUTTON_Y, "pause": JOY_BUTTON_START, "reset": JOY_BUTTON_BACK, "ui_accept": JOY_BUTTON_A}
	for action in buttons:
		var found := false
		for event in InputMap.action_get_events(action):
			found = found or (event is InputEventJoypadButton and event.button_index == buttons[action])
		check(found, action + " controller binding")
	for action in ["move_left", "move_right"]:
		var found := false
		for event in InputMap.action_get_events(action):
			found = found or (event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_X and event.axis_value == (-1.0 if action == "move_left" else 1.0))
		check(found, action + " controller axis")
	var files: Array[Dictionary] = []
	inventory("res://", files)
	var out := FileAccess.open(args[1], FileAccess.WRITE)
	check(out != null, "write complete embedded-pack file inventory")
	if out:
		out.store_string(JSON.stringify({"files": files, "expected_media": spec.expected_assets, "public_release_approved": false}, "\t"))
		out.close()
	paused = false
	arena.queue_free()
	await process_frame
	await process_frame
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
