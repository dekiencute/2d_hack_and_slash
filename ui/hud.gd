extends CanvasLayer

signal start_requested
signal restart_requested
signal pause_requested

const PAPER := Color("e0eeec")
const TEAL := Color("69ded0")
const GOLD := Color("f1c77c")
var root: Control
var hp_bar: TextureProgressBar
var hp_label: Label
var style_label: Label
var score_label: Label
var wave_label: Label
var enemy_label: Label
var message_label: Label
var overlay: Control
var menu_title: Label
var menu_body: Label
var menu_button: Button
var sound_button: Button
var menu_kind := "title"
var last_view_size := Vector2.ZERO
const HEALTH_BAR = preload("res://pixel_art/health_bar.gd")

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_label("BREAKER  /  VITALS", Rect2(40, 34, 250, 22), 14, TEAL)
	hp_label = _label("100 / 100", Rect2(40, 58, 260, 25), 19)
	hp_bar = HEALTH_BAR.new()
	hp_bar.position = Vector2(40, 85)
	hp_bar.scale = Vector2(3, 3)
	root.add_child(hp_bar)
	_label("MIX MOVES. BREAK THE PATTERN.", Rect2(40, 128, 270, 22), 13, Color("8caaaF"))
	wave_label = _label("WAVE  0 / 5", Rect2(1030, 37, 210, 30), 22, PAPER)
	enemy_label = _label("0 ENEMIES", Rect2(1030, 71, 210, 23), 15, TEAL)
	style_label = _label("STYLE  D", Rect2(1030, 106, 210, 35), 29, GOLD)
	score_label = _label("0000  POINTS", Rect2(1030, 149, 210, 23), 14, PAPER)
	message_label = _label("", Rect2(360, 125, 560, 100), 30, GOLD)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label("A / D  Move     SPACE  Jump ×2     SHIFT  Dash     J  Light     K  Heavy     R  Retry     ESC  Pause", Rect2(40, 657, 1060, 26), 16)
	sound_button = _button("SFX ON  [M]", Rect2(1122, 654, 120, 32), root)
	sound_button.pressed.connect(_toggle_sound)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.05, 0.085, 0.93)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	_label("COMBAT LAB    /    01                   PRE-ALPHA · 15 OCT 2026", Rect2(224, 107, 840, 26), 15, TEAL, overlay)
	menu_title = _label("STYLEBREAKER", Rect2(220, 158, 840, 74), 59, PAPER, overlay)
	menu_body = _label("", Rect2(224, 255, 840, 270), 19, PAPER, overlay)
	menu_button = _button("ENTER THE ARENA", Rect2(224, 551, 350, 53), overlay)
	menu_button.pressed.connect(_activate_menu)
	var quit_button := _button("QUIT", Rect2(924, 551, 130, 53), overlay)
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	show_title()
	var style := get_tree().get_first_node_in_group("style_system")
	if style:
		style.style_changed.connect(_on_style_changed)
		_on_style_changed(style.get_rank(), style.score)

func _label(text: String, rect: Rect2, font_size: int, color: Color = PAPER, parent: Control = null) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent else root).add_child(label)
	return label

func _button(text: String, rect: Rect2, parent: Control) -> Button:
	var button := Button.new()
	button.text = text
	button.flat = true
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	button.add_theme_color_override("font_hover_color", GOLD)
	button.add_theme_color_override("font_focus_color", GOLD)
	button.add_theme_color_override("font_outline_color", Color.BLACK)
	button.add_theme_constant_override("outline_size", 3)
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", PAPER)
	parent.add_child(button)
	return button

func show_title() -> void:
	menu_kind = "title"
	menu_title.text = "STYLEBREAKER"
	menu_body.text = "Five waves. One arena. Make every hit count.\n\nA / D  Move     SPACE  Double jump     SHIFT  Invulnerable dash\nJ  Light combo     K  Launcher / Air heavy     R  Restart\nPad: Left stick · A Jump · B Dash · X Light · Y Heavy · Start Pause\n\nTry: J → J → K → Jump → J → J → K\n! STRIKE ! text warns of attacks. Dash through danger; vary moves for Style.\n\nPixel art · Synthesized SFX · No music · F11 Fullscreen · M Mute"
	menu_button.text = "ENTER THE ARENA   [ENTER / A]"
	overlay.show()
	menu_button.grab_focus()

func show_pause() -> void:
	menu_kind = "pause"
	menu_title.text = "TAKE A BREATHER"
	menu_body.text = "The arena is paused.\n\nA / D or Left stick  Move\nSPACE / A  Jump twice       SHIFT / B  Invulnerable dash\nJ / X  Light combo             K / Y  Launcher or air heavy\n\nR / Back  Restart       ESC / Start  Resume\nM  Mute SFX       F11  Fullscreen\n\nMix your moves. Repetition earns less Style."
	menu_button.text = "RESUME   [ENTER / A]"
	overlay.show()
	menu_button.grab_focus()

func hide_menu() -> void:
	menu_kind = ""
	overlay.hide()
	menu_button.release_focus()

func show_result(won: bool, health: float, peak: float, elapsed: float) -> void:
	menu_kind = "result"
	menu_title.text = "ARENA CLEAR" if won else "BREAKER DOWN"
	menu_body.text = ("All five waves defeated." if won else "The arena got the upper hand. Try a dash to escape a strike.")
	menu_body.text += "\n\nPeak Style score     %04d\nHealth remaining    %d / 100\nRun time                    %02d:%02d\n\nThanks for playing this small pre-alpha.\nNext run: vary light, launcher, and aerial attacks to build Style." % [int(peak), int(health), int(elapsed) / 60, int(elapsed) % 60]
	menu_button.text = "TRY AGAIN   [ENTER / A / R]"
	overlay.show()
	menu_button.grab_focus()

func _activate_menu() -> void:
	match menu_kind:
		"title": start_requested.emit()
		"pause": pause_requested.emit()
		"result": restart_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("reset") and menu_kind != "title":
		restart_requested.emit()
	elif event.is_action_pressed("pause") and menu_kind in ["", "pause"]:
		pause_requested.emit()
	elif event.is_action_pressed("mute"):
		_toggle_sound()
	elif event.is_action_pressed("fullscreen"):
		var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		return
	get_viewport().set_input_as_handled()

func _toggle_sound() -> void:
	var feedback := get_tree().get_first_node_in_group("combat_feedback")
	if feedback:
		var muted: bool = feedback.toggle_mute()
		sound_button.text = "SFX OFF [M]" if muted else "SFX ON  [M]"

func set_player_hp(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "%d / %d" % [int(ceil(current)), int(maximum)]

func set_wave(current: int, total: int) -> void:
	wave_label.text = "WAVE  %d / %d" % [current, total]

func set_enemies(count: int) -> void:
	enemy_label.text = "%d ENEMIES" % count

func set_message(text: String) -> void:
	message_label.text = text
	message_label.visible = not text.is_empty()

func _on_style_changed(rank: String, score: float) -> void:
	style_label.text = "STYLE  %s" % rank
	score_label.text = "%04d  POINTS" % int(score)

func _process(_delta: float) -> void:
	var size := get_viewport().get_visible_rect().size
	if size == last_view_size:
		return
	# Existing controls are repositioned rather than fractionally scaling UI pixels.
	var change := size - (Vector2(1280, 720) if last_view_size == Vector2.ZERO else last_view_size)
	for child in root.get_children():
		if child == overlay:
			for panel in child.get_children():
				if not panel is ColorRect:
					panel.position += change / 2.0
		elif child is Control:
			if child.position.y >= (647.0 if last_view_size == Vector2.ZERO else last_view_size.y - 73.0):
				child.position.y += change.y
			elif child.position.x >= (1010.0 if last_view_size == Vector2.ZERO else last_view_size.x - 270.0):
				child.position.x += change.x
			if child is Label and child.text.begins_with("A / D  Move"):
				child.text = "A / D  Move · SPACE  Jump ×2 · SHIFT  Dash · J  Light · K  Heavy · R  Retry · ESC  Pause"
				child.add_theme_font_size_override("font_size", 13)
				child.size.x = size.x - 200.0
	sound_button.position.x = size.x - 158.0
	message_label.position.x = (size.x - message_label.size.x) / 2.0
	last_view_size = size
