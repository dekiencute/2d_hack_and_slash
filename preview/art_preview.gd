extends Control
## Run this scene with F6. No gameplay scene, actor, animation tree, or autoload is used.
const CANVAS := preload("res://preview/preview_canvas.gd")
const CATALOG := "res://preview/art_catalog.json"
const CATEGORIES := ["Character", "Enemy", "UI", "Source"]
var catalog: Dictionary = {}
var entries: Array = []
var visible_entries: Array = []
var selected: Dictionary = {}
var current_texture: Texture2D
var texture_cache: Dictionary = {}
var frame_index := 0
var playing := false
var accumulator := 0.0
var load_errors: Array[String] = []
var category: OptionButton
var search: LineEdit
var asset_list: ItemList
var asset_title: Label
var asset_path: LineEdit
var details: RichTextLabel
var status: Label
var play_button: Button
var frame_label: Label
var frame_slider: HSlider
var fps: SpinBox
var zoom: SpinBox
var mode: OptionButton
var backdrop: OptionButton
var mirror: CheckBox
var borders: CheckBox
var loop: CheckBox
var canvas: Control
var stage_scroll: ScrollContainer

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
	if not parsed is Dictionary or not parsed.has("entries"):
		push_error("Asset preview catalog is missing or invalid: " + CATALOG)
		return
	catalog = parsed
	entries = catalog.entries
	_build_ui()
	_refilter()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("111924")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 16)
	add_child(margin)
	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	margin.add_child(main)
	var title := Label.new()
	title.text = "ART ASSET PREVIEW   /   inspection only"
	title.add_theme_font_size_override("font_size", 25)
	main.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Original uploads • No gameplay integration • Nearest filtering • Integer zoom • No new art"
	main.add_child(subtitle)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	main.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 285
	body.add_child(left)
	category = OptionButton.new()
	for item in ["Characters (19)", "Enemy (8 animations)", "Pixel UI (19 images)", "Source / references (8)"]:
		category.add_item(item)
	category.item_selected.connect(func(_index: int) -> void: _refilter())
	left.add_child(category)
	search = LineEdit.new()
	search.placeholder_text = "Filter asset names…"
	search.text_changed.connect(func(_text: String) -> void: _refilter())
	left.add_child(search)
	asset_list = ItemList.new()
	asset_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	asset_list.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	asset_list.item_selected.connect(_select_visible)
	left.add_child(asset_list)
	var help := Label.new()
	help.text = "F6: run this scene\nSpace: play/pause\nLeft / Right: step a frame\nUse scrollbars for large sheets."
	help.add_theme_font_size_override("font_size", 13)
	left.add_child(help)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	asset_title = Label.new()
	asset_title.add_theme_font_size_override("font_size", 21)
	asset_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	right.add_child(asset_title)
	asset_path = LineEdit.new()
	asset_path.editable = false
	asset_path.add_theme_font_size_override("font_size", 12)
	right.add_child(asset_path)
	var row := HBoxContainer.new()
	right.add_child(row)
	play_button = _button("Pause", row, _toggle_play)
	_button("Prev", row, func() -> void: step_frame(-1))
	_button("Next", row, func() -> void: step_frame(1))
	_label("FPS", row)
	fps = _spin(1, 60, 8, row)
	fps.value_changed.connect(func(_value: float) -> void: accumulator = 0.0)
	_label("Zoom", row)
	zoom = _spin(1, 8, 4, row)
	zoom.value_changed.connect(func(_value: float) -> void: _refresh_canvas())
	mode = OptionButton.new()
	for item in ["Animation frame", "Whole sheet", "Alpha bounds (UI)"]:
		mode.add_item(item)
	mode.item_selected.connect(func(_index: int) -> void: _refresh_canvas())
	row.add_child(mode)
	var second := HBoxContainer.new()
	right.add_child(second)
	backdrop = OptionButton.new()
	for item in ["Checkerboard", "Dark", "Light"]:
		backdrop.add_item(item)
	backdrop.item_selected.connect(func(_index: int) -> void: _refresh_canvas())
	second.add_child(backdrop)
	mirror = _check("Flip horizontally", false, second)
	borders = _check("Cell borders", true, second)
	loop = _check("Loop preview", true, second)
	stage_scroll = ScrollContainer.new()
	stage_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_scroll.custom_minimum_size.y = 190
	right.add_child(stage_scroll)
	canvas = CANVAS.new()
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_scroll.add_child(canvas)
	stage_scroll.get_h_scroll_bar().value_changed.connect(func(_value: float) -> void: canvas.queue_redraw())
	stage_scroll.get_v_scroll_bar().value_changed.connect(func(_value: float) -> void: canvas.queue_redraw())
	var frame_row := HBoxContainer.new()
	right.add_child(frame_row)
	frame_label = _label("Frame", frame_row)
	frame_label.custom_minimum_size.x = 175
	frame_slider = HSlider.new()
	frame_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame_slider.step = 1
	frame_slider.value_changed.connect(_scrub)
	frame_row.add_child(frame_slider)
	details = RichTextLabel.new()
	details.custom_minimum_size.y = 160
	details.bbcode_enabled = false
	details.selection_enabled = true
	details.add_theme_font_size_override("normal_font_size", 14)
	right.add_child(details)
	status = Label.new()
	status.text = "Preview only: no asset pack includes a redistribution license. Review docs/ART_ASSET_REVIEW_2026-10-15.md."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_color_override("font_color", Color("e6bd77"))
	status.add_theme_font_size_override("font_size", 13)
	main.add_child(status)

func _label(text: String, parent: Node) -> Label:
	var label := Label.new()
	label.text = text
	parent.add_child(label)
	return label

func _button(text: String, parent: Node, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _spin(low: int, high: int, initial: int, parent: Node) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = low
	spin.max_value = high
	spin.step = 1
	spin.value = initial
	spin.custom_minimum_size.x = 82
	parent.add_child(spin)
	return spin

func _check(text: String, checked: bool, parent: Node) -> CheckBox:
	var checkbox := CheckBox.new()
	checkbox.text = text
	checkbox.button_pressed = checked
	checkbox.toggled.connect(func(_value: bool) -> void: _refresh_canvas())
	parent.add_child(checkbox)
	return checkbox

func _refilter() -> void:
	visible_entries.clear()
	asset_list.clear()
	for entry in entries:
		if entry.category == CATEGORIES[category.selected] and (search.text.is_empty() or entry.name.to_lower().contains(search.text.to_lower())):
			visible_entries.append(entry)
			var suffix := "  [review export]" if entry.technical_status.begins_with("Source/export") else ""
			asset_list.add_item(entry.name + suffix)
			asset_list.set_item_tooltip(asset_list.item_count - 1, entry.path)
	if not visible_entries.is_empty():
		asset_list.select(0)
		_select_visible(0)
	else:
		selected = {}
		playing = false
		current_texture = null
		asset_title.text = "No matching assets"
		asset_path.text = ""
		details.text = "Clear the filter or choose another category."
		play_button.disabled = true
		frame_slider.editable = false
		frame_label.text = "No frames"
		_refresh_canvas()

func _select_visible(index: int) -> void:
	select_entry(visible_entries[index])

func select_entry(entry: Dictionary) -> void:
	selected = entry
	for index in range(visible_entries.size()):
		if visible_entries[index].id == entry.id:
			asset_list.select(index)
			asset_list.ensure_current_is_visible()
			break
	frame_index = 0
	accumulator = 0
	playing = entry.frames_count > 1
	fps.value = entry.fps
	asset_title.text = "%s  /  %s" % [entry.category, entry.name]
	asset_path.text = entry.path
	current_texture = null
	if not entry.frames.is_empty():
		if not texture_cache.has(entry.path):
			var texture := load(entry.path) as Texture2D
			if texture:
				texture_cache[entry.path] = texture
			else:
				load_errors.append(entry.path)
		current_texture = texture_cache.get(entry.path)
	frame_slider.max_value = maxi(0, entry.frames_count - 1)
	frame_slider.editable = entry.frames_count > 1
	mode.set_item_disabled(2, entry.category != "UI")
	mode.select(0)
	stage_scroll.scroll_horizontal = 0
	stage_scroll.scroll_vertical = 0
	play_button.disabled = entry.frames_count < 2
	details.text = "%d × %d px | %d PNG preview frame(s) | cells: %s\n%s\n%s\nTiming: %s\nLICENSE: %s" % [entry.dimensions[0], entry.dimensions[1], entry.frames_count, str(entry.cell) if entry.has("cell") else "source only", entry.technical_status, entry.note, entry.fps_basis, entry.license_status]
	_refresh_canvas()

func _region(values: Array) -> Rect2i:
	return Rect2i(int(values[0]), int(values[1]), int(values[2]), int(values[3]))

func displayed_region() -> Rect2i:
	if selected.is_empty() or current_texture == null:
		return Rect2i()
	if mode.selected == 1:
		return Rect2i(0, 0, selected.dimensions[0], selected.dimensions[1])
	if mode.selected == 2 and selected.has("alpha_region"):
		return _region(selected.alpha_region)
	return _region(selected.frames[frame_index])

func _refresh_canvas() -> void:
	if canvas == null:
		return
	var cell_size := Vector2i.ZERO
	if not selected.is_empty() and selected.has("cell"):
		cell_size = Vector2i(selected.cell[0], selected.cell[1])
	canvas.configure(current_texture, displayed_region(), cell_size, int(zoom.value), borders.button_pressed, mirror.button_pressed, backdrop.selected)
	play_button.text = "Pause" if playing else "Play"
	if not selected.is_empty():
		frame_label.text = "Frame %d / %d (0-based)" % [frame_index, maxi(0, selected.frames_count - 1)] if current_texture else "Source metadata only"
	frame_slider.set_value_no_signal(frame_index)

func _toggle_play() -> void:
	if selected.is_empty() or selected.frames_count < 2:
		return
	playing = not playing
	_refresh_canvas()

func _scrub(value: float) -> void:
	playing = false
	frame_index = int(value)
	_refresh_canvas()

func step_frame(direction: int) -> void:
	if selected.is_empty() or selected.frames_count < 1:
		return
	playing = false
	frame_index = posmod(frame_index + direction, int(selected.frames_count))
	_refresh_canvas()

func _process(delta: float) -> void:
	if not playing or selected.is_empty() or selected.frames_count < 2:
		return
	accumulator += delta * fps.value
	if accumulator < 1.0:
		return
	var advance := int(accumulator)
	accumulator -= advance
	var next := frame_index + advance
	if not loop.button_pressed and next >= selected.frames_count:
		frame_index = selected.frames_count - 1
		playing = false
	else:
		frame_index = next % int(selected.frames_count)
	_refresh_canvas()

func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if get_viewport().gui_get_focus_owner() is LineEdit or get_viewport().gui_get_focus_owner() is SpinBox:
		return
	if event is InputEventKey and event.physical_keycode == KEY_SPACE:
		_toggle_play()
	elif event.is_action_pressed("ui_left"):
		step_frame(-1)
	elif event.is_action_pressed("ui_right"):
		step_frame(1)
	else:
		return
	get_viewport().set_input_as_handled()
