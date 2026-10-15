extends Node
## Audio only. Confirmed hits remain owned by AttackHitbox.

const SOUNDS := {
	"slash": preload("res://resources/audio/slash.wav"),
	"hit": preload("res://resources/audio/hit.wav"),
	"dash": preload("res://resources/audio/dash.wav"),
	"hurt": preload("res://resources/audio/hurt.wav"),
	"wave": preload("res://resources/audio/wave.wav"),
	"victory": preload("res://resources/audio/victory.wav"),
	"defeat": preload("res://resources/audio/defeat.wav"),
}
var voices: Array[AudioStreamPlayer] = []
var voice_index := 0
var muted := false

func _ready() -> void:
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

func _on_attack(_data: AttackData) -> void:
	play_sound("slash")

func _on_dash() -> void:
	play_sound("dash")

func _on_hit(_target: Node2D, _data: AttackData, _direction: float) -> void:
	play_sound("hit")

func _on_hurt() -> void:
	play_sound("hurt")
