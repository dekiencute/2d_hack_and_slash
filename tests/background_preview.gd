extends Node2D
## Standalone inspection scene. Uses uploaded PNGs only; no combat dependencies.
const PAN_LIMIT := Vector2(128, 16)
const MANUAL_SPEED := Vector2(100, 35)
@export var automatic_pan := true
@export var parallax_enabled := true
@onready var camera: Camera2D = $Camera2D
@onready var far_lights: Sprite2D = $Layers/Distance3/Lights
@onready var near_lights: Sprite2D = $Layers/Distance5/Lights
var phase := 0.0
var desired_camera := Vector2.ZERO
var authored_scales: Dictionary = {}
var hud: CanvasLayer
var controls: Control
var readout: Label
var auto_button: CheckBox
var parallax_button: CheckBox
var far_button: CheckBox
var near_button: CheckBox
var backdrop: OptionButton

func _ready() -> void:
	# Runtime-local preview framing; never write to project.godot or the main scene.
	# Disable window resampling so nearest pixels map to an integer number of pixels.
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	RenderingServer.viewport_set_snap_2d_transforms_to_pixel(get_viewport().get_viewport_rid(), true)
	for layer in $Layers.get_children():
		authored_scales[layer.name] = layer.scroll_scale
	_build_hud()
	get_viewport().size_changed.connect(_update_zoom)
	_update_zoom()
	set_parallax_enabled(parallax_enabled)

func _update_zoom() -> void:
	var viewport_size := get_viewport_rect().size
	var integer_zoom := maxf(1.0, ceilf(maxf(viewport_size.x / 640.0, viewport_size.y / 360.0)))
	camera.zoom = Vector2.ONE * integer_zoom
	_sync_parallax_camera()

func _physics_process(delta: float) -> void:
	var axis := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	if axis != Vector2.ZERO:
		set_automatic_pan(false)
		desired_camera += axis * MANUAL_SPEED * delta
	elif automatic_pan:
		phase += delta
		desired_camera = Vector2(sin(phase * 0.45) * PAN_LIMIT.x, sin(phase * 0.65) * PAN_LIMIT.y)
	set_camera_offset(desired_camera)

func set_camera_offset(offset: Vector2) -> void:
	desired_camera = offset.clamp(-PAN_LIMIT, PAN_LIMIT)
	camera.position = desired_camera.round()
	camera.force_update_scroll()
	_sync_parallax_camera()
	if readout:
		readout.text = "Camera (%d, %d)  •  %d× integer zoom  •  bounded, non-repeating layers" % [int(camera.position.x), int(camera.position.y), int(camera.zoom.x)]

func set_automatic_pan(enabled: bool) -> void:
	automatic_pan = enabled
	if auto_button:
		auto_button.set_pressed_no_signal(enabled)

func set_parallax_enabled(enabled: bool) -> void:
	parallax_enabled = enabled
	for layer in $Layers.get_children():
		var original: Vector2 = authored_scales.get(layer.name, layer.scroll_scale)
		layer.scroll_scale = original if enabled or original == Vector2.ZERO else Vector2.ONE
	_sync_parallax_camera()
	if parallax_button:
		parallax_button.set_pressed_no_signal(enabled)

func _sync_parallax_camera() -> void:
	# Finite, full-canvas layers share a world origin. Feed this scene's camera
	# offset to Parallax2D explicitly instead of its viewport-top-left offset.
	for layer in $Layers.get_children():
		# Refresh scroll-scale changes even when the camera is stationary.
		layer.screen_offset = camera.position + Vector2.ONE
		layer.screen_offset = camera.position

func set_lights_visible(far_visible: bool, near_visible: bool) -> void:
	far_lights.visible = far_visible
	near_lights.visible = near_visible
	far_button.set_pressed_no_signal(far_visible)
	near_button.set_pressed_no_signal(near_visible)

func select_backdrop(index: int) -> void:
	$Layers/Backdrop0/Base.visible = index == 1
	$Layers/Backdrop1/Base.visible = index == 0
	backdrop.select(index)

func reset_camera() -> void:
	set_automatic_pan(false)
	phase = 0.0
	set_camera_offset(Vector2.ZERO)

func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.layer = 20
	add_child(hud)
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	controls = panel
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.10, 0.88)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	hud.add_child(panel)
	var stack := VBoxContainer.new()
	panel.add_child(stack)
	var title := Label.new()
	title.text = "UPLOADED BACKGROUND / PARALLAX PREVIEW"
	title.add_theme_font_size_override("font_size", 18)
	stack.add_child(title)
	var help := Label.new()
	help.text = "WASD / Arrows: pan   Space: auto   R: center   P: parallax   L: lights   B: base   H: hide UI"
	help.add_theme_font_size_override("font_size", 13)
	stack.add_child(help)
	var row := HBoxContainer.new()
	stack.add_child(row)
	auto_button = _checkbox("Auto pan", automatic_pan, row)
	auto_button.toggled.connect(set_automatic_pan)
	parallax_button = _checkbox("Parallax", parallax_enabled, row)
	parallax_button.toggled.connect(set_parallax_enabled)
	far_button = _checkbox("Lights 0007", true, row)
	far_button.toggled.connect(func(value: bool) -> void: set_lights_visible(value, near_lights.visible))
	near_button = _checkbox("Lights 0004", true, row)
	near_button.toggled.connect(func(value: bool) -> void: set_lights_visible(far_lights.visible, value))
	backdrop = OptionButton.new()
	backdrop.add_item("Base 1 (opaque)")
	backdrop.add_item("Base 0 (opaque)")
	backdrop.item_selected.connect(select_backdrop)
	row.add_child(backdrop)
	var reset := Button.new()
	reset.text = "Center"
	reset.pressed.connect(reset_camera)
	row.add_child(reset)
	readout = Label.new()
	readout.add_theme_font_size_override("font_size", 13)
	stack.add_child(readout)

func _checkbox(text: String, value: bool, parent: Node) -> CheckBox:
	var checkbox := CheckBox.new()
	checkbox.text = text
	checkbox.button_pressed = value
	parent.add_child(checkbox)
	return checkbox

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_SPACE:
			set_automatic_pan(not automatic_pan)
		KEY_R:
			reset_camera()
		KEY_P:
			set_parallax_enabled(not parallax_enabled)
		KEY_L:
			var enabled := not (far_lights.visible and near_lights.visible)
			set_lights_visible(enabled, enabled)
		KEY_B:
			select_backdrop(1 - backdrop.selected)
		KEY_H:
			controls.visible = not controls.visible
		_:
			return
	get_viewport().set_input_as_handled()
