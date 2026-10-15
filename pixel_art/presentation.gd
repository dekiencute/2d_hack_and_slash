extends Node2D
## Opt-in presentation adapter. Core scenes, animation tracks and combat scripts stay intact.
const FOREST = preload("res://pixel_art/forest_layers.tscn")
const ENEMY_VISUAL = preload("res://pixel_art/enemy_visual.gd")
const HEALTH_BAR = preload("res://pixel_art/health_bar.gd")
const SHEETS := {
	"idle": "Idle", "run": "Run", "jumpandfall": "JumpAndFall", "dash": "Dash",
	"die": "Die", "groundcombo1": "GroundCombo1", "groundcombo2": "GroundCombo2",
	"groundcombo3": "GroundCombo3", "aircombo1": "AirCombo1", "aircombo2": "AirCombo2",
	"aircombo3": "AirCombo3",
}
@export var pixel_player := true
@export var pixel_enemies := true
@export var pixel_ui := true
@export_enum("Base 1", "Base 0") var background_base := 0
var arena
var player
var hud
var forest: Node2D
var camera: Camera2D
var health: TextureProgressBar
var original_scale_mode: int
var last_view_size := Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	arena = get_parent()
	player = arena.get_node("Player")
	hud = arena.get_node("HUD")
	original_scale_mode = get_window().content_scale_mode
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_viewport().snap_2d_transforms_to_pixel = true
	if pixel_player:
		_skin_player()
	if pixel_enemies:
		arena.get_node("Enemies").child_entered_tree.connect(_enemy_added)
	forest = FOREST.instantiate()
	forest.name = "Forest"
	forest.position = Vector2(688, 350)
	forest.scale = Vector2(2, 2)
	forest.z_index = -100
	add_child(forest)
	forest.get_node("Backdrop0/Base").visible = background_base == 1
	forest.get_node("Backdrop1/Base").visible = background_base == 0
	arena.get_node("Environment").hide()
	var previous_camera: Camera2D = player.get_node("Camera2D")
	previous_camera.enabled = false
	previous_camera.set_process(false)
	camera = Camera2D.new()
	camera.name = "PixelCamera"
	camera.position_smoothing_enabled = false
	add_child(camera)
	camera.make_current()
	# HUD is built by its own _ready before this sibling adapter runs.
	if pixel_ui:
		health = HEALTH_BAR.new()
		health.name = "PixelHealth"
		health.position = Vector2(40, 85)
		health.scale = Vector2(3, 3)
		hud.root.add_child(health)
		hud.root.move_child(health, hud.overlay.get_index())
		for child in hud.root.get_children():
			if child is Label and child.text.begins_with("MIX MOVES"):
				child.position.y = 128
		hud.hp_bar.hide()
		player.health_changed.connect(health.sync_health)
		health.sync_health(player.hp, player.max_hp)
	_update_camera()
	_layout_hud()
	# Parent _ready sets the title after children have initialized.
	_review_title.call_deferred()

func _review_title() -> void:
	hud.menu_body.text = hud.menu_body.text.replace(
		"Original art & synthesized SFX", "Pixel-art review · Licenses pending · Synthesized SFX")

func _skin_player() -> void:
	var sprite: AnimatedSprite2D = player.sprite
	var frames := sprite.sprite_frames.duplicate(true) as SpriteFrames
	for animation in frames.get_animation_names():
		for frame in range(frames.get_frame_count(animation)):
			var texture := frames.get_frame_texture(animation, frame) as AtlasTexture
			var sheet_name := texture.atlas.resource_path.get_file().get_basename().trim_prefix("player_")
			assert(SHEETS.has(sheet_name), "Unmapped original player atlas: " + sheet_name)
			texture.atlas = load("res://assets/Art/Character/" + SHEETS[sheet_name] + ".png")
	var animation := sprite.animation
	var current_frame := sprite.frame
	sprite.sprite_frames = frames
	sprite.animation = animation
	sprite.frame = current_frame
	sprite.scale = Vector2(2, 2)
	sprite.position = Vector2(0, -48)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _enemy_added(enemy: Node) -> void:
	_skin_enemy.call_deferred(enemy)

func _skin_enemy(enemy: Node) -> void:
	if not is_instance_valid(enemy) or not enemy.is_inside_tree():
		return
	var visual := ENEMY_VISUAL.new()
	visual.name = "PixelVisual"
	enemy.add_child(visual)

func _process(_delta: float) -> void:
	_update_camera()
	_layout_hud()

func _layout_hud() -> void:
	var size := get_viewport_rect().size
	if size == last_view_size:
		return
	# Existing controls are repositioned rather than fractionally scaling UI pixels.
	var change := size - (Vector2(1280, 720) if last_view_size == Vector2.ZERO else last_view_size)
	for child in hud.root.get_children():
		if child == hud.overlay:
			for panel in child.get_children():
				if not panel is ColorRect:
					panel.position += change / 2.0
		elif child is Control:
			if child.position.y >= (647.0 if last_view_size == Vector2.ZERO else last_view_size.y - 73.0):
				child.position.y += change.y
				if child is Panel:
					child.size.x = size.x - 48.0
			elif child.position.x >= (1010.0 if last_view_size == Vector2.ZERO else last_view_size.x - 270.0):
				child.position.x += change.x
			if child is Label and child.text.begins_with("A / D  Move"):
				child.text = "A / D  Move · SPACE  Jump ×2 · SHIFT  Dash · J  Light · K  Heavy · R  Retry · ESC  Pause"
				child.add_theme_font_size_override("font_size", 13)
				child.size.x = size.x - 200.0
	hud.sound_button.position.x = size.x - 158.0
	hud.message_label.position.x = (size.x - hud.message_label.size.x) / 2.0
	last_view_size = size

func _update_camera() -> void:
	var size := get_viewport_rect().size
	var integer_zoom := maxf(1.0, ceilf(maxf(size.x / 1280.0, size.y / 720.0)))
	camera.zoom = Vector2.ONE * integer_zoom
	var half_view := size / integer_zoom / 2.0
	var target: Vector2 = player.position + Vector2(0, -220)
	camera.position = target.clamp(Vector2(-240, -830) + half_view, Vector2(1616, 756) - half_view).round()
	var relative_camera := (camera.position - Vector2(688, 396)) / 2.0
	forest.sync_camera_offset(relative_camera)

func _exit_tree() -> void:
	get_window().content_scale_mode = original_scale_mode
