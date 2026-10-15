# Stylebreaker — Pre-Alpha v0.1.0

Godot **4.6.3** pixel-art hack-and-slash prototype. Open `project.godot` and press **F5** to run `res://pixel_art/arena.tscn`, the standalone main scene. The approved uploaded pixel art is the only game presentation.

A/D moves; Space double-jumps; Shift dashes; J chains light attacks; K launches or slams; Esc pauses; R restarts; M mutes; F11 toggles fullscreen. Xbox-style controller: left stick, A jump/confirm, B dash, X light, Y heavy, Start pause, Back restart. Clear five waves (**2 / 3 / 3 / 4 / 5**) and vary attacks for Style. `! STRIKE !` text and enemy tint warn of attacks.

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script tests/regression.gd
godot --headless --path . --script tests/pixel_art_validation.gd
godot --headless --path . --script tests/release_controls_validation.gd
python3 tools/check_pixel_only.py
python tools/release.py
```

The normal Windows Desktop preset exports the approved pixel runtime. Build a validated Windows ZIP with `python tools/release.py`; on Windows PowerShell use `py -3 .\tools\release.py`. Godot 4.6.3 and matching official templates are required. Godot can be on PATH, selected with `GODOT_BIN`, or passed via `--godot`. See [Windows export instructions](docs/WINDOWS_EXPORT.md) for installation, executable/template paths, outputs and technical checks.

Incomplete character/enemy/UI license evidence produces warnings and is included in the package reports; it does **not** stop exports. Forest compiled-game permission and required credit are documented. Verification statuses and creator credits remain unchanged; a successful build does not certify redistribution rights. Native Windows playtesting remains pending. No automatic merge, upload or publication.

[Cleanup inventory and validation](docs/CLEANUP_REPORT.md) · [Asset rights](docs/RC_ASSET_LICENSE_REPORT.md) · [Credits](docs/RC_CREDITS.txt) · [Player instructions](docs/PLAYER_README.txt)
