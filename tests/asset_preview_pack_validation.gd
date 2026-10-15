extends SceneTree
## Run against an exported pack, with the catalog's absolute path as a user argument.
func _initialize() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 1:
		push_error("Provide the absolute art_catalog.json path after --")
		quit(1)
		return
	var catalog = JSON.parse_string(FileAccess.get_file_as_string(arguments[0]))
	var leaked: Array[String] = []
	var checked := 0
	for file in catalog.files:
		if file.format == "png":
			checked += 1
			if ResourceLoader.exists(file.path):
				leaked.append(file.path)
	for path in ["res://preview/art_preview.tscn", "res://preview/art_preview.gd", "res://preview/art_catalog.json"]:
		if ResourceLoader.exists(path) or FileAccess.file_exists(path):
			leaked.append(path)
	var gameplay_present := ResourceLoader.exists("res://levels/main.tscn") and ResourceLoader.exists("res://actors/player/player.tscn") and ResourceLoader.exists("res://actors/enemies/dummy_enemy.tscn")
	if not leaked.is_empty() or not gameplay_present or checked != 39:
		push_error("Export isolation failed; leaked=" + str(leaked) + ", gameplay present=" + str(gameplay_present))
		quit(1)
	else:
		print("PASS: exported gameplay resources remain present")
		print("PASS: all 39 uploaded PNGs and preview scene/scripts/catalog are excluded")
		quit(0)
