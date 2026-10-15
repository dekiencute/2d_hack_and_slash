extends TextureProgressBar
## Crops uploaded UI padding; the underlying gameplay HP value remains authoritative.
const PACK := "res://assets/Art/UI/Pixel Health Bar Asset Pack 1 by Adwit Rahman/Pixel Health Bar 1/"

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border := AtlasTexture.new()
	border.atlas = load(PACK + "Pixel1_Healthbar_0002_pixel1_border.png")
	border.region = Rect2(6, 65, 83, 11)
	texture_under = border
	var fill := AtlasTexture.new()
	fill.atlas = load(PACK + "Pixel1_Healthbar_0001_pixel1_healthbar.png")
	fill.region = Rect2(8, 54, 79, 6)
	texture_progress = fill
	texture_progress_offset = Vector2(2, 3)
	step = 0.0

func sync_health(current: float, maximum: float) -> void:
	max_value = maximum
	value = current
