extends Node2D
## Shared by the inspection camera and gameplay camera. Offset is in source pixels.
func sync_camera_offset(offset: Vector2) -> void:
	for layer: Parallax2D in get_children():
		# Refresh stationary scroll-scale changes too. Native Parallax2D applies depth.
		layer.screen_offset = offset + Vector2.ONE
		layer.screen_offset = offset
