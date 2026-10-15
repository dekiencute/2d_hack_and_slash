extends SceneTree
## Presentation compatibility, actual camera transforms, UI resize and fallback isolation.
var checks := 0
var failures := 0
var arena
var art

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

func screen_position(node: Node2D) -> Vector2:
	return node.get_global_transform_with_canvas().origin

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("/tmp/stylebreaker-pixel/screenshots")
	check(root.get_texture().get_image().save_png("/tmp/stylebreaker-pixel/screenshots/" + name + ".png") == OK, "capture " + name)

func _run() -> void:
	var mode := root.content_scale_mode
	arena = load("res://pixel_art/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	art = arena.get_node("PixelPresentation")
	await settle()
	check(paused and arena.wave == 0, "pixel scene retains title gate")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://pixel_art/arena.tscn", "F5 starts the approved pixel arena")
	var fallback = load("res://levels/main.tscn").instantiate()
	check(fallback.get_script() == arena.get_script(), "both arenas use the identical combat director")
	check(fallback.get_node("Player").get_script() == arena.player.get_script(), "player controller is unchanged")
	var original: SpriteFrames = fallback.get_node("Player/Sprite").sprite_frames
	var pixel: SpriteFrames = arena.player.sprite.sprite_frames
	check(original != pixel, "pixel textures do not mutate shared fallback SpriteFrames")
	for animation in original.get_animation_names():
		var compatible := original.get_frame_count(animation) == pixel.get_frame_count(animation)
		compatible = compatible and original.get_animation_speed(animation) == pixel.get_animation_speed(animation)
		compatible = compatible and original.get_animation_loop(animation) == pixel.get_animation_loop(animation)
		for i in range(original.get_frame_count(animation)):
			var before := original.get_frame_texture(animation, i) as AtlasTexture
			var after := pixel.get_frame_texture(animation, i) as AtlasTexture
			compatible = compatible and before.region == after.region
			compatible = compatible and before.atlas.resource_path.begins_with("res://resources/original/")
			compatible = compatible and after.atlas.resource_path.begins_with("res://assets/Art/Character/")
			compatible = compatible and original.get_frame_duration(animation, i) == pixel.get_frame_duration(animation, i)
		check(compatible, animation + " keeps every frame region and duration; fallback atlas stays original")
	for path in ["Floor/CollisionShape2D", "LeftWall/CollisionShape2D", "RightWall/CollisionShape2D", "Player/CollisionShape2D", "Player/AttackHitbox/CollisionShape2D"]:
		var a: CollisionShape2D = fallback.get_node(path)
		var b: CollisionShape2D = arena.get_node(path)
		check(a.shape == b.shape and a.transform == b.transform, path + " retains original physics shape and transform")
	check(arena.player.sprite.scale == Vector2(2, 2), "player uses integer 2x source pixels")
	check(arena.player.sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "player uses nearest sampling")
	check(not arena.get_node("Environment").visible and fallback.get_node("Environment").visible, "old environment remains available in fallback")
	check(not art.camera.position_smoothing_enabled and art.camera.zoom.x == roundf(art.camera.zoom.x), "pixel camera has integer zoom and no smoothing")
	check(art.health.value == arena.player.hp and not arena.hud.hp_bar.visible, "pixel HUD starts at authoritative HP")
	arena.player.receive_hit(17.0)
	check(art.health.value == 83.0 and arena.hud.hp_label.text.contains("83"), "damage updates uploaded pixel bar and readable health text")
	check(art.forest.get_node("Ground8/Art").to_global(Vector2(0, 723)).y == 616.0, "authored ground row aligns with unchanged collision floor")
	var far: Sprite2D = art.forest.get_node("Distance2/Art")
	var ground: Sprite2D = art.forest.get_node("Ground8/Art")
	var far_start := screen_position(far)
	var ground_start := screen_position(ground)
	arena.player.position.x = 950.0
	await settle()
	art.camera.force_update_scroll()
	var far_motion := screen_position(far) - far_start
	var ground_motion := screen_position(ground) - ground_start
	check(absf(ground_motion.x) > absf(far_motion.x) and absf(far_motion.x) > 0.0, "actual gameplay camera produces depth without moving ground in world space")
	for path in ["Distance3", "Distance5"]:
		var group = art.forest.get_node(path)
		check(screen_position(group.get_node("Lights")).is_equal_approx(screen_position(group.get_node("Art"))), path + " Lights stay registered during gameplay camera motion")
	# Explicitly exercise window layout while paused, without altering project settings.
	for size in [Vector2i(960, 540), Vector2i(1920, 1080), Vector2i(1280, 720)]:
		root.size = size
		await settle()
		check(art.camera.zoom.x == roundf(art.camera.zoom.x), str(size) + " retains integer zoom")
		check(arena.hud.menu_button.get_global_rect().end.x <= size.x and arena.hud.menu_button.get_global_rect().end.y <= size.y, str(size) + " title button remains visible")
		check(arena.hud.sound_button.get_global_rect().end.x <= size.x and arena.hud.sound_button.get_global_rect().end.y <= size.y, str(size) + " sound button remains visible")
	arena.hud.hide_menu()
	await capture("05-camera-right")
	var enemy = load("res://actors/enemies/dummy_enemy.tscn").instantiate()
	arena.enemies_root.add_child(enemy)
	enemy.position = Vector2(900, 616)
	enemy.configure_for_wave(5, 0)
	await settle()
	check(enemy.has_node("PixelVisual"), "original director's enemy receives optional skin")
	var visual = enemy.get_node("PixelVisual")
	check(enemy.body_visual is Sprite2D and enemy.body_visual.scale == Vector2(2, 2), "original typed enemy visual and integer scale are retained")
	check(visual.bar.max_value == 100 and visual.bar.value == 100, "wave-five health syncs into uploaded enemy bar")
	var original_shape = load("res://actors/enemies/dummy_enemy.tscn").instantiate()
	check(enemy.get_node("CollisionShape2D").shape == original_shape.get_node("CollisionShape2D").shape, "enemy skin leaves physics shape untouched")
	check(enemy.attack_windup == original_shape.attack_windup and enemy.attack_recovery == original_shape.attack_recovery, "enemy visual does not change windup or recovery")
	for target_x in [800.0, 1000.0]:
		arena.player.position.x = target_x
		visual._process(0.0)
		var pivot := Vector2(96 if enemy.body_visual.flip_h else 32, 51)
		check(enemy.body_visual.to_global(pivot).is_equal_approx(enemy.global_position), "enemy facing keeps authored foot pivot at physics origin")
	var hit := AttackData.new()
	hit.damage = 25.0
	enemy.receive_hit(hit, 1.0, arena.player)
	visual._process(0.0)
	check(visual.bar.value == 75.0 and visual.state == "hit", "enemy hit animation and pixel HP reflect existing damage state")
	await capture("06-hit-feedback")
	var config := ConfigFile.new()
	check(config.load("res://export_presets.cfg") == OK, "release configuration loads")
	for section in ["preset.0", "preset.1"]:
		var exclusions: String = config.get_value(section, "exclude_filter")
		check(exclusions.contains("pixel_art/*") and exclusions.contains("assets/Art/*"), section + " keeps license-pending integration out of public exports")
	fallback.free()
	original_shape.free()
	enemy.stop_combat()
	arena.player.set_physics_process(false)
	paused = false
	# Let the original hit-flash timer finish after the paused inspection.
	await create_timer(0.3, true, false, true).timeout
	arena.queue_free()
	await settle()
	check(root.content_scale_mode == mode, "leaving pixel arena restores runtime window scaling")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
