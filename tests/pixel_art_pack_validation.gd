extends SceneTree
## Run this external script against an exported PCK, with a source-path JSON manifest.
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Supply absolute manifest path after --")
		quit(1)
		return
	var paths = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	if not paths is Array or paths.size() < 51:
		push_error("Missing upload/integration manifest")
		quit(1)
		return
	var leaked: Array[String] = []
	for path in paths:
		if ResourceLoader.exists(path) or FileAccess.file_exists(path):
			leaked.append(path)
	var playable := ResourceLoader.exists("res://levels/main.tscn") and ResourceLoader.exists("res://actors/player/player.tscn") and ResourceLoader.exists("res://actors/enemies/dummy_enemy.tscn")
	if not leaked.is_empty() or not playable:
		push_error("Export isolation failed: " + str(leaked) + "; fallback present=" + str(playable))
		quit(1)
		return
	print("PASS: original playable arena resources remain present")
	print("PASS: all %d uploaded PNG/integration/preview paths are absent from exported pack" % paths.size())
	quit(0)
