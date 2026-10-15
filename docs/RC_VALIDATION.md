# Stylebreaker — Pre-Alpha v0.1.0 release-candidate record

**NOT READY FOR PUBLIC RELEASE.** Character, enemy and UI rights are unverified; forest provenance/current terms and packaging need review. Native Windows playtesting has not happened. No public pixel ZIP, itch.io upload or automatic merge was performed.

Branch: `release/prealpha-v0.1.0-rc`, based on approved integration merge **d319aae**. Tested build source: **842c15a7d31c5016b938bb8fb23d0244c9df9207**, clean worktree. Later commits record evidence/docs/audit tooling only; no game-code change follows that build.

## Implemented scope and confirmed fixes

- F5/default startup is **`res://pixel_art/arena.tscn`**; game name is **Stylebreaker**. Previous `res://levels/main.tscn` remains available through direct launch or F6. Both scenes are packaged for private QA.
- Nearest filtering, pixel snapping, uploaded art, shared Parallax2D forest/Lights and integer presentation remain intact. No artwork is generated, deleted or edited.
- All `actors/`, `combat/`, `systems/`, `ui/`, `resources/`, `assets/Art/` and `pixel_art/` files remain unchanged from `d319aae`. The only director change is **one controller-A → `ui_accept` binding**. A real synthetic joypad event exposed that the earlier title could not start with controller A. This is fixed without changing Jump or other combat bindings.
- Selected-resource exports initially omitted script-loaded enemy/scenes/AttackData/global classes. Startup validation caught this and prevented ZIP creation. The QA whitelist now explicitly includes runtime scripts/scenes/AttackData plus declared media. No gameplay resource is reconstructed or retuned.
- Public packaging fails closed on unresolved selected-asset rights. Committed public presets retain quarantine. Owner-only QA uses a temporary project and selected-resource preset; it includes unresolved art solely for local review. Do not bypass the gate through manual public export while startup dependencies are quarantined.

## Actual results

Tested **Godot 4.6.3.stable.official.7d41c59c4** on Linux x86_64. Official matching Windows/Linux Release templates were extracted over HTTPS from the Godot 4.6.3 archive; ZIP member CRCs and template SHA-256 were checked. [Template provenance](RC_TEMPLATE_PROVENANCE.json) records URL, sizes and hashes. This is not a whole-archive checksum claim.

| Gate | Actual result |
|---|---|
| Headless editor import, source and temporary QA copy | Pass; no final script/resource/import errors. |
| Pixel/default combat regression | **47 checks, 0 failures**. Actual input/physics/timers/hitbox overlaps, move chains, double jump, dash cancellation/invulnerability, launcher/air suspension/slam, damage, Style rules, two-attacker cap, pause/hitstop/reload, all five waves, victory/defeat. |
| Fallback combat regression | **47/0**, same suite. |
| Synthetic controller/death test | **13/0**. Low-level joypad A starts title; stick moves; A double-jumps; B dashes; X/Y attack; Start pauses/resumes; Back reloads pixel scene. Actual supplied enemy death frame is nonempty, then existing removal timer deletes the actor. No physical-device claim. |
| Pixel presentation | **55 headless / 57 rendered checks, 0 failures**. Frame/timing/shape compatibility, HP text/bar sync, pivots/floor, camera/parallax/Lights, menu/HUD at three window sizes and runtime scale restore. |
| Background preview / asset inspector | **61 / 80 headless checks, 0 failures**, respectively. No historical rendered preview result is counted as a new run. |
| Rendered gameplay | **51/0** with normal clock and `--max-fps 60`, X11/OpenGL Compatibility, Mesa llvmpipe, Dummy audio. Four fresh actual viewport captures, visually inspected for title, HUD, forest alignment and combat. Virtual-driver V-Sync warning only; no script/resource errors. |
| Windows x86_64 Release export | Pass with matching official template. PE x86_64 header and embedded Godot footer verified. **Cross-export only, not Windows execution.** |
| Linux Release export/startup | Pass; exported Linux executable starts from outside the source tree and reaches title without errors. |
| Fresh ZIP extraction / embedded Windows startup and inventory | **80/0** under Linux Godot: pixel scene is the embedded default, actual uploaded player frames load, forest/camera exist, nearest/snapping retained, fallback retained, keyboard/controller mappings correct, unused art/source/previews/tooling absent. |
| Exact freshly extracted Windows pack combat | **47/0**, plus **13/0 controller/death checks**, both under Linux Godot. These tests load the real embedded Windows data; they do not launch or play the Windows PE. |
| Every included media asset | **47 declared sources → exactly 47 imported media files**: 40 textures and seven audio samples, no undeclared derived media. Complete pack has **156 files** with paths/sizes/SHA-256. Asset rights report covers all 47 sources plus engine/font notices. |
| ZIP integrity | **12 members**; CRC passes, every packaged file's SHA-256 matches the staged copy, manifest JSON matches, extracted PE matches exported PE, embedded-pack tests pass. SHA-256 sidecar generated. |
| Public packaging gate | `python3 tools/release.py` exits 1 with `PUBLIC PACKAGING BLOCKED` before export; no new public ZIP produced. Intentional refusal, not a Godot error. |
| Source integrity | Uploaded sources/sidecars, combat resources and visual adapter unchanged; `git diff --check` and Python compile checks pass. |

Initial missing-dependency and controller failures were fixed and retested; diagnostic logs are retained separately under `builds/rc-private-qa/diagnostics`. Final pipeline logs have no Godot errors or instance-leak warnings. Automated later-wave progression uses scripted lethal hits; it does not prove human clearability/balance.

## Private QA artifacts — do not distribute

- Windows executable: `builds/rc-private-qa/windows/Stylebreaker.exe`.
- ZIP: `dist/private-qa/Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-PRIVATE-QA-NOT-FOR-DISTRIBUTION.zip`.
- SHA-256 sidecar alongside the ZIP; full artifact record: [RC_ARTIFACTS.json](RC_ARTIFACTS.json).
- Build logs, exact argv/cwd, license manifest, temporary export configuration, 156-file pack inventory, derived-media audit and SHA-256 map: `builds/rc-private-qa/`.
- Older ignored `builds/windows/` and root `dist/` artifacts belong to the previous fallback candidate and were left recoverable. They are not this RC. No binaries/ZIPs are committed or attached to a GitHub release.

ZIP SHA-256:

```text
2afcca7cd9544a81cb50fa2eb792ca3907e27c041b682d8948e2924084a12e8f
```

Windows executable SHA-256:

```text
d3ec40f23fec209880a064370ed33ed0f253d298cba0188928e95198e47c2624
```

The archive bundles executable, instructions, credits, changelog, human/machine asset-rights reports, BUILD_STATUS, source/template/package provenance manifest, CC0 notice for original media, forest historical terms and full Godot/font/library notices. It is **private QA, not a distributable public release**. Its embedded `private_qa` feature marker is checked.

## Commands and environment

[RC_COMMANDS.json](RC_COMMANDS.json) records exact commands, cwd, non-secret environment selectors and exit results, including ephemeral build/extraction paths. Reproduce from the project root with matching official templates installed under `$XDG_DATA_HOME/godot/export_templates/4.6.3.stable`:

```sh
export XDG_DATA_HOME=/tmp/stylebreaker-rc/data
export XDG_CONFIG_HOME=/tmp/stylebreaker-rc/config
export XDG_CACHE_HOME=/tmp/stylebreaker-rc/cache
python3 tools/release.py --audit-only
python3 tools/release.py                 # Expected license refusal; no public ZIP.
python3 tools/release.py --private-qa     # Owner-local QA only.
python3 tools/audit_rc_pack.py
```

The private QA pipeline runs import, both source combat suites, presentation/controller/preview checks, both Release exports, independent Linux startup, full ZIP/hash checks and three checks of the extracted Windows pack. Export options: x86_64, embedded PCK, release templates, no debug wrapper/signing/resource modification, Compatibility renderer, no ANGLE/D3D12 distribution, no editor tooling. Exact selected-resource settings are captured in `builds/rc-private-qa/QA_EXPORT_PRESETS.cfg`.

Rendered commands on the available X11 display:

```sh
DISPLAY=:99 LP_NUM_THREADS=4 godot --path . --audio-driver Dummy --max-fps 60 --script tests/regression.gd -- --screenshots /tmp/stylebreaker-rc/screenshots
DISPLAY=:99 LP_NUM_THREADS=4 godot --path . --audio-driver Dummy --script tests/pixel_art_validation.gd
```

Screenshots copied unchanged from the first rendered command to `docs/media/rc-v0.1.0/`. They are actual editor-engine gameplay, not native Windows captures. [Draft itch.io materials](ITCHIO_PREALPHA_V0.1.0.md), [changelog](RC_CHANGELOG.md), [credits](RC_CREDITS.txt), [player instructions](PLAYER_README.txt) and [asset report](RC_ASSET_LICENSE_REPORT.md) are prepared.

## Open release blockers

1. **Rights:** character, Demon Sword and UI permission/entitlement evidence still missing; forest provenance/current terms and packaging need review. Uploaded files and owner art-selection approval do not establish commercial redistribution rights. [Full report](RC_ASSET_LICENSE_REPORT.md). Public presets/packaging remain blocked.
2. **Native Windows:** no Windows machine/runtime was used. Extract and play the actual executable on Windows x86_64; test all five waves, defeat/retry, startup outside editor, pause, controls, fullscreen, sound/mute, real controller and GPU behavior. Record OS/GPU/driver/controller, archive/exe hashes and outcomes in [Windows checklist](RC_WINDOWS_PLAYTEST.md).
3. **Public candidate verification after rights clearance:** resolve notices/inventory, enable an appropriate reviewed export configuration, rebuild a licensed public candidate, repeat archive/extracted-pack checks, perform native Windows sign-off, and have the owner approve publication. A future itch.io upload/download/hash check remains pending; nothing was uploaded here.

Known prototype limits: one enemy type/arena, no music/saves/rebinding/online/progression, placeholder feedback/menu panels, integer camera view changes on resize, source/PNG enemy frame-count mismatch and short existing death/removal behavior. Windows output is unsigned and retains the default Godot shell icon because resource modification is disabled. No new mechanics/art or full-game completion is claimed.
