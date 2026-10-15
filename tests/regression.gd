extends SceneTree
## Integration checks use real scene physics, overlaps, timers and input actions.
var checks := 0
var failures := 0
var arena: Node
var moves: Array[StringName] = []
var scene_path := ""
var screenshot_dir := "/tmp/stylebreaker-logs/screenshots"

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size() - 1):
		if args[i] == "--scene":
			scene_path = args[i + 1]
		elif args[i] == "--screenshots":
			screenshot_dir = args[i + 1]
	seed(12345)
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

func tap(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await physics_frame
	await physics_frame
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	var result := root.get_texture().get_image().save_png(screenshot_dir.path_join(name) + ".png")
	check(result == OK, "render screenshot " + name)

func wait_for_wave(number: int) -> bool:
	for i in range(100):
		if arena.wave == number and not arena.spawning_wave:
			return true
		await delay(0.05)
	return false

func _run() -> void:
	if scene_path.is_empty():
		scene_path = ProjectSettings.get_setting("application/run/main_scene")
	var scene := load(scene_path) as PackedScene
	check(scene != null, "main scene and dependencies load")
	arena = scene.instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	await process_frame
	check(paused and arena.wave == 0, "title holds the arena until Start")
	await capture("01-title")
	arena.hud.menu_button.pressed.emit()
	check(not paused and arena.started, "title button starts combat")
	check(await wait_for_wave(1), "first wave spawns")
	check(arena.enemies_alive == 2, "wave one has two enemies")
	await capture("02-arena")
	var p = arena.player
	var frames: SpriteFrames = p.sprite.sprite_frames
	var frame_bounds_ok := true
	for animation in frames.get_animation_names():
		for frame in range(frames.get_frame_count(animation)):
			var texture := frames.get_frame_texture(animation, frame) as AtlasTexture
			if texture and (texture.region.end.x > texture.atlas.get_width() or texture.region.end.y > texture.atlas.get_height()):
				frame_bounds_ok = false
	check(frame_bounds_ok, "every animation frame fits its original replacement atlas")
	var has_pad_jump := false
	for event in InputMap.action_get_events("jump"):
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
			has_pad_jump = true
	check(has_pad_jump, "controller jump binding is present")
	var enemies := get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.set_physics_process(false)
		enemy.global_position = Vector2(1100, 616)
	p.attack_started.connect(func(data: AttackData) -> void: moves.append(data.move_id))
	# Move and double jump through the actual InputMap.
	var old_x: float = p.position.x
	Input.action_press("move_right")
	await delay(.12)
	Input.action_release("move_right")
	check(p.position.x > old_x + 8, "movement responds to input")
	await tap(&"jump")
	await delay(.05)
	await tap(&"jump")
	check(p.jumps_used == 2 and p.velocity.y < 0, "double jump works")
	await delay(.85)
	p.position = Vector2(400, 616)
	p.velocity = Vector2.ZERO
	await delay(.08)
	moves.clear()
	await tap(&"light_attack")
	await delay(.14)
	await tap(&"light_attack")
	await delay(.21)
	await tap(&"light_attack")
	await delay(.45)
	check(moves == [&"light_01", &"light_02", &"light_03"], "buffered ground chain advances 1, 2, 3")
	await delay(.65)
	await tap(&"light_attack")
	check(moves.back() == &"light_01", "combo resets after timeout")
	await delay(.07)
	check(p.hitbox.monitoring, "hitbox activates after startup")
	await tap(&"dash")
	var hp_before: float = p.hp
	p.receive_hit(20.0)
	check(not p.hitbox.monitoring and not p.attacking, "dash cancels and disables the hitbox")
	check(p.hp == hp_before, "dash provides invulnerability")
	await delay(.4)
	check(not p.hitbox.monitoring and not p.attacking, "cancelled timers cannot reactivate the hitbox")
	# Real Area2D contact: one confirmed hit per activation and launcher motion.
	var target = enemies[0]
	target.max_hp = 1000.0
	target.hp = 1000.0
	target.attack_cooldown_left = 1000.0
	target.set_physics_process(true)
	p.position = Vector2(500, 616)
	p.velocity = Vector2.ZERO
	p.facing = 1.0
	target.position = Vector2(550, 616)
	target.velocity = Vector2.ZERO
	await delay(.06)
	p._start_attack(p.launcher)
	await delay(.14)
	check(target.hp == 988.0 and target.velocity.y < 0, "launcher overlap deals one hit and launches")
	await capture("03-combat")
	await delay(.3)
	p.position = Vector2(500, 460)
	p.velocity = Vector2.ZERO
	target.position = Vector2(550, 460)
	target.velocity = Vector2(0, -45)
	await physics_frame
	await physics_frame
	p._start_attack(p.air_light_attacks[0])
	await delay(.1)
	check(target.hp == 980.0, "air light connects through the hitbox")
	check(p.air_suspend_left > 0 and target.air_suspend_left > 0, "air hit suspends both actors")
	await delay(.25)
	p.position = Vector2(500, 420)
	p.velocity = Vector2.ZERO
	target.position = Vector2(550, 435)
	target.velocity = Vector2.ZERO
	await physics_frame
	p._start_attack(p.air_heavy)
	await delay(.14)
	check(target.hp == 962.0 and target.velocity.y > 0, "air heavy connects and sends the target downward")
	await delay(.35)
	# Score rules and the director's two-attacker limit.
	var style = arena.get_node("StyleSystem")
	style.reset()
	style.register_move(&"a", 100)
	style.register_move(&"a", 100)
	check(is_equal_approx(style.score, 170), "repeated move scores less")
	style.register_move(&"b", 100)
	check(is_equal_approx(style.score, 270), "move variety restores full award")
	style.player_was_hit()
	check(is_equal_approx(style.score, 148.5), "taking damage reduces Style")
	arena.active_attackers.clear()
	var third := Node.new()
	root.add_child(third)
	check(arena.request_attack_token(enemies[0]) and arena.request_attack_token(enemies[1]) and not arena.request_attack_token(third), "director admits at most two attackers")
	arena.release_attack_token(enemies[0])
	check(arena.request_attack_token(third), "released attack slots can be reused")
	arena.release_attack_token(third)
	third.free()
	arena.active_attackers.clear()
	# Real enemy windup hits the player, consumes its token, and respects i-frames.
	p.position = Vector2(400, 616)
	p.velocity = Vector2.ZERO
	p.invulnerability_left = 0
	p.dash_left = 0
	target.position = Vector2(445, 616)
	target.velocity = Vector2.ZERO
	target.hitstun_left = 0
	target._request_attack_token()
	target._begin_attack()
	var health_before: float = p.hp
	await delay(.44)
	check(p.hp == health_before - target.attack_damage, "enemy telegraph leads to the configured damage")
	health_before = p.hp
	p.receive_hit(8.0)
	check(p.hp == health_before, "damage invulnerability prevents immediate repeat hits")
	await delay(.35)
	check(not target.token_held, "enemy recovery releases its attack slot")
	# Interrupted windup must not finish a newer attack.
	p.position = Vector2(200, 616)
	target.position = Vector2(1000, 616)
	target.hitstun_left = 0
	target._request_attack_token()
	target._begin_attack()
	await delay(.12)
	target.receive_hit(p.light_attacks[0], 1.0, p)
	await delay(.18)
	target._request_attack_token()
	target._begin_attack()
	await delay(.13)
	check(target.attacking and target.token_held, "old windup cannot cancel a newer attack token")
	target.stop_combat()
	# Combat timers, not just physics, must freeze in a pause.
	p._start_attack(p.launcher)
	arena.toggle_pause()
	await delay(.5)
	check(paused and p.attacking and not p.hitbox.monitoring, "pause freezes an attack during startup")
	arena.hud.menu_button.pressed.emit()
	await delay(.45)
	check(not paused and not p.attacking, "resume completes the paused attack")
	arena.get_node("HitStop").request(.08)
	arena.toggle_pause()
	await delay(.2)
	check(Engine.time_scale < 1.0, "pause preserves the pending hitstop countdown")
	arena.toggle_pause()
	await delay(.12)
	check(is_equal_approx(Engine.time_scale, 1.0), "hitstop finishes after resume")
	# Exercise actual scene reload while the global hitstop scale is active.
	arena.get_node("HitStop").request(.5)
	arena.restart_run()
	await delay(.12)
	arena = current_scene
	check(is_equal_approx(Engine.time_scale, 1.0) and paused and arena.wave == 0, "restart during hitstop restores full speed and title")
	# Scripted lethal hits exercise every wave/death lifecycle, not combat balance.
	arena.hud.menu_button.pressed.emit()
	var lethal := AttackData.new()
	lethal.damage = 9999
	for number in range(1, 6):
		check(await wait_for_wave(number), "wave %d reaches a stable spawned state" % number)
		check(arena.enemies_alive == arena.WAVE_COUNTS[number - 1], "wave %d keeps original enemy count" % number)
		for enemy in get_nodes_in_group("enemies"):
			if not enemy.dead:
				enemy.receive_hit(lethal, 1.0, arena.player)
		if number == 5:
			await delay(1.3)
	check(arena.run_over and arena.wave == 5 and arena.hud.menu_title.text == "ARENA CLEAR", "all five waves produce the victory result")
	check(not arena.player.is_physics_processing(), "victory ends player combat")
	await capture("04-victory")
	arena.hud.menu_button.pressed.emit()
	await delay(.12)
	arena = current_scene
	arena.hud.menu_button.pressed.emit()
	arena.player.receive_hit(1000.0)
	check(arena.run_over and arena.player.dead and arena.hud.menu_title.text == "BREAKER DOWN", "lethal damage produces defeat and retry")
	await delay(2)
	check(arena.enemies_root.get_child_count() == 0, "defeat cancels pending wave spawns")
	paused = false
	arena.queue_free()
	await process_frame
	await process_frame
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
