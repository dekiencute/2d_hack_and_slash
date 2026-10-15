extends Node

var _generation := 0

func _ready() -> void:
	add_to_group("hitstop")

func request(duration: float, scale: float = 0.12) -> void:
	_generation += 1
	var my_generation := _generation
	Engine.time_scale = scale
	await get_tree().create_timer(duration, true, false, true).timeout
	if my_generation == _generation:
		Engine.time_scale = 1.0
