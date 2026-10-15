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
var active_attackers: Dictionary = {}

func _enter_tree() -> void:
	_setup_input_map()

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	_on_player_health_changed(player.hp, player.max_hp)
	hud.set_wave(0, TOTAL_WAVES)
	hud.set_enemies(0)
	hud.set_message("STYLEBREAKER ARENA\nSurvive 5 waves. Mix moves to raise Style.")
	await get_tree().create_timer(1.25).timeout
	if not run_over:
		_start_next_wave()

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

	await get_tree().create_timer(0.65).timeout
	for i in range(enemy_count):
		if run_over:
			break
		_spawn_enemy(i)
		await get_tree().create_timer(0.18).timeout

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
		await get_tree().create_timer(1.15).timeout
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
	hud.set_message("GAME OVER\nPress R to restart")
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)

func _win_run() -> void:
	run_over = true
	hud.set_message("ARENA CLEAR!\nPress R to play again")

func _setup_input_map() -> void:
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("jump", KEY_SPACE)
	_add_key_action("dash", KEY_SHIFT)
	_add_key_action("light_attack", KEY_J)
	_add_key_action("heavy_attack", KEY_K)
	_add_key_action("reset", KEY_R)

	_add_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_button("jump", JOY_BUTTON_A)
	_add_joy_button("dash", JOY_BUTTON_B)
	_add_joy_button("light_attack", JOY_BUTTON_X)
	_add_joy_button("heavy_attack", JOY_BUTTON_Y)

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
