extends SceneTree
## Validates the isolated browser, every uploaded PNG and every preview region.
var checks := 0
var failures := 0
var preview: Control

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("/tmp/stylebreaker-art-preview/screenshots")
	check(root.get_texture().get_image().save_png("/tmp/stylebreaker-art-preview/screenshots/" + name + ".png") == OK, "render " + name)

func _run() -> void:
	var scene := load("res://preview/art_preview.tscn") as PackedScene
	check(scene != null, "standalone preview scene loads")
	preview = scene.instantiate()
	root.add_child(preview)
	current_scene = preview
	await process_frame
	check(preview.entries.size() == 54, "catalog has 19 character, 8 enemy, 19 UI and 8 source entries")
	check(preview.catalog.files.size() == 86, "inventory covers all 86 uploaded files")
	check(preview.catalog.failures.is_empty(), "no missing import sources or invalid character grids")
	check(get_nodes_in_group("player").is_empty() and get_nodes_in_group("enemies").is_empty() and get_nodes_in_group("hitstop").is_empty(), "preview instantiates no gameplay actors/services")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://pixel_art/arena.tscn", "main scene is the approved pixel arena")
	check(preview.canvas.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "preview canvas explicitly uses nearest filtering")
	var unique: Dictionary = {}
	var regions := 0
	var mismatch_count := 0
	for entry in preview.entries:
		preview.select_entry(entry)
		if entry.frames.is_empty():
			check(preview.current_texture == null and preview.displayed_region().size == Vector2i.ZERO, "source is metadata-only: " + entry.name)
			continue
		var texture: Texture2D = preview.current_texture
		var valid := texture != null
		if valid:
			unique[entry.path] = true
			valid = texture.get_width() == int(entry.dimensions[0]) and texture.get_height() == int(entry.dimensions[1])
			for index in range(entry.frames.size()):
				preview.frame_index = index
				var region: Rect2i = preview.displayed_region()
				valid = valid and region.size.x > 0 and region.size.y > 0 and region.position.x >= 0 and region.position.y >= 0 and region.end.x <= texture.get_width() and region.end.y <= texture.get_height()
				regions += 1
		check(valid, "%s / %s: texture dimensions and all regions valid" % [entry.category, entry.name])
		if entry.technical_status.begins_with("Source/export"):
			mismatch_count += 1
	check(unique.size() == 39 and preview.load_errors.is_empty(), "all 39 PNG textures load without missing resources")
	check(mismatch_count == 2, "enemy AttackCombo and Death source/export mismatches are flagged")
	print("Inspected preview regions: ", regions)
	preview.category.select(0)
	preview.search.text = "Run"
	preview._refilter()
	check(preview.visible_entries.size() == 1 and preview.selected.name == "Run", "character search selects Run")
	preview.playing = true
	preview.frame_index = 0
	preview._process(0.14)
	check(preview.frame_index == 1, "playback advances at configured inspection FPS")
	preview.step_frame(1)
	check(not preview.playing and preview.frame_index == 2, "frame stepping pauses playback")
	preview.frame_slider.value = 5
	check(not preview.playing and preview.frame_index == 5, "slider scrubs to exact frame")
	preview.loop.button_pressed = false
	preview.playing = true
	preview.frame_index = 7
	preview._process(0.25)
	check(not preview.playing and preview.frame_index == 7, "non-looping playback stops at the final frame")
	preview.asset_list.grab_focus()
	var space_key := InputEventKey.new()
	space_key.physical_keycode = KEY_SPACE
	space_key.pressed = true
	Input.parse_input_event(space_key)
	Input.flush_buffered_events()
	check(preview.playing, "Space toggles playback even with asset-list focus")
	space_key = InputEventKey.new()
	space_key.physical_keycode = KEY_SPACE
	space_key.pressed = false
	Input.parse_input_event(space_key)
	Input.flush_buffered_events()
	preview.playing = false
	preview.mode.select(1)
	preview._refresh_canvas()
	check(preview.displayed_region() == Rect2i(0, 0, 640, 48), "whole-sheet mode preserves full source dimensions")
	preview.zoom.value = 3
	check(preview.canvas.integer_zoom == 3 and preview.canvas.custom_minimum_size.x == 640 * 3 + 64, "integer zoom sizes the inspection canvas without resampling files")
	preview.mode.select(0)
	preview.zoom.value = 6
	preview._refresh_canvas()
	await capture("01-character-run")
	preview.search.text = ""
	preview.category.select(1)
	preview._refilter()
	check(preview.visible_entries.size() == 8, "all eight enemy rows are available")
	preview.select_entry(preview.visible_entries.filter(func(entry: Dictionary) -> bool: return entry.name == "AttackCombo")[0])
	check(preview.selected.frames_count == 7 and preview.selected.source_tag.count == 8, "AttackCombo previews seven existing PNG cells without inventing the missing source frame")
	preview.mode.select(1)
	preview.zoom.value = 1
	preview._refresh_canvas()
	await capture("02-enemy-sheet")
	preview.category.select(2)
	preview._refilter()
	check(preview.visible_entries.size() == 19, "all nineteen UI images are available")
	var ui_entry = preview.visible_entries.filter(func(entry: Dictionary) -> bool: return entry.name == "Pixel1_Healthbar_0003_pixel1_healthbarcomplete")[0]
	preview.select_entry(ui_entry)
	preview.mode.select(2)
	preview.zoom.value = 6
	preview._refresh_canvas()
	check(preview.displayed_region() == Rect2i(6, 14, 83, 11), "UI alpha view crops only the display, at measured bounds")
	check(preview.current_texture.get_size() == Vector2(130, 89), "UI source texture stays unchanged when cropped for display")
	await capture("03-ui-alpha-bounds")
	preview.category.select(3)
	preview._refilter()
	check(preview.visible_entries.size() == 8 and preview.current_texture == null, "source/reference category clears the last texture")
	preview.search.text = "no-such-upload"
	preview._refilter()
	check(preview.selected.is_empty() and preview.current_texture == null and not preview.playing, "empty search clears stale image/playback state")
	var config := ConfigFile.new()
	check(config.load("res://export_presets.cfg") == OK, "export configuration loads")
	var excluded := true
	for preset in ["preset.0", "preset.1"]:
		var filters: String = config.get_value(preset, "exclude_filter", "")
		excluded = excluded and filters.contains("preview/*") and filters.contains("assets/Art/*")
	check(excluded, "release presets exclude preview and license-unverified uploads")
	preview.queue_free()
	await process_frame
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
