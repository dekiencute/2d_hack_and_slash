# Validation — 15 October 2026

Tested engine: **Godot 4.6.3.stable.official.7d41c59c4**, Linux x86_64, Compatibility renderer. Windows/Linux export templates are from the official matching 4.6.3-stable release. The environment's default writable configuration/data/cache directories were replaced per command with temporary XDG directories; no project dependency on those absolute paths exists.

| Check | Result |
|---|---|
| Clean Godot editor/headless import | Pass; no script/resource errors. Disabled optional MCP editor addon. |
| Source integration suite | **47 checks, 0 failures**. Real input actions, physics and Area2D contact; atlas bounds, controller binding, movement/double jump, buffered 1/2/3 combo/reset, dash cancellation/i-frames, launcher, air light suspension, air slam, Style rules, enemy damage/recovery, two-attack limit, interrupted windup generations, pause/resume, paused hitstop, restart during hitstop, wave counts, victory/defeat and spawn cancellation. |
| Rendered integration suite | **51 checks, 0 failures** on X11 with Mesa llvmpipe / OpenGL 4.5. Includes four successful 1280 × 720 screenshots, visually inspected. One platform warning: virtual driver cannot change V-Sync. No game/script/resource errors or leaked timer warning. Audio driver was Dummy. |
| Windows release export | Pass: `Windows Desktop`, x86_64, embedded PCK, matching templates. No export errors. This is cross-export, not Windows execution. |
| Independent exported Linux startup | Pass from a temporary directory outside the project/editor; no script/resource errors. Validation artifact only. |
| Fresh candidate ZIP | CRC validation, fresh extraction, SHA-256 match, PE x86_64 header and embedded PCK footer checks pass. |
| Extracted Windows **resource pack**, Linux Godot runtime | **47 checks, 0 failures**, loading the exact extracted `.exe` as the main data pack with an external test script. Confirms exported scripts/scenes/moves/audio dependencies and gameplay logic. Does **not** execute Windows machine code. |
| Original media generation | 21 game SVG/WAV outputs reproduce byte-for-byte. All nine move resources and AttackData schema unchanged from `origin/main`. |
| Repository diff | `git diff --check` and Python tool syntax checks pass. Runtime/export package excludes docs, tests, tools, addon and old binaries. |

## Reproduction

```sh
godot --headless --editor --path . --import
godot --headless --path . --script tests/regression.gd
python3 tools/release.py
```

`tools/release.py` writes individual logs to `builds/logs`, refuses script/resource errors even on an exit code of zero, verifies the extracted candidate, and writes a ZIP plus SHA-256 file under `dist`. Its manifest records source revision/dirty status, source hashes and package hashes. Generated artifacts and machine-specific logs are not committed.

For screenshots, use an available X11 display and run:

```sh
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script tests/regression.gd
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script tools/render_cover.gd
```

The test captures title, first-wave arena, a real launcher impact and scripted victory under `/tmp/stylebreaker-logs/screenshots`; selected captures and the cover are committed in `docs/media`. The scripted wave completion uses lethal test hits to exercise wave lifecycle; it is not a human difficulty/playability assessment. Controller binding verification is not a hardware/controller test. No editor F5 button interaction or audible speaker playback is claimed.

## Checks that could not run / blockers

- **Native Windows execution:** neither a Windows host nor Wine is available. The Windows executable must be launched from a fresh extracted ZIP and played through victory and defeat outside the editor. GPU/driver compatibility, audible SFX, device behavior, physical controller input, resizing and full-screen transitions need that check.
- **itch.io upload/download:** no itch.io publishing access or upload was used. Follow the dated release gate after Windows validation; keep the page Draft/Restricted until the uploaded download is checked.
- **PR creation:** the feature branch was pushed successfully, but `gh pr create` failed with `Post "https://api.github.com/graphql": Forbidden`. No PR was created. Open [the prepared branch comparison](https://github.com/dekiencute/2d_hack_and_slash/compare/main...release/itchio-prealpha-2026-10-15?expand=1) and use [the prepared PR description](PR_DESCRIPTION_2026-10-15.md). This is an environment GitHub API access blocker; Git push succeeded.

Required basic prototype assets are present. Music, extra enemy types/arenas, animation expansion, save/rebinding and progression are outside scope.
