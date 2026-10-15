extends SceneTree
## Render original itch.io cover at the recommended 630 × 500 size.
func _initialize() -> void:
	_render.call_deferred()

func _render() -> void:
	root.size = Vector2i(630, 500)
	root.content_scale_size = Vector2i(630, 500)
	var background := ColorRect.new()
	background.color = Color("101d2d")
	background.size = Vector2(630, 500)
	root.add_child(background)
	var emblem := TextureRect.new()
	emblem.texture = load("res://resources/original/icon.svg")
	emblem.position = Vector2(435, 49)
	emblem.size = Vector2(142, 142)
	root.add_child(emblem)
	text("STYLE", Vector2(42, 93), 79, Color("e0eeec"))
	text("BREAKER", Vector2(42, 173), 79, Color("e0eeec"))
	var line := ColorRect.new()
	line.color = Color("69ded0")
	line.position = Vector2(48, 292)
	line.size = Vector2(530, 4)
	root.add_child(line)
	text("FIVE WAVES. ONE ARENA.", Vector2(48, 326), 24, Color("f1c77c"))
	text("2D HACK & SLASH  /  PRE-ALPHA 0.1.0", Vector2(48, 368), 18, Color("b5cdcd"))
	text("15 OCT 2026", Vector2(48, 437), 15, Color("69ded0"))
	await process_frame
	await RenderingServer.frame_post_draw
	var output := ProjectSettings.globalize_path("res://docs/media/itch-cover-630x500.png")
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var result := root.get_texture().get_image().save_png(output)
	print("Cover render: ", error_string(result))
	quit(0 if result == OK else 1)

func text(value: String, at: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	root.add_child(label)
