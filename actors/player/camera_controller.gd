extends Camera2D

# Stable character-action camera for side-view combat.
# Horizontal look-ahead is intentionally disabled because rapid A/D direction
# changes are common during combos and can make the camera feel nauseating.
# The camera only adjusts vertical framing and a very small amount of zoom
# during confirmed air-combat situations.

@export_category("Framing")
@export var base_vertical_offset := -65.0
@export var air_vertical_offset := -110.0

@export_category("Response")
@export var rise_speed := 7.0
@export var return_speed := 3.5

@export_category("Zoom")
@export var ground_zoom := 1.50
@export var air_zoom := 1.46
@export var zoom_response_speed := 3.0

var target_offset := Vector2.ZERO
var target_zoom := 1.50

@onready var player := get_parent()


func _ready() -> void:
	target_offset = Vector2(0.0, base_vertical_offset)
	offset = target_offset
	target_zoom = ground_zoom
	zoom = Vector2.ONE * ground_zoom


func _process(delta: float) -> void:
	var air_combat := _is_air_combat()

	# Keep horizontal framing completely stable. The player can switch facing
	# as often as needed without pulling the camera left/right.
	target_offset.x = 0.0
	offset.x = 0.0

	target_offset.y = (
		air_vertical_offset
		if air_combat
		else base_vertical_offset
	)

	# Follow upward action faster, but return to ground framing more gently.
	var vertical_speed := return_speed
	if target_offset.y < offset.y:
		vertical_speed = rise_speed

	offset.y = lerpf(
		offset.y,
		target_offset.y,
		_smooth_factor(vertical_speed, delta)
	)

	# Keep zoom changes subtle so air combat remains readable without creating
	# a distracting breathing/zooming effect.
	target_zoom = air_zoom if air_combat else ground_zoom
	var current_zoom := zoom.x
	current_zoom = lerpf(
		current_zoom,
		target_zoom,
		_smooth_factor(zoom_response_speed, delta)
	)
	zoom = Vector2.ONE * current_zoom


func _is_air_combat() -> bool:
	if player.is_on_floor():
		return false

	var attacking_value = player.get("attacking")
	var suspend_value = player.get("air_suspend_left")

	var is_attacking := bool(attacking_value) if attacking_value != null else false
	var suspend_left := float(suspend_value) if suspend_value != null else 0.0

	return is_attacking or suspend_left > 0.0


func _smooth_factor(speed: float, delta: float) -> float:
	return 1.0 - exp(-speed * delta)
