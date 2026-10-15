extends SceneTree
## Synthetic physical joypad events exercise mappings and UI; no hardware claim.
var checks := 0
var failures := 0
var moves: Array[StringName] = []

func _initialize() -> void:
	_run.call_deferred()

func check(value: bool, description: String) -> void:
	checks += 1
	if value:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func delay(seconds: float) -> void:
	await create_timer(seconds, true, false, true).timeout

func button(index: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = index
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await delay(0.04)
	event = InputEventJoypadButton.new()
	event.button_index = index
	event.pressed = false
	Input.parse_input_event(event)
	await delay(0.02)

func _run() -> void:
	var arena = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	await process_frame
	arena.hud.menu_button.grab_focus()
	await button(JOY_BUTTON_A)
	check(arena.started and not paused, "controller A starts from focused title button")
	await delay(2.5)
	var enemies := get_nodes_in_group("enemies")
	check(enemies.size() == 2, "controller-started run reaches first wave")
	if enemies.size() != 2:
		paused = false
		arena.queue_free()
		await delay(0.2)
		quit(1)
		return
	for enemy in enemies:
		enemy.stop_combat()
	var player = arena.player
	player.attack_started.connect(func(data: AttackData) -> void: moves.append(data.move_id))
	var start_x: float = player.position.x
	var axis := InputEventJoypadMotion.new()
	axis.axis = JOY_AXIS_LEFT_X
	axis.axis_value = 1.0
	Input.parse_input_event(axis)
	await delay(0.15)
	axis = InputEventJoypadMotion.new()
	axis.axis = JOY_AXIS_LEFT_X
	axis.axis_value = 0.0
	Input.parse_input_event(axis)
	check(player.position.x > start_x + 8.0, "left-stick event moves the player")
	await button(JOY_BUTTON_A)
	await button(JOY_BUTTON_A)
	check(player.jumps_used == 2 and player.velocity.y < 0.0, "controller A double jump reaches airborne state")
	await button(JOY_BUTTON_B)
	var hp: float = player.hp
	player.receive_hit(20.0)
	check(player.dash_left > 0.0 and player.hp == hp, "controller B activates invulnerable dash")
	await delay(1.0)
	await button(JOY_BUTTON_X)
	check(moves.has(&"light_01"), "controller X starts ground light attack")
	await delay(0.55)
	await button(JOY_BUTTON_Y)
	check(moves.has(&"launcher"), "controller Y starts launcher")
	await delay(0.65)
	await button(JOY_BUTTON_START)
	check(paused and arena.hud.menu_kind == "pause", "controller Start opens pause menu")
	await button(JOY_BUTTON_START)
	check(not paused, "controller Start resumes")
	# Observe the actual death clip and actual unchanged removal timer.
	var enemy = enemies[0]
	var visual = enemy.get_node("PixelVisual")
	var lethal := AttackData.new()
	lethal.damage = 9999.0
	enemy.receive_hit(lethal, 1.0, player)
	await delay(0.06)
	check(is_instance_valid(enemy) and visual.state == "death" and enemy.body_visual.texture.region.position.y == 448.0, "enemy damage transitions to supplied death row")
	check(enemy.body_visual.texture.get_image().get_used_rect().has_area(), "displayed death frame contains pixels")
	await delay(0.16)
	check(not is_instance_valid(enemy), "death removes enemy within existing short lifetime")
	await button(JOY_BUTTON_BACK)
	arena = current_scene
	check(paused and arena.wave == 0 and arena.scene_file_path == "res://pixel_art/arena.tscn", "controller Back reloads pixel scene and title")
	paused = false
	arena.queue_free()
	await delay(0.25)
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
