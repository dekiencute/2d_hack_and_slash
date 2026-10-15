extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal died

const SPEED := 340.0
const ACCEL := 2200.0
const AIR_ACCEL := 1500.0
const FRICTION := 2600.0
const JUMP_VELOCITY := -560.0
const GRAVITY := 1550.0

const AIR_HIT_SUSPEND_TIME := 0.12
const AIR_HIT_GRAVITY_SCALE := 0.08
const AIR_HIT_VERTICAL_DAMPING := 0.15

const DASH_SPEED := 760.0
const DASH_TIME := 0.12
const DASH_COOLDOWN := 0.22
const INPUT_BUFFER_TIME := 0.16
const HURT_TIME := 0.14
const HIT_INVULNERABILITY := 0.55

@export var max_hp := 100.0

@onready var hitbox: AttackHitbox = $AttackHitbox
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var light_attacks: Array[AttackData] = [
	preload("res://resources/attacks/light_01.tres"),
	preload("res://resources/attacks/light_02.tres"),
	preload("res://resources/attacks/light_03.tres"),
]
var air_light_attacks: Array[AttackData] = [
	preload("res://resources/attacks/air_light_01.tres"),
	preload("res://resources/attacks/air_light_02.tres"),
	preload("res://resources/attacks/air_light_03.tres"),
]
var launcher: AttackData = preload("res://resources/attacks/launcher.tres")
var air_heavy: AttackData = preload("res://resources/attacks/air_heavy.tres")

var hp := 100.0
var facing := 1.0
var jumps_used := 0
var attacking := false
var dead := false
var has_move_input := false
var move_axis := 0.0
var attack_generation := 0
var ground_combo_index := 0
var air_combo_index := 0
var combo_timeout := 0.0
var buffered_action: StringName = &""
var buffer_left := 0.0
var dash_left := 0.0
var dash_cooldown_left := 0.0
var air_suspend_left := 0.0
var hurt_left := 0.0
var invulnerability_left := 0.0

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	animation_tree.active = true
	sprite.stop()
	animation_state.start(&"Idle", true)
	health_changed.emit(hp, max_hp)

func _unhandled_input(event: InputEvent) -> void:
	if dead:
		return
	if event.is_action_pressed("light_attack"):
		buffered_action = &"light"
		buffer_left = INPUT_BUFFER_TIME
	elif event.is_action_pressed("heavy_attack"):
		buffered_action = &"heavy"
		buffer_left = INPUT_BUFFER_TIME

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		return

	move_axis = Input.get_axis("move_left", "move_right")
	has_move_input = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")

	buffer_left = maxf(0.0, buffer_left - delta)
	if buffer_left <= 0.0:
		buffered_action = &""

	combo_timeout = maxf(0.0, combo_timeout - delta)
	if combo_timeout <= 0.0 and not attacking:
		ground_combo_index = 0
		air_combo_index = 0

	dash_cooldown_left = maxf(0.0, dash_cooldown_left - delta)
	air_suspend_left = maxf(0.0, air_suspend_left - delta)
	hurt_left = maxf(0.0, hurt_left - delta)
	invulnerability_left = maxf(0.0, invulnerability_left - delta)

	if is_on_floor():
		jumps_used = 0
		air_combo_index = 0
	elif dash_left <= 0.0:
		var gravity_scale := AIR_HIT_GRAVITY_SCALE if air_suspend_left > 0.0 else 1.0
		velocity.y += GRAVITY * gravity_scale * delta

	if dead:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		move_and_slide()
		return

	if hurt_left <= 0.0:
		if Input.is_action_just_pressed("jump") and jumps_used < 2 and not attacking:
			velocity.y = JUMP_VELOCITY
			jumps_used += 1

		if Input.is_action_just_pressed("dash") and dash_cooldown_left <= 0.0:
			_start_dash()

	if dash_left > 0.0:
		dash_left = maxf(0.0, dash_left - delta)
		velocity.x = facing * DASH_SPEED
		velocity.y = 0.0
	elif hurt_left > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * 0.2 * delta)
	else:
		_handle_horizontal_movement(delta)
		_try_consume_buffer()

	move_and_slide()
	_update_visual_facing()

func _handle_horizontal_movement(delta: float) -> void:
	if attacking:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * 0.35 * delta)
		return

	if absf(move_axis) > 0.01:
		facing = signf(move_axis)
		var accel := ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, move_axis * SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

func _try_consume_buffer() -> void:
	if dead or hurt_left > 0.0 or attacking or buffered_action == &"":
		return

	var action := buffered_action
	buffered_action = &""
	buffer_left = 0.0

	if action == &"light":
		if is_on_floor():
			_start_attack(light_attacks[ground_combo_index])
			ground_combo_index = (ground_combo_index + 1) % light_attacks.size()
			combo_timeout = 0.55
		else:
			_start_attack(air_light_attacks[air_combo_index])
			air_combo_index = (air_combo_index + 1) % air_light_attacks.size()
			combo_timeout = 0.38
	elif action == &"heavy":
		ground_combo_index = 0
		if is_on_floor():
			_start_attack(launcher)
		else:
			_start_attack(air_heavy)

func _start_attack(data: AttackData) -> void:
	attack_generation += 1
	var generation := attack_generation
	attacking = true

	# start() is intentional here: attacks are action states and should never
	# get stuck because a graph path is missing.
	animation_state.start(data.animation_state, true)

	if data.lunge_time > 0.0:
		velocity.x = facing * data.lunge_speed

	await get_tree().create_timer(data.startup).timeout
	if generation != attack_generation or dead:
		return

	_position_hitbox(data)
	hitbox.activate(data, self, facing)

	await get_tree().create_timer(data.active).timeout
	if generation != attack_generation or dead:
		return

	hitbox.deactivate()

	await get_tree().create_timer(data.recovery).timeout
	if generation != attack_generation or dead:
		return

	attacking = false
	if buffered_action != &"":
		_try_consume_buffer()
	else:
		_return_to_locomotion_state()

func _return_to_locomotion_state() -> void:
	if dead:
		return
	if not is_on_floor():
		if velocity.y < 0.0:
			animation_state.start(&"Jump", true)
		else:
			animation_state.start(&"Fall", true)
	elif has_move_input:
		animation_state.start(&"Run", true)
	else:
		animation_state.start(&"Idle", true)

func on_attack_hit_confirmed(target: Node, attack: AttackData, target_was_airborne: bool) -> void:
	if is_on_floor() or not target_was_airborne or attack.move_id == &"air_heavy":
		return

	velocity.y *= AIR_HIT_VERTICAL_DAMPING
	air_suspend_left = AIR_HIT_SUSPEND_TIME

	if target.has_method("apply_air_suspend"):
		target.apply_air_suspend(AIR_HIT_SUSPEND_TIME, AIR_HIT_VERTICAL_DAMPING)

func _position_hitbox(data: AttackData) -> void:
	var x_offset := 42.0 * facing
	var y_offset := -4.0
	if data.move_id == &"launcher":
		y_offset = -22.0
	elif data.move_id == &"air_heavy":
		y_offset = 22.0
	hitbox.position = Vector2(x_offset, y_offset)

func _start_dash() -> void:
	attack_generation += 1
	attacking = false
	hitbox.deactivate()
	buffered_action = &""
	dash_left = DASH_TIME
	dash_cooldown_left = DASH_COOLDOWN

	if absf(move_axis) > 0.01:
		facing = signf(move_axis)

	animation_state.start(&"Dash", true)

func receive_hit(damage: float, knockback_x: float = 180.0) -> void:
	if dead or invulnerability_left > 0.0 or dash_left > 0.0:
		return

	hp = maxf(0.0, hp - damage)
	health_changed.emit(hp, max_hp)

	var style := get_tree().get_first_node_in_group("style_system")
	if style:
		style.player_was_hit()

	attack_generation += 1
	attacking = false
	hitbox.deactivate()
	buffered_action = &""
	hurt_left = HURT_TIME
	invulnerability_left = HIT_INVULNERABILITY
	velocity.x = knockback_x
	velocity.y = -125.0
	_flash_player()

	if hp <= 0.0:
		_die()
	else:
		_return_to_locomotion_state()

func _flash_player() -> void:
	sprite.modulate = Color(1.0, 0.35, 0.35)
	await get_tree().create_timer(0.08, true, false, true).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

func _die() -> void:
	dead = true
	attack_generation += 1
	attacking = false
	hitbox.deactivate()
	buffered_action = &""
	velocity.x = 0.0
	animation_tree.active = false
	# Freeze the current pose; the HUD communicates game over.
	died.emit()

func _update_visual_facing() -> void:
	sprite.flip_h = facing < 0.0
