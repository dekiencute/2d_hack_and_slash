# Stylebreaker — Pre-Alpha 0.1.0 release gate (15 October 2026)

Prepare a working Windows prototype for itch.io, marked **In development**. The candidate must remain **Draft/Restricted** until a native Windows extracted-archive playtest and download verification pass. No upload or publication was performed by this work.

## Implemented scope

- Existing move definitions, damage/timing, AnimationPlayer/AnimationTree architecture, five waves (`2 / 3 / 3 / 4 / 5`) and two-attacker cap preserved.
- Interrupted enemy windups cannot finish a newer attack or release its token. Interrupted warnings reset correctly; hit flash is now visible. Dead enemies cannot award additional hit-confirm style.
- Hitstop uses a scene-owned real-time countdown, freezes during pause and restores normal global speed when the scene exits. This also removes an orphaned timer warning reproduced by restarting mid-impact.
- Combat/wave timers pause with gameplay. Title/controls, pause, keyboard/controller retry, victory/defeat results, peak Style, health and run time are available. The camera's accidental air zoom-in is corrected; ground framing remains unchanged.
- Original masked fighter atlases, sentinel, arena, icon, line/arc combat VFX and seven synthesized SFX replace unclear asset packs. All original atlas regions are checked. New assets are CC0; [asset audit](ASSET_AUDIT_2026-10-15.md) and [removed-file inventory](REMOVED_ASSETS_2026-10-15.csv) record decisions.
- Single Windows x86_64 preset embeds its PCK. Linux preset is for validation. Matching Godot 4.6.3 templates are required. Source-only tooling and caches are excluded. Stale binaries are deleted and new outputs ignored by Git.
- Cover and actual Godot screenshots are in `docs/media`. Credits and engine/font notices are included in candidate ZIPs.

## Validation record

Commands and logs are recorded in `builds/logs` by `tools/release.py`. Refer to `docs/VALIDATION_2026-10-15.md` for the final run and limits.

| Gate | Status |
|---|---|
| Exact clone imports and main scene runs using Godot 4.6.3 | Verified by headless import, runtime checks and rendered X11/OpenGL run. |
| Scene/script/resource dependencies and animation atlas bounds | Automated regression checks; original AttackData files unchanged. |
| Shipped character/environment/audio redistribution rights | Original media, CC0; Godot MIT and engine/font notices bundled. Legacy packs excluded. |
| Five-wave progression, defeat/victory, restart, combat inputs and HUD | Automated physics/input/overlap integration tests plus rendered captures. Human balance playtest remains pending. |
| Windows release export | Candidate built with matching 4.6.3 templates; PE x86_64 structure and embedded PCK checked by release script. |
| Fresh ZIP extraction / Windows resource bundle | ZIP CRC/hash and extracted bundle gameplay checked under a Linux Godot engine. |
| **Native Windows executable starts outside editor, all five waves playable** | **BLOCKER — Windows/Wine unavailable in this environment. Do not treat Linux bundle tests as Windows execution.** |
| Physical controller, native GPU/audio/device behavior | **Pending manual Windows checks.** Mappings and rendered UI checked without hardware. |
| Upload / downloaded itch.io archive | **Pending.** Requires the verified candidate and itch.io account access. |

## Reproduce and build

1. Install **Godot 4.6.3 stable** and matching export templates from the official `godotengine/godot` 4.6.3-stable release. Install Windows x86_64 and Linux x86_64 templates through **Editor → Manage Export Templates**. This repository previously declared 4.7; the candidate is pinned to the version actually tested.
2. From the project directory run:

   ```sh
   godot --headless --editor --path . --import
   godot --headless --path . --script tests/regression.gd
   python3 tools/release.py
   ```

   The automated release script is intended for Linux validation. On Windows, import/run the tests using `godot_console.exe` or the installed Godot command, then export through **Project → Export → Windows Desktop → Export Project** with debug disabled. The preset writes `builds/windows/Stylebreaker.exe`. Keep credits/licenses with the executable when making a ZIP manually.
3. `tools/release.py` creates `dist/Stylebreaker-PreAlpha-0.1.0-windows-x86_64.zip`, its SHA-256 file, and logs. It checks errors in logs as well as exit codes. The PCK is embedded; no separate `.pck` should be uploaded.
4. Extract the ZIP on a native Windows x86_64 PC into a new directory. Open `Stylebreaker.exe` without the editor. Check no missing DLL/resources, black screen or crash; test movement, double jump, light chains, launcher/air attacks, dash, SFX/mute, controller, pause, F11 and R. Clear all five waves and trigger defeat/retry. Record OS/GPU/controller and results here before Public. The executable is unsigned and resource editing is disabled for reproducible Linux cross-export; its shell icon remains the default Godot executable icon.

## itch.io page and upload

- Title: **Stylebreaker Prototype — Pre-Alpha 0.1.0**. Kind: downloadable game. Platform: Windows. Status: **In development**. Keep Draft/Restricted while gates are open.
- Suggested description: “A compact 2D hack & slash combat prototype. Clear five waves, launch sentinels, continue the fight in the air, and mix attacks to build Style. Includes keyboard and Xbox-style controller mappings. One arena, one enemy type, original art and SFX. This pre-alpha has no music, saves or progression.”
- Use `docs/media/itch-cover-630x500.png` as the cover and the actual title/arena/combat captures as screenshots. Include the controls from `PLAYER_README.txt`; do not imply more content.
- Upload the verified ZIP and mark Windows. Preview the page, download the uploaded archive into a fresh directory, compare its SHA-256, launch it and repeat the short controls/retry check. Only then change visibility to Public.
- Optional Butler command after those checks and selecting your actual itch account/project: `butler push dist/Stylebreaker-PreAlpha-0.1.0-windows-x86_64.zip YOUR_ACCOUNT/YOUR_PROJECT:windows --userversion 0.1.0-prealpha.20261015`.

No required basic prototype asset is missing. Music, richer animation, extra enemies/arenas and other combat features remain outside scope. No web/macOS release is claimed. Do not distribute old builds or historical source snapshots containing the removed art.
