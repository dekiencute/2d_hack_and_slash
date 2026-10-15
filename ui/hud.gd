extends CanvasLayer

signal start_requested
signal restart_requested
signal pause_requested

const INK := Color("101d2d")
const PAPER := Color("e0eeec")
const TEAL := Color("69ded0")
const GOLD := Color("f1c77c")
var root: Control
var hp_bar: ProgressBar
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

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_panel(Rect2(24, 24, 300, 134), root)
	_label("BREAKER  /  VITALS", Rect2(40, 34, 250, 22), 14, TEAL)
	hp_label = _label("100 / 100", Rect2(40, 58, 260, 25), 19)
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(40, 91)
	hp_bar.size = Vector2(266, 10)
	hp_bar.show_percentage = false
	hp_bar.add_theme_stylebox_override("background", _style(Color("273c4c")))
	hp_bar.add_theme_stylebox_override("fill", _style(TEAL))
	root.add_child(hp_bar)
	_label("MIX MOVES. BREAK THE PATTERN.", Rect2(40, 115, 270, 22), 13, Color("8caaaF"))
	_panel(Rect2(1010, 24, 246, 168), root)
	wave_label = _label("WAVE  0 / 5", Rect2(1030, 37, 210, 30), 22, PAPER)
	enemy_label = _label("0 SENTINELS", Rect2(1030, 71, 210, 23), 15, TEAL)
	style_label = _label("STYLE  D", Rect2(1030, 106, 210, 35), 29, GOLD)
	score_label = _label("0000  POINTS", Rect2(1030, 149, 210, 23), 14, PAPER)
	message_label = _label("", Rect2(360, 125, 560, 100), 30, GOLD)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel(Rect2(24, 647, 1232, 49), root)
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
	_panel(Rect2(176, 76, 928, 562), overlay)
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
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent else root).add_child(label)
	return label

func _style(color: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style

func _panel(rect: Rect2, parent: Control) -> void:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(INK, Color("33515c")))
	parent.add_child(panel)

func _button(text: String, rect: Rect2, parent: Control) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", PAPER)
	button.add_theme_stylebox_override("normal", _style(Color("1b3947"), Color("4b8c8c")))
	button.add_theme_stylebox_override("hover", _style(Color("2c5661"), TEAL))
	button.add_theme_stylebox_override("pressed", _style(Color("366770"), TEAL))
	button.add_theme_stylebox_override("focus", _style(Color(0, 0, 0, 0), GOLD))
	parent.add_child(button)
	return button

func show_title() -> void:
	menu_kind = "title"
	menu_title.text = "STYLEBREAKER"
	menu_body.text = "Five waves. One arena. Make every hit count.\n\nA / D  Move     SPACE  Double jump     SHIFT  Invulnerable dash\nJ  Light combo     K  Launcher / Air heavy     R  Restart\nPad: Left stick · A Jump · B Dash · X Light · Y Heavy · Start Pause\n\nTry: J → J → K → Jump → J → J → K\nGold rings warn of strikes. Dash through danger; vary moves for Style.\n\nOriginal art & synthesized SFX · No music · F11 Fullscreen · M Mute"
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
	enemy_label.text = "%d SENTINELS" % count

func set_message(text: String) -> void:
	message_label.text = text
	message_label.visible = not text.is_empty()

func _on_style_changed(rank: String, score: float) -> void:
	style_label.text = "STYLE  %s" % rank
	score_label.text = "%04d  POINTS" % int(score)
