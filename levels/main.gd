extends Node2D

const ENEMY_SCENE := preload("res://actors/enemies/dummy_enemy.tscn")
const WAVE_COUNTS := [2, 3, 3, 4, 5]
const TOTAL_WAVES := 5
const MAX_ACTIVE_ATTACKERS := 2
const SPAWN_POINTS := [
	Vector2(600, 620),
	Vector2(760, 620),
	Vector2(920, 620),
	Vector2(1080, 620),
	Vector2(1210, 620),
	Vector2(470, 620),
]

@onready var player = $Player
@onready var enemies_root: Node2D = $Enemies
@onready var hud = $HUD

var wave := 0
var enemies_alive := 0
var run_over := false
var spawning_wave := false
var started := false
var elapsed := 0.0
var active_attackers: Dictionary = {}

func _enter_tree() -> void:
	_setup_input_map()

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	_on_player_health_changed(player.hp, player.max_hp)
	hud.set_wave(0, TOTAL_WAVES)
	hud.set_enemies(0)
	hud.start_requested.connect(start_run)
	hud.restart_requested.connect(restart_run)
	hud.pause_requested.connect(toggle_pause)
	get_tree().paused = true

func _process(delta: float) -> void:
	if started and not run_over:
		elapsed += delta / maxf(Engine.time_scale, 0.01)

func start_run() -> void:
	if started:
		return
	started = true
	hud.hide_menu()
	get_tree().paused = false
	hud.set_message("BREAK THE PATTERN")
	await get_tree().create_timer(1.25, false).timeout
	if not run_over:
		_start_next_wave()

func restart_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().call_deferred("reload_current_scene")

func toggle_pause() -> void:
	if not started or run_over:
		return
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		hud.show_pause()
	else:
		hud.hide_menu()

func _start_next_wave() -> void:
	if run_over or spawning_wave:
		return
	if wave >= TOTAL_WAVES:
		_win_run()
		return

	spawning_wave = true
	wave += 1
	var enemy_count: int = WAVE_COUNTS[wave - 1]
	enemies_alive = enemy_count
	hud.set_wave(wave, TOTAL_WAVES)
	hud.set_enemies(enemies_alive)
	hud.set_message("WAVE %d" % wave)
	$CombatFeedback.play_sound("wave")

	await get_tree().create_timer(0.65, false).timeout
	for i in range(enemy_count):
		if run_over:
			break
		_spawn_enemy(i)
		await get_tree().create_timer(0.18, false).timeout

	spawning_wave = false
	if not run_over:
		hud.set_message("")

func _spawn_enemy(index: int) -> void:
	var enemy = ENEMY_SCENE.instantiate()
	enemies_root.add_child(enemy)
	enemy.global_position = SPAWN_POINTS[index % SPAWN_POINTS.size()]
	enemy.configure_for_wave(wave, index)
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Node) -> void:
	release_attack_token(enemy)
	enemies_alive = maxi(0, enemies_alive - 1)
	hud.set_enemies(enemies_alive)

	if enemies_alive == 0 and not run_over:
		hud.set_message("WAVE CLEAR")
		await get_tree().create_timer(1.15, false).timeout
		if not run_over:
			_start_next_wave()

func request_attack_token(enemy: Node) -> bool:
	_cleanup_attackers()
	if active_attackers.has(enemy):
		return true
	if active_attackers.size() >= MAX_ACTIVE_ATTACKERS:
		return false
	active_attackers[enemy] = true
	return true

func release_attack_token(enemy: Node) -> void:
	active_attackers.erase(enemy)

func _cleanup_attackers() -> void:
	for enemy in active_attackers.keys():
		if not is_instance_valid(enemy):
			active_attackers.erase(enemy)

func _on_player_health_changed(current: float, maximum: float) -> void:
	hud.set_player_hp(current, maximum)

func _on_player_died() -> void:
	if run_over:
		return
	run_over = true
	_finish_run(false)

func _win_run() -> void:
	run_over = true
	_finish_run(true)

func _finish_run(won: bool) -> void:
	hud.set_message("")
	player.attack_generation += 1
	player.attacking = false
	player.hitbox.deactivate()
	player.set_physics_process(false)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and not enemy.dead:
			enemy.stop_combat()
	$StyleSystem.set_process(false)
	hud.show_result(won, player.hp, $StyleSystem.peak_score, elapsed)
	$CombatFeedback.play_sound("victory" if won else "defeat")

func _setup_input_map() -> void:
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("jump", KEY_SPACE)
	_add_key_action("dash", KEY_SHIFT)
	_add_key_action("light_attack", KEY_J)
	_add_key_action("heavy_attack", KEY_K)
	_add_key_action("reset", KEY_R)
	_add_key_action("pause", KEY_ESCAPE)
	_add_key_action("mute", KEY_M)
	_add_key_action("fullscreen", KEY_F11)

	_add_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_button("jump", JOY_BUTTON_A)
	_add_joy_button("ui_accept", JOY_BUTTON_A)
	_add_joy_button("dash", JOY_BUTTON_B)
	_add_joy_button("light_attack", JOY_BUTTON_X)
	_add_joy_button("heavy_attack", JOY_BUTTON_Y)
	_add_joy_button("pause", JOY_BUTTON_START)
	_add_joy_button("reset", JOY_BUTTON_BACK)

func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)

func _add_key_action(action: StringName, keycode: int) -> void:
	_ensure_action(action)
	for existing in InputMap.action_get_events(action):
		if existing is InputEventKey and existing.physical_keycode == keycode:
			return
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _add_joy_button(action: StringName, button: int) -> void:
	_ensure_action(action)
	for existing in InputMap.action_get_events(action):
		if existing is InputEventJoypadButton and existing.button_index == button:
			return
	var event := InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)

func _add_joy_axis(action: StringName, axis: int, value: float) -> void:
	_ensure_action(action)
	for existing in InputMap.action_get_events(action):
		if existing is InputEventJoypadMotion and existing.axis == axis and is_equal_approx(existing.axis_value, value):
			return
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action, event)
