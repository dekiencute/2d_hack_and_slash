extends CharacterBody2D

signal died(enemy: Node)

@export var max_hp := 72.0
@export var gravity := 1400.0
@export var move_speed := 115.0
@export var attack_damage := 9.0
@export var attack_range := 62.0
@export var attack_windup := 0.38
@export var attack_recovery := 0.28
@export var attack_cooldown := 1.15
@export var attack_knockback := 230.0

var hp := 72.0
var hitstun_left := 0.0
var air_suspend_left := 0.0
var air_suspend_gravity_scale := 0.08
var attack_cooldown_left := 0.0
var attacking := false
var dead := false
var action_generation := 0
var token_held := false
var target: Node2D
var base_color := Color(0.92, 0.31, 0.34, 1.0)

@onready var body_visual: Polygon2D = $BodyVisual
@onready var hp_label: Label = $HPLabel
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp
	attack_cooldown_left = randf_range(0.25, 0.9)
	_update_label()
	_acquire_target()

func configure_for_wave(wave: int, index: int) -> void:
	max_hp = 60.0 + float(wave - 1) * 10.0
	hp = max_hp
	move_speed = 105.0 + float(wave - 1) * 7.0
	attack_damage = 8.0 + float(wave - 1) * 1.5
	attack_cooldown = maxf(0.72, 1.2 - float(wave - 1) * 0.08)
	base_color = Color.from_hsv(fmod(0.98 + float(index) * 0.035, 1.0), 0.62, 0.92)
	body_visual.color = base_color
	_update_label()

func _physics_process(delta: float) -> void:
	if dead:
		return

	air_suspend_left = maxf(0.0, air_suspend_left - delta)
	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)

	if not is_on_floor():
		var gravity_scale := air_suspend_gravity_scale if air_suspend_left > 0.0 else 1.0
		velocity.y += gravity * gravity_scale * delta

	if hitstun_left > 0.0:
		hitstun_left = maxf(0.0, hitstun_left - delta)
		velocity.x = move_toward(velocity.x, 0.0, 520.0 * delta)
	else:
		if not is_instance_valid(target):
			_acquire_target()
		_update_ai(delta)

	move_and_slide()

func _update_ai(delta: float) -> void:
	if attacking or not is_instance_valid(target):
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		return

	if target.has_method("is_queued_for_deletion") and target.is_queued_for_deletion():
		return

	var offset := target.global_position - global_position
	var horizontal_distance := absf(offset.x)
	var vertical_distance := absf(offset.y)

	if horizontal_distance > attack_range or vertical_distance > 85.0:
		var direction := signf(offset.x)
		velocity.x = move_toward(velocity.x, direction * move_speed, 700.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
		if attack_cooldown_left <= 0.0 and _request_attack_token():
			_begin_attack()

func _begin_attack() -> void:
	attacking = true
	action_generation += 1
	var generation := action_generation
	body_visual.color = Color(1.0, 0.76, 0.2, 1.0)

	await get_tree().create_timer(attack_windup).timeout
	if generation != action_generation or dead or hitstun_left > 0.0:
		_finish_attack(false)
		return

	if is_instance_valid(target):
		var offset := target.global_position - global_position
		if absf(offset.x) <= attack_range + 18.0 and absf(offset.y) <= 90.0:
			var direction := signf(offset.x)
			if direction == 0.0:
				direction = 1.0
			if target.has_method("receive_hit"):
				target.receive_hit(attack_damage, direction * attack_knockback)

	body_visual.color = Color(1.0, 0.42, 0.24, 1.0)
	await get_tree().create_timer(attack_recovery).timeout
	if generation == action_generation:
		_finish_attack(true)

func _finish_attack(apply_cooldown: bool) -> void:
	attacking = false
	body_visual.color = base_color
	if apply_cooldown:
		attack_cooldown_left = attack_cooldown + randf_range(-0.12, 0.18)
	_release_attack_token()

func _request_attack_token() -> bool:
	if token_held:
		return true
	var arena := get_tree().current_scene
	if arena and arena.has_method("request_attack_token") and arena.request_attack_token(self):
		token_held = true
		return true
	return false

func _release_attack_token() -> void:
	if not token_held:
		return
	token_held = false
	var arena := get_tree().current_scene
	if arena and arena.has_method("release_attack_token"):
		arena.release_attack_token(self)

func _acquire_target() -> void:
	target = get_tree().get_first_node_in_group("player") as Node2D

func apply_air_suspend(duration: float, vertical_damping: float) -> void:
	air_suspend_left = maxf(air_suspend_left, duration)
	velocity.y *= vertical_damping

func receive_hit(attack: AttackData, facing: float, _attacker: Node) -> void:
	if dead:
		return

	hp = maxf(0.0, hp - attack.damage)
	hitstun_left = attack.hitstun
	velocity.x = attack.knockback_x * facing
	if attack.launch_y != 0.0:
		velocity.y = attack.launch_y

	if attacking:
		action_generation += 1
		attacking = false
		attack_cooldown_left = maxf(attack_cooldown_left, 0.45)
		_release_attack_token()

	_flash()
	_update_label()

	if hp <= 0.0:
		_die()

func _flash() -> void:
	body_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	await get_tree().create_timer(0.07, true, false, true).timeout
	if is_instance_valid(body_visual):
		body_visual.modulate = Color.WHITE

func _die() -> void:
	dead = true
	action_generation += 1
	_release_attack_token()
	died.emit(self)
	body_visual.color = Color(0.28, 0.28, 0.32, 1.0)
	hp_label.text = "DOWN"
	collision_layer = 0
	collision_mask = 0
	await get_tree().create_timer(0.18).timeout
	queue_free()

func _update_label() -> void:
	hp_label.text = "HP  %d / %d" % [int(ceil(hp)), int(max_hp)]
	hp_bar.max_value = max_hp
	hp_bar.value = hp
