class_name AttackHitbox
extends Area2D

var attack: AttackData
var owner_actor: Node
var facing := 1.0
var hit_targets: Dictionary = {}

func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)

func activate(data: AttackData, attacker: Node, face: float) -> void:
	attack = data
	owner_actor = attacker
	facing = face
	hit_targets.clear()
	monitoring = true

func deactivate() -> void:
	monitoring = false
	attack = null
	hit_targets.clear()

func _on_body_entered(body: Node) -> void:
	if attack == null or body == owner_actor or hit_targets.has(body):
		return
	if not body.has_method("receive_hit"):
		return

	hit_targets[body] = true
	var target_was_airborne := false
	if body is CharacterBody2D:
		target_was_airborne = not body.is_on_floor()
	body.receive_hit(attack, facing, owner_actor)

	if owner_actor.has_method("on_attack_hit_confirmed"):
		owner_actor.on_attack_hit_confirmed(body, attack, target_was_airborne)

	var style := get_tree().get_first_node_in_group("style_system")
	if style:
		style.register_move(attack.move_id, attack.style_score)

	var hitstop := get_tree().get_first_node_in_group("hitstop")
	if hitstop:
		hitstop.request(attack.hitstop)
