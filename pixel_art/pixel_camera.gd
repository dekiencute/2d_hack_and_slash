extends Camera2D
## Integer camera and finite parallax framing for the standalone arena.
var player
var forest
var original_scale_mode: int

func _ready() -> void:
	player = get_parent().get_node("Player")
	forest = get_parent().get_node("Forest")
	original_scale_mode = get_window().content_scale_mode
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_viewport().snap_2d_transforms_to_pixel = true
	make_current()
	_update_camera()

func _process(_delta: float) -> void:
	_update_camera()

func _update_camera() -> void:
	var size := get_viewport_rect().size
	var integer_zoom := maxf(1.0, ceilf(maxf(size.x / 1280.0, size.y / 720.0)))
	zoom = Vector2.ONE * integer_zoom
	var half_view := size / integer_zoom / 2.0
	var target: Vector2 = player.position + Vector2(0, -220)
	position = target.clamp(Vector2(-240, -830) + half_view, Vector2(1616, 756) - half_view).round()
	var relative_camera := (position - Vector2(688, 396)) / 2.0
	forest.sync_camera_offset(relative_camera)

func _exit_tree() -> void:
	get_window().content_scale_mode = original_scale_mode
