extends Node
## Read-only observer of the original enemy state. Never schedules attacks or damage.
const SHEET = preload("res://assets/Art/Enemies/Demon_Sword/Sword.png")
const HEALTH_BAR = preload("res://pixel_art/health_bar.gd")
var actor
var sprite: Sprite2D
var bar: TextureProgressBar
var frames: Array[AtlasTexture] = []
var state := ""
var elapsed := 0.0

func _ready() -> void:
	actor = get_parent()
	sprite = actor.body_visual
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = false
	sprite.position = Vector2(-64, -102)
	sprite.scale = Vector2(2, 2)
	for row in range(8):
		for column in range(14):
			var texture := AtlasTexture.new()
			texture.atlas = SHEET
			texture.region = Rect2(column * 128, row * 64, 128, 64)
			frames.append(texture)
	actor.hp_bar.hide()
	bar = HEALTH_BAR.new()
	bar.name = "PixelHealth"
	bar.position = Vector2(-41, -84)
	actor.add_child(bar)
	_process(0.0)

func _process(delta: float) -> void:
	var next := "idle"
	var row := 0
	var count := 7
	var fps := 10.0
	if actor.dead:
		next = "death"
		row = 7
		count = 9
		fps = 50.0 # Existing actor removal remains 0.18 seconds.
	elif actor.hitstun_left > 0.0:
		next = "hit"
		row = 6
		count = 2
	elif actor.attacking:
		next = "attack"
		row = 4
		count = 14
	elif absf(actor.velocity.x) > 8.0:
		next = "run"
		row = 2
		count = 8
	if state != next:
		state = next
		elapsed = 0.0
	else:
		elapsed += delta
	var frame := int(elapsed * fps) % count
	if state == "attack":
		# Map visual anticipation/contact to the EXISTING damage boundary.
		if actor.telegraph_left > 0.0:
			frame = mini(7, int((1.0 - actor.telegraph_left / actor.attack_windup) * 8.0))
		else:
			frame = mini(13, 8 + int(maxf(0.0, elapsed - actor.attack_windup) / actor.attack_recovery * 6.0))
	elif state == "death":
		frame = mini(count - 1, int(elapsed * fps))
	sprite.texture = frames[row * 14 + frame]
	if is_instance_valid(actor.target) and not actor.dead:
		sprite.flip_h = actor.target.global_position.x < actor.global_position.x
		# Sprite2D mirrors around the canvas center, not the authored foot pivot.
		sprite.position.x = -192.0 if sprite.flip_h else -64.0
	bar.sync_health(actor.hp, actor.max_hp)
