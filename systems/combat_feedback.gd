extends Node2D
## Presentation only. Confirmed hits remain owned by AttackHitbox.

const SOUNDS := {
	"slash": preload("res://resources/original/audio/slash.wav"),
	"hit": preload("res://resources/original/audio/hit.wav"),
	"dash": preload("res://resources/original/audio/dash.wav"),
	"hurt": preload("res://resources/original/audio/hurt.wav"),
	"wave": preload("res://resources/original/audio/wave.wav"),
	"victory": preload("res://resources/original/audio/victory.wav"),
	"defeat": preload("res://resources/original/audio/defeat.wav"),
}
var effects: Array[Dictionary] = []
var voices: Array[AudioStreamPlayer] = []
var voice_index := 0
var muted := false

func _ready() -> void:
	z_index = 10
	add_to_group("combat_feedback")
	for i in range(8):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -13.0
		add_child(voice)
		voices.append(voice)
	var player := get_tree().get_first_node_in_group("player")
	player.attack_started.connect(_on_attack)
	player.dash_started.connect(_on_dash)
	player.damaged.connect(_on_hurt)
	player.hitbox.hit_confirmed.connect(_on_hit)

func play_sound(sound_name: String) -> void:
	if muted:
		return
	var voice := voices[voice_index]
	voice_index = (voice_index + 1) % voices.size()
	voice.stream = SOUNDS[sound_name]
	voice.play()

func toggle_mute() -> bool:
	muted = not muted
	if muted:
		for voice in voices:
			voice.stop()
	return muted

func _on_attack(data: AttackData) -> void:
	var player := get_tree().get_first_node_in_group("player")
	effects.append({"kind": "slash", "pos": player.global_position + Vector2(0, -30),
		"age": 0.0, "life": 0.19, "face": player.facing, "heavy": data.move_id == &"launcher" or data.move_id == &"air_heavy"})
	play_sound("slash")

func _on_dash() -> void:
	var player := get_tree().get_first_node_in_group("player")
	for i in range(4):
		effects.append({"kind": "dash", "pos": player.global_position + Vector2(-player.facing * i * 18, -28), "age": 0.0, "life": 0.23})
	play_sound("dash")

func _on_hit(target: Node2D, _data: AttackData, _direction: float) -> void:
	effects.append({"kind": "hit", "pos": target.global_position + Vector2(0, -34), "age": 0.0, "life": 0.22})
	play_sound("hit")

func _on_hurt() -> void:
	var player := get_tree().get_first_node_in_group("player")
	effects.append({"kind": "hurt", "pos": player.global_position + Vector2(0, -28), "age": 0.0, "life": 0.3})
	play_sound("hurt")

func _process(delta: float) -> void:
	# Visual effects use real elapsed time even during hitstop, and pause with combat.
	var real_delta := delta / maxf(Engine.time_scale, 0.01)
	for effect in effects:
		effect.age += real_delta
	effects = effects.filter(func(effect: Dictionary) -> bool: return effect.age < effect.life)
	queue_redraw()

func _draw() -> void:
	for effect in effects:
		var p: float = effect.age / effect.life
		var at: Vector2 = effect.pos
		var color := Color(0.4, 1.0, 0.91, 1.0 - p)
		match effect.kind:
			"slash":
				if effect.heavy:
					color = Color(1.0, 0.79, 0.4, 1.0 - p)
				var center_angle: float = 0.0 if effect.face > 0 else PI
				var radius := 42.0 + p * 27.0
				draw_arc(at, radius, center_angle - 1.2, center_angle + 1.2, 24, color, (1.0 - p) * 6.0 + 1.0, true)
			"dash":
				draw_line(at + Vector2(-10, -16), at + Vector2(4, 16), color * Color(1, 1, 1, 0.5), 7.0, true)
			"hit", "hurt":
				color = Color(1.0, 0.82, 0.5, 1.0 - p) if effect.kind == "hit" else Color(1.0, 0.36, 0.4, 1.0 - p)
				for i in range(8):
					var direction := Vector2.from_angle(i * TAU / 8.0 + 0.3)
					draw_line(at + direction * (5.0 + p * 20.0), at + direction * (18.0 + p * 28.0), color, 2.5, true)
