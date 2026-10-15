extends SceneTree
## Standalone pixel presentation checked against numeric pre-cleanup combat contracts.
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

func settle() -> void:
	for i in range(3):
		await process_frame

func _run() -> void:
	var mode := root.content_scale_mode
	var contract = JSON.parse_string(FileAccess.get_file_as_string("res://tests/combat_presentation_contract.json"))
	var packed := load("res://pixel_art/arena.tscn") as PackedScene
	check(packed.get_state().get_node_instance(0) == null, "arena has an independent native root")
	var arena = packed.instantiate()
	root.add_child(arena)
	current_scene = arena
	await settle()
	var camera: Camera2D = arena.get_node("PixelCamera")
	var forest: Node2D = arena.get_node("Forest")
	check(paused and arena.wave == 0, "standalone arena retains title gate")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://pixel_art/arena.tscn", "startup is the standalone pixel arena")
	var frames: SpriteFrames = arena.player.sprite.sprite_frames
	for name in contract.sprite_frames:
		var expected = contract.sprite_frames[name]
		var valid: bool = frames.get_frame_count(name) == expected.frames.size() and frames.get_animation_speed(name) == expected.speed and frames.get_animation_loop(name) == expected.loop
		for i in range(frames.get_frame_count(name)):
			var texture := frames.get_frame_texture(name, i) as AtlasTexture
			valid = valid and var_to_str(texture.region) == expected.frames[i].region and frames.get_frame_duration(name, i) == expected.frames[i].duration
			valid = valid and texture.atlas.resource_path.begins_with("res://assets/Art/Character/")
		check(valid, name + " preserves frame selection, duration, loop and speed using uploaded PNGs")
	var ap: AnimationPlayer = arena.player.get_node("AnimationPlayer")
	for name in contract.animations:
		var a: Animation = ap.get_animation(name)
		var expected = contract.animations[name]
		var valid: bool = is_equal_approx(a.length, float(expected.length)) and a.loop_mode == expected.loop and a.get_track_count() == expected.tracks.size()
		for i in range(a.get_track_count()):
			var track = expected.tracks[i]
			valid = valid and str(a.track_get_path(i)) == track.path and a.track_get_type(i) == track.type and a.track_get_key_count(i) == track.keys.size()
			for k in range(a.track_get_key_count(i)):
				valid = valid and is_equal_approx(a.track_get_key_time(i, k), float(track.keys[k].time)) and var_to_str(a.track_get_key_value(i, k)) == track.keys[k].value
		check(valid, name + " preserves every AnimationPlayer track and key timing")
	for path in contract.shapes:
		var node: CollisionShape2D = arena.get_node(path)
		var expected = contract.shapes[path]
		var valid: bool = var_to_str(node.position) == expected.position
		for property in expected.properties:
			valid = valid and var_to_str(node.shape.get(property)) == expected.properties[property]
		check(valid, path + " preserves collision geometry and transform")
	check(arena.player.sprite.scale == Vector2(2, 2) and arena.player.sprite.position == Vector2(0, -48), "native player has integer scale and foot pivot")
	check(arena.player.sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "native player uses nearest filtering")
	check(arena.hud.hp_bar is TextureProgressBar and arena.hud.hp_bar.visible, "HUD natively uses uploaded pixel health bar")
	arena.player.receive_hit(17.0)
	check(arena.hud.hp_bar.value == 83.0 and arena.hud.hp_label.text.contains("83"), "damage updates pixel bar and health text")
	check(forest.get_node("Ground8/Art").to_global(Vector2(0, 723)).y == 616.0, "uploaded ground aligns with unchanged physical floor")
	var far: Sprite2D = forest.get_node("Distance2/Art")
	var near: Sprite2D = forest.get_node("Ground8/Art")
	var far_start := far.get_global_transform_with_canvas().origin
	var near_start := near.get_global_transform_with_canvas().origin
	arena.player.position.x = 950
	await settle()
	camera.force_update_scroll()
	var far_motion := far.get_global_transform_with_canvas().origin - far_start
	var near_motion := near.get_global_transform_with_canvas().origin - near_start
	check(absf(near_motion.x) > absf(far_motion.x) and absf(far_motion.x) > 0, "actual camera movement retains parallax depth")
	for path in ["Distance3", "Distance5"]:
		var group = forest.get_node(path)
		var light: Sprite2D = group.get_node("Lights")
		check(light.get_global_transform_with_canvas().origin.is_equal_approx(group.get_node("Art").get_global_transform_with_canvas().origin), path + " Lights remain registered")
		check(light.material.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED and light.material.blend_mode == CanvasItemMaterial.BLEND_MODE_MIX, path + " Lights preserve authored alpha blending")
	for size in [Vector2i(960, 540), Vector2i(1920, 1080), Vector2i(1280, 720)]:
		root.size = size
		await settle()
		check(camera.zoom.x == roundf(camera.zoom.x) and not camera.position_smoothing_enabled, str(size) + " uses unsmoothed integer camera zoom")
		check(arena.hud.menu_button.get_global_rect().end.x <= size.x and arena.hud.menu_button.get_global_rect().end.y <= size.y, str(size) + " menu button stays visible")
		check(arena.hud.sound_button.get_global_rect().end.x <= size.x, str(size) + " sound button stays visible")
	var enemy = load("res://actors/enemies/dummy_enemy.tscn").instantiate()
	arena.enemies_root.add_child(enemy)
	enemy.position = Vector2(900, 616)
	enemy.configure_for_wave(5, 0)
	await settle()
	var visual = enemy.get_node("PixelVisual")
	check(enemy.body_visual.texture.atlas.resource_path.begins_with("res://assets/Art/Enemies/"), "enemy is pixel art from instantiation")
	check(visual.bar == enemy.hp_bar and visual.bar.max_value == 100, "enemy uses its native pixel health bar")
	check(enemy.attack_windup == 0.38 and enemy.attack_recovery == 0.28, "enemy attack timings remain unchanged")
	for x in [800.0, 1000.0]:
		arena.player.position.x = x
		visual._process(0)
		var pivot := Vector2(96 if enemy.body_visual.flip_h else 32, 51)
		check(enemy.body_visual.to_global(pivot).is_equal_approx(enemy.global_position), "enemy facing preserves foot pivot")
	enemy._begin_attack()
	check(enemy.hp_label.text.contains("STRIKE"), "functional text warning replaces illustrative telegraph")
	enemy.stop_combat()
	arena.player.set_physics_process(false)
	paused = false
	await create_timer(0.7, true, false, true).timeout
	arena.queue_free()
	await settle()
	check(root.content_scale_mode == mode, "camera restores runtime window scaling on exit")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
