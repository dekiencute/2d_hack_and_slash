# Add an opt-in pixel-art five-wave arena

`res://pixel_art/arena.tscn` makes the uploaded player, Demon Sword, health bars and forest playable together. It inherits the existing arena and adds presentation adapters; original controls, attack resources/timings, collision shapes, AI, scoring, wave counts and win/loss logic stay intact. F5 remains the previous arena; no source art is edited or deleted, no art is generated, and no merge or itch.io publication is performed.

## Try it

Open the project in Godot **4.6.3**, open **`pixel_art/arena.tscn`**, and press **F6**. Enter/A starts; A/D moves, Space double jumps, Shift dashes, J chains light attacks, K launches/air heavies, R retries and Esc pauses. F5 runs the fallback. Presentation toggles and two background bases remain available in the `PixelPresentation` inspector.

The background preview and arena now share the same forest scene and Parallax2D controller. Both Lights retain their authored alpha and depth parent. Player/enemy scale is integer 2×; pixel health bars use explicit atlas crops. Camera/window handling keeps nearest pixels crisp without changing `project.godot`.

## Validation

Godot 4.6.3 on Linux; X11/OpenGL Compatibility/Mesa llvmpipe/Dummy audio for rendered runs:

- Headless import and pixel scene launch pass, no final script/resource errors.
- Identical combat regression: **47/47 headless on fallback and 47/47 on pixel arena**. Real inputs, hitbox overlaps, damage/Style, combos/air attacks/dash, attack tokens, pause/hitstop/reload, five waves, victory and defeat.
- Pixel rendered regression: **51/51** using normal clock with `--max-fps 60`; separate fixed-step run **51/51**. Initial concurrent uncapped rendering failed one timing-sensitive combo assertion; controlled follow-ups passed. Hardware performance remains unverified.
- Pixel presentation/compatibility: **55/55 headless, 57/57 rendered**; original frame durations/regions and collision shapes, independent fallback resources, health sync, foot/floor alignment, parallax/Lights, and UI visibility at three window sizes.
- Background preview after extraction: **61/61 headless, 65/65 rendered**. Existing asset inspector: **80/80 headless**.
- Actual Windows-preset **PCK-only** export passes. External inspection confirms all **59 uploaded PNG/integration/preview paths** excluded and fallback scene resources present. **No new Windows executable build or native Windows run is claimed.**
- Core gameplay, project settings and all uploads unchanged from base `808dd4d`; all 19 character/12 forest hashes match historical inventory. `git diff --check` clean.

## Rights and remaining work

Character, enemy and Adwit Rahman UI licenses **still need original terms/provenance**. The user confirmed having license/source information but URLs/text have not yet been supplied. The forest matches Eder Muniz's pack: custom game-use permission with credit, source redistribution prohibited; not CC0 or plain CC BY. Forest credit and evidence are recorded in the integration notes. **All uploaded art and integration files stay excluded from public export presets.** Do not publish a pixel build or source asset bundle until cleared.

Enemy PNG/source counts differ (AttackCombo 7/8, Death 9/11). Unavailable frames are not invented, AttackCombo is unused, and existing short removal/death behavior is preserved. Extra player frames/guns/alternate UI remain inspectable options. Existing smooth feedback/warnings and standard menu panels remain placeholders; no complete pixel VFX/menu skin is claimed. Finite forest framing uses no repeating seams.

Human balance/input/performance, physical controller/audio and native Windows playtests remain pending. Automated later-wave progression uses scripted lethal hits.

See [full implementation, rights, screenshots, test commands and release gates](PIXEL_ART_INTEGRATION.md). Screenshots below are actual unedited Godot captures for review, not cleared public marketing.

## Screenshots

![Pixel-art arena](https://raw.githubusercontent.com/dekiencute/2d_hack_and_slash/refs/heads/integration/pixel-art-arena/docs/media/pixel-art/02-arena.png)

![Combat with uploaded sprites](https://raw.githubusercontent.com/dekiencute/2d_hack_and_slash/refs/heads/integration/pixel-art-arena/docs/media/pixel-art/03-combat.png)

![Five-wave victory](https://raw.githubusercontent.com/dekiencute/2d_hack_and_slash/refs/heads/integration/pixel-art-arena/docs/media/pixel-art/04-victory.png)
