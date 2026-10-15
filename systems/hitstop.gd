extends Node
## Real-time impact freeze. A scene-owned countdown avoids orphaned async timers.
var remaining := 0.0
var last_tick_usec := 0

func _ready() -> void:
	add_to_group("hitstop")
	set_process(false)

func request(duration: float, scale: float = 0.12) -> void:
	remaining = duration
	last_tick_usec = Time.get_ticks_usec()
	Engine.time_scale = scale
	set_process(true)

func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	remaining -= float(now - last_tick_usec) / 1000000.0
	last_tick_usec = now
	if remaining <= 0.0:
		Engine.time_scale = 1.0
		set_process(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		last_tick_usec = Time.get_ticks_usec()

func _exit_tree() -> void:
	Engine.time_scale = 1.0
