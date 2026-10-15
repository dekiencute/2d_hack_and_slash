extends Control
## Inspection drawing only. Uses original textures and region coordinates; writes no art.
var image_texture: Texture2D
var region := Rect2i()
var cell := Vector2i.ZERO
var integer_zoom := 4
var show_grid := true
var flip := false
var backdrop := 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func configure(texture: Texture2D, source: Rect2i, cell_size: Vector2i, zoom: int, grid: bool, mirrored: bool, background: int) -> void:
	image_texture = texture
	region = source
	cell = cell_size
	integer_zoom = zoom
	show_grid = grid
	flip = mirrored
	backdrop = background
	custom_minimum_size = Vector2(region.size * integer_zoom) + Vector2(64, 64) if texture else Vector2(320, 240)
	queue_redraw()

func _draw() -> void:
	var base := Color("202735") if backdrop != 2 else Color("e1e2e5")
	draw_rect(Rect2(Vector2.ZERO, size), base)
	if backdrop == 0:
		# Draw only the visible checkerboard, even when a large sheet is scrolled.
		var visible := Rect2(-position, get_parent_control().size).intersection(Rect2(Vector2.ZERO, size))
		for y in range(int(visible.position.y) / 16, int(visible.end.y) / 16 + 1):
			for x in range(int(visible.position.x) / 16, int(visible.end.x) / 16 + 1):
				if (x + y) % 2 == 0:
					draw_rect(Rect2(x * 16, y * 16, 16, 16), Color("2b3444"))
	if image_texture == null or region.size == Vector2i.ZERO:
		return
	var drawn_size := Vector2(region.size * integer_zoom)
	var at := ((size - drawn_size) * 0.5).floor()
	draw_set_transform(at + drawn_size * 0.5, 0.0, Vector2(-1.0 if flip else 1.0, 1.0))
	draw_texture_rect_region(image_texture, Rect2(-drawn_size * 0.5, drawn_size), Rect2(region))
	draw_set_transform(Vector2.ZERO)
	if show_grid:
		draw_rect(Rect2(at, drawn_size), Color(0.65, 0.8, 1, 0.6), false, 1)
		if cell.x > 0 and cell.y > 0:
			for x in range(cell.x, region.size.x, cell.x):
				draw_line(at + Vector2(x * integer_zoom, 0), at + Vector2(x * integer_zoom, drawn_size.y), Color(0.65, 0.8, 1, 0.4))
			for y in range(cell.y, region.size.y, cell.y):
				draw_line(at + Vector2(0, y * integer_zoom), at + Vector2(drawn_size.x, y * integer_zoom), Color(0.65, 0.8, 1, 0.4))
