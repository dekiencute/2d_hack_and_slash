# Stylebreaker Prototype

A small Godot **4.6.3** 2D hack & slash pre-alpha: clear five waves of sentinels in one arena. Original geometric art, combat effects and synthesized SFX are included. No external art packs or Python packages are needed.

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
godot --headless --editor --path . --import
godot --headless --path . --script tests/regression.gd
python3 tools/release.py
```

The release script requires matching Windows and Linux x86_64 export templates. It builds a Windows candidate ZIP with embedded game data, credits and license notices; tests source gameplay, native Linux startup and the exact freshly extracted Windows resource pack under Linux Godot. It rejects script/resource errors even when Godot returns exit code zero. **It does not execute the Windows program.**

[Release gate and Windows/itch.io instructions](docs/ITCHIO_RELEASE_2026-10-15.md) · [Asset rights audit](docs/ASSET_AUDIT_2026-10-15.md) · [Player readme](docs/PLAYER_README.txt)

Native Windows playtesting and an itch.io upload/download check are still required before Public. Output under `builds/` and `dist/` is ignored by Git. The old unverified binaries were removed. One arena, one enemy type; no music, save, rebinding, guns, online features or progression.
