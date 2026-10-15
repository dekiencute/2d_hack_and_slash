extends Node

signal style_changed(rank: String, score: float)

const RANKS := [
	[0.0, "D"],
	[50.0, "C"],
	[110.0, "B"],
	[190.0, "A"],
	[290.0, "S"],
	[420.0, "SS"],
	[580.0, "SSS"],
]

var score := 0.0
var peak_score := 0.0
var last_move: StringName = &""
var repeat_count := 0
var decay_delay := 1.4
var idle_time := 0.0

func _ready() -> void:
	add_to_group("style_system")

func _process(delta: float) -> void:
	idle_time += delta
	if idle_time > decay_delay and score > 0.0:
		score = maxf(0.0, score - 22.0 * delta)
		style_changed.emit(get_rank(), score)

func register_move(move_id: StringName, base_score: float) -> void:
	idle_time = 0.0
	if move_id == last_move:
		repeat_count += 1
	else:
		last_move = move_id
		repeat_count = 0
	var multipliers := [1.0, 0.7, 0.4, 0.1]
	var index := mini(repeat_count, multipliers.size() - 1)
	score += base_score * multipliers[index]
	peak_score = maxf(peak_score, score)
	style_changed.emit(get_rank(), score)

func player_was_hit() -> void:
	score *= 0.55
	idle_time = 0.0
	style_changed.emit(get_rank(), score)

func get_rank() -> String:
	var rank := "D"
	for entry in RANKS:
		if score >= entry[0]:
			rank = entry[1]
	return rank

func reset() -> void:
	score = 0.0
	peak_score = 0.0
	last_move = &""
	repeat_count = 0
	idle_time = 0.0
	style_changed.emit(get_rank(), score)
