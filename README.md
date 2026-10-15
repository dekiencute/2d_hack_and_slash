# Stylebreaker — Pre-Alpha v0.1.0

A Godot **4.6.3** pixel-art 2D hack-and-slash pre-alpha: clear five waves in one forest arena. The owner-approved `pixel_art/arena.tscn` now starts with F5. The previous `levels/main.tscn` remains available with F6 or direct launch. No new artwork or mechanics were added by this release task.

**Release status: NOT READY.** Character/enemy/UI terms remain unverified; forest compiled-game use is documented with credit, while forest source-asset redistribution is prohibited. Native Windows playtesting is pending. The only new Windows artifact is private owner QA, not a public download. See [asset rights](docs/RC_ASSET_LICENSE_REPORT.md) and [latest private QA build](docs/ASSET_LICENSE_QA_REFRESH.md).

Open `project.godot` and press F5, then choose **Enter the arena**. Keyboard and Xbox-style controller mappings appear on the title screen. The combat retains its data-driven three-hit ground/air chains, launcher, aerial slam, input buffer, double jump, dash cancellation/invulnerability, juggling, hitstop and Style scoring. Wave counts remain **2 / 3 / 3 / 4 / 5**, with at most two attackers.

| Action | Keyboard | Controller |
|---|---|---|
| Move | A / D | Left stick |
| Jump / double jump | Space | A / South |
| Dash | Shift | B / East |
| Light combo | J | X / West |
| Launcher / air heavy | K | Y / North |
| Pause / resume | Escape | Start |
| Restart to title | R | Back / Select |
| Start / retry menu | Enter | A / South |
| Mute SFX / fullscreen | M / F11 | — |

Try `J → J → K → Jump → J → J → K`. Gold rings and `! STRIKE !` warn of enemy attacks. Vary moves for Style; repeated moves earn less and damage reduces it.

## Checks and release

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script tests/regression.gd
godot --headless --path . --script tests/regression.gd -- --scene res://levels/main.tscn
godot --headless --path . --script tests/pixel_art_validation.gd
# Fails closed until selected asset rights are verified:
python3 tools/release.py
# Owner review only, NOT FOR DISTRIBUTION:
python3 tools/release.py --private-qa
```

The script requires matching Windows/Linux x86_64 export templates, checks their recorded fingerprints, tests both arenas and previews, and uses selected assets in a temporary QA project. Committed public presets retain their quarantine; manual public exports are blocked from release approval while dependencies lack rights. ZIP checks cover every packaged file and the exact embedded Windows pack under Linux Godot. **No native Windows execution is claimed.**

[Release record](docs/RC_VALIDATION.md) · [Draft itch.io copy](docs/ITCHIO_PREALPHA_V0.1.0.md) · [Credits](docs/RC_CREDITS.txt) · [Player readme](docs/PLAYER_README.txt)

Native Windows playtesting and an itch.io upload/download check are still required before Public. Output under `builds/` and `dist/` is ignored by Git. The old unverified binaries were removed. One arena, one enemy type; no music, save, rebinding, guns, online features or progression.
