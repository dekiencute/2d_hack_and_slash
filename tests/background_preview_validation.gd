extends SceneTree
var checks := 0
var failures := 0
var preview: Node2D

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
	await process_frame
	await process_frame
	await process_frame

func capture(name: String) -> Image:
	if DisplayServer.get_name() == "headless":
		return null
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("/tmp/stylebreaker-background/screenshots")
	check(image.save_png("/tmp/stylebreaker-background/screenshots/" + name + ".png") == OK, "render " + name)
	return image

func screen_position(node: Node2D) -> Vector2:
	return node.get_global_transform_with_canvas().origin

func _run() -> void:
	var packed := load("res://tests/background_preview.tscn") as PackedScene
	check(packed != null, "standalone background scene loads")
	preview = packed.instantiate()
	root.add_child(preview)
	current_scene = preview
	preview.set_physics_process(false)
	preview.reset_camera()
	await settle()
	var layers: Node2D = preview.get_node("Layers")
	check(layers.get_child_count() == 10, "ten independently arranged parallax depth groups")
	var sprites: Array[Sprite2D] = []
	var registered := true
	var reference := Vector2.ZERO
	for layer in layers.get_children():
		check(layer is Parallax2D and layer.repeat_size == Vector2.ZERO, layer.name + " uses bounded Parallax2D without invented tile seams")
		for child in layer.get_children():
			if child is Sprite2D:
				sprites.append(child)
				check(child.texture != null and child.texture.get_size() == Vector2(928, 793), child.texture.resource_path.get_file() + " loads at 928×793")
				check(child.texture.resource_path.begins_with("res://assets/Art/UI/Background/Background layers/"), "sprite uses only an uploaded background PNG")
				if sprites.size() == 1:
					reference = screen_position(child)
				registered = registered and screen_position(child).is_equal_approx(reference)
	check(sprites.size() == 12, "all twelve source PNGs represented without generated textures")
	print("Center layer positions: ", layers.get_node("Distance2").position, " / ", layers.get_node("Foreground9").position)
	check(registered, "all layers share authored pixel registration at centered camera")
	check(preview.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "nearest filtering is local to the preview")
	check(preview.camera.zoom.x == roundf(preview.camera.zoom.x) and preview.camera.zoom.x >= 1, "camera zoom is an integer with no window resampling")
	check(not preview.camera.position_smoothing_enabled, "camera does not introduce smoothing blur")
	for light in [preview.far_lights, preview.near_lights]:
		check(light.texture.get_image().detect_alpha() == Image.ALPHA_BLEND, "Lights texture retains partial alpha")
		check(light.material is CanvasItemMaterial and light.material.blend_mode == CanvasItemMaterial.BLEND_MODE_MIX and light.material.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED, "Lights use authored alpha, unshaded normal blending")
		check(light.position == light.get_parent().get_node("Art").position, "Lights remain registered with their depth group's artwork")
	preview.controls.hide()
	var lit := await capture("01-centered")
	preview.set_lights_visible(false, false)
	await settle()
	check(not preview.far_lights.visible and not preview.near_lights.visible, "both Lights layers toggle off")
	var unlit := await capture("02-lights-off")
	if lit != null and unlit != null:
		check(lit.get_data() != unlit.get_data(), "uploaded Lights change actual rendered pixels")
	preview.set_lights_visible(true, true)
	var far: Sprite2D = layers.get_node("Distance2/Art")
	var near: Sprite2D = layers.get_node("Foreground9/Art")
	var far_start := screen_position(far)
	var near_start := screen_position(near)
	preview.set_camera_offset(Vector2(100, 12))
	await settle()
	var far_motion := screen_position(far) - far_start
	var near_motion := screen_position(near) - near_start
	print("Observed camera test, far motion=", far_motion, ", near motion=", near_motion)
	check(absf(near_motion.x) > absf(far_motion.x) and absf(far_motion.x) > 0, "real camera movement produces distinct near/far parallax")
	for light in [preview.far_lights, preview.near_lights]:
		check(screen_position(light).is_equal_approx(screen_position(light.get_parent().get_node("Art"))), "Lights track artwork after camera movement")
	await capture("03-panned")
	preview.set_parallax_enabled(false)
	check(layers.get_node("Distance2").scroll_scale == Vector2.ONE and layers.get_node("Distance6").scroll_scale == Vector2.ONE, "flat comparison disables relative depth")
	preview.set_parallax_enabled(true)
	check(layers.get_node("Distance2").scroll_scale == Vector2(0.10, 0.08), "authored preview depth factors restore")
	preview.set_camera_offset(Vector2(99999, -99999))
	check(preview.camera.position == Vector2(128, -16), "camera clamps to finite art bounds")
	preview.reset_camera()
	check(preview.camera.position == Vector2.ZERO and not preview.automatic_pan, "reset centers and stops automatic movement")
	preview.set_automatic_pan(true)
	preview._physics_process(1.0)
	check(preview.camera.position != Vector2.ZERO, "automatic camera test moves through the preview")
	preview.reset_camera()
	var event := InputEventKey.new()
	event.physical_keycode = KEY_D
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	preview._physics_process(0.25)
	check(preview.camera.position.x > 0 and not preview.automatic_pan, "manual keyboard movement controls the camera")
	event = InputEventKey.new()
	event.physical_keycode = KEY_D
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	preview.select_backdrop(1)
	check(layers.get_node("Backdrop0/Base").visible and not layers.get_node("Backdrop1/Base").visible, "opaque base zero is inspectable without stacking opaque backgrounds")
	preview.select_backdrop(0)
	check(not layers.get_node("Backdrop0/Base").visible and layers.get_node("Backdrop1/Base").visible, "default opaque base restores")
	check(get_nodes_in_group("player").is_empty() and get_nodes_in_group("enemies").is_empty(), "preview instantiates no combat actors")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://pixel_art/arena.tscn", "approved pixel arena remains the startup scene")
	preview.queue_free()
	await process_frame
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
