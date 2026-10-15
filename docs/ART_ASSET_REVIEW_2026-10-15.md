# Uploaded art review — 15 October 2026

## Open the separate preview

Open `res://preview/art_preview.tscn` in Godot and press **F6** (Run Current Scene), or run:

```sh
godot --path . preview/art_preview.tscn
```

F5 still starts the existing arena. The preview has independent character, enemy, UI and source/reference lists, name search, play/pause, frame stepping/scrubbing, adjustable inspection FPS, integer 1×–8× zoom, horizontal flip, loop control, checker/dark/light backgrounds, cell outlines, full-sheet scrolling and UI alpha-bound views. Space toggles playback and Left/Right step frames; text-field input is left alone. **Whole sheet** and **Alpha bounds** only change the displayed region; they do not crop or rewrite source files. Alpha bounds are not automatically safe widget regions for multi-option sheets.

No game art was generated, replaced or retargeted. All 86 uploaded files are byte-for-byte unchanged. `actors/`, `combat/`, `levels/`, `systems/`, and `ui/` are unchanged from base commit `74ee68d`. Main-scene selection is unchanged. The existing vector placeholders remain in gameplay; replacing them is explicitly outside this review.

## Inventory and readiness

All **86 files** were inspected: **39 PNGs** (19 character sheets, one enemy sheet, 19 UI images), **39 import sidecars**, **3 Aseprite sources**, **3 PSD sources**, and **2 GIF references**. The catalog contains **54 inspection entries** and **181 existing PNG frame regions**. Every PNG decodes, has a matching valid import source, and loads through Godot. Import sidecars use lossless compression, no mipmaps and no size limit. No missing referenced resource was found.

| Group | Technically ready | Needs adjustment | License status |
|---|---|---|---|
| Character PNGs | All 19 decode as horizontal 80×48 cells, with no remainder. Idle/Run/air-light layouts fit the corresponding stored sprite layouts. | Preserve state-owned timings; review unused extra frames in ground chains and Dash. Split Jump/Fall poses. Guns, LungingStab and hurt/death playback are not currently wired gameplay features. | **Verification required for every file.** All 19 hashes match the historical `resources/Characters/Dante/` files; a new directory/upload does not establish permission. |
| Enemy Sword PNG | Six rows have counts matching source tags: Idle, Run, Run2, Walk, Attack, Hit. All eight PNG rows can be inspected. | AttackCombo is 7 PNG cells vs 8 source frames; Death is 9 vs 11. Reconcile/re-export before using source timing. All enemy clips still need deliberate pivot, facing, state and hitbox mapping. | **Verification required.** No author/source URL/license included. |
| Pixel UI PNGs | All 19 decode; individual bar components and composites can be inspected immediately. | Most are padded canvases or packed variants, not drop-in ProgressBar textures. Choose explicit AtlasTexture regions and fill direction; do not stretch borders. Stamina image has detached pixels beyond the main bar. Credit art and opaque presentation backgrounds are not widgets. | **Verification required.** Credit identifies Adwit Rahman / `@adwitr_itch.io`, but attribution is not a redistribution grant. |
| Aseprite, PSD, GIF | Headers/dimensions and Aseprite tags/durations inspected; Pillow decoded all PSD composites and every GIF frame. Metadata is shown in Source/reference. | These are authoring/reference formats, not textures loaded by this Godot preview. Inspect/edit in their native tools and export deliberately. Examples differ in canvas size and frame count from the runtime PNG. | Same unresolved pack rights. No license text was supplied. |

“Ready” means technically inspectable/compatible with further integration work. **No uploaded pack is cleared for redistribution or public integration.** Obtain the original source URL, creator/license terms and any required purchase/permission evidence, including game-derived character rights where applicable. Existing CC0 terms for `resources/original` do not apply to these uploads. No license was downloaded, inferred or granted by this review.

## Character dimensions and compatibility

Preview playback is **8 FPS for inspection only**; there is no supplied authoring timing metadata for these PNG strips. Gameplay still owns move timing through AttackData and AnimationPlayer/AnimationTree. Equal cell sizes do not prove compatible timing, pivot, facing or frame selection. Current grounded sprite scale is non-integer; future pixel-art integration must review scale/feet alignment without changing combat hitboxes as a side effect.

| File | PNG size | 80×48 cells | Compatibility / adjustment |
|---|---:|---:|---|
| `2WayShootGun1.png` | 160×48 | 2 | Two firing poses; no gun mechanic/state is wired in this prototype. |
| `2WayShootGun2.png` | 160×48 | 2 | Two firing poses; no gun mechanic/state is wired in this prototype. |
| `AirCombo1.png` | 560×48 | 7 | 7 frames fit existing air_light_01 layout; keep hit timings separate from preview FPS. |
| `AirCombo2.png` | 560×48 | 7 | 7 frames fit existing air_light_02 layout; keep hit timings separate from preview FPS. |
| `AirCombo3.png` | 720×48 | 9 | 9 frames fit existing air_light_03 layout; keep hit timings separate from preview FPS. |
| `AirShootGun1.png` | 160×48 | 2 | Two firing poses; no gun mechanic/state is wired in this prototype. |
| `AirShootGun2.png` | 160×48 | 2 | Two firing poses; no gun mechanic/state is wired in this prototype. |
| `Dash.png` | 480×48 | 6 | 6 available frames; current dash uses four atlas cells (indices 1–4). Review selection before retargeting. |
| `Die.png` | 320×48 | 4 | 4 poses fit stored die animation; gameplay currently freezes the last pose on death. |
| `GroundCombo1.png` | 640×48 | 8 | 8 available frames; existing light_01 uses six cells. Extra poses need deliberate timing/selection. |
| `GroundCombo2.png` | 800×48 | 10 | 10 available frames; existing light_02 uses eight cells. Extra poses need deliberate timing/selection. |
| `GroundCombo3.png` | 1120×48 | 14 | 14 available frames; existing launcher uses 14, light_03 uses 12, air_heavy uses seven selected cells. Review state-specific selection. |
| `Idle.png` | 80×48 | 1 | Single pose. Matches existing idle frame count. |
| `JumpAndFall.png` | 160×48 | 2 | Two distinct poses: split frame 0 Jump and frame 1 Fall; do not loop as locomotion. |
| `LungingStab.png` | 1200×48 | 15 | 15 frames. No existing move/animation state is wired to this sheet. |
| `Run.png` | 640×48 | 8 | 8 frames match existing run layout; preserve gameplay-owned animation timing. |
| `ShootGun1.png` | 160×48 | 2 | Two firing poses; no gun mechanic/state is wired in this prototype. |
| `ShootGun2.png` | 160×48 | 2 | Two firing poses; no gun mechanic/state is wired in this prototype. |
| `TakeHit.png` | 80×48 | 1 | One reaction pose; no dedicated active hurt animation state currently. |

## Enemy sheet and source tags

`Sword.png` is **1792×512**, a **14-column × 8-row** grid of **128×64** cells. **58** cells contain pixels; **54** are empty trailing slots and are excluded from playback. `Sword.aseprite` is **128×64**, **61 frames**, with eight forward-loop tags; every source frame is **100 ms**. Preview uses 10 FPS based on that source, with a warning that the PNG export may represent another revision. Missing source-tag frames are not invented or padded into the preview.

| PNG row (0-based) | Clip | Occupied PNG frames | Aseprite range | Source count | Status |
|---:|---|---:|---|---:|---|
| 0 | Idle | 7 | 0–6 | 7 | Count agrees; integration mapping still required |
| 1 | Run | 4 | 7–10 | 4 | Count agrees; integration mapping still required |
| 2 | Run2 | 8 | 11–18 | 8 | Count agrees; integration mapping still required |
| 3 | Walk | 7 | 19–25 | 7 | Count agrees; integration mapping still required |
| 4 | Attack | 14 | 26–39 | 14 | Count agrees; integration mapping still required |
| 5 | AttackCombo | 7 | 40–47 | 8 | COUNT MISMATCH |
| 6 | Hit | 2 | 48–49 | 2 | Count agrees; integration mapping still required |
| 7 | Death | 9 | 50–60 | 11 | COUNT MISMATCH |

## Pixel UI canvases

These are individual PNG files containing components/variants on canvases, **not uniformly spaced animation strips**. Alpha rectangles below use `(x, y, width, height)` in source pixels. Full-canvas and alpha-bound viewing are both available; no source images were trimmed. RGB background PNGs are opaque. Detached pixels and multiple options can make a single alpha rectangle unsuitable for a functional widget.

| PNG | Canvas | Measured alpha/display rectangle | Notes |
|---|---:|---|---|
| `Health_0000_Created-by-Adwit-Rahman-@adwitr_itch.io-.png` | 162×132 | `[9, 97, 143, 27]` | Author credit artwork, not a health widget and not a license. |
| `Heart.png` | 162×132 | `[12, 2, 40, 83]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel (1).png` | 162×132 | `[3, 29, 82, 17]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel (2).png` | 162×132 | `[3, 5, 82, 17]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel (3).png` | 162×132 | `[3, 5, 82, 17]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel (4).png` | 162×132 | `[2, 4, 84, 19]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel 2.png` | 162×132 | `[24, 9, 81, 46]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel1_Healthbar_0000_pixel1_staminabar.png` | 130×89 | `[8, 14, 118, 26]` | Detached pixels beyond main bar; alpha bounds alone do not isolate a clean component. |
| `Pixel1_Healthbar_0001_pixel1_healthbar.png` | 130×89 | `[8, 54, 79, 6]` | Component/composite on a padded canvas; use a reviewed AtlasTexture region. |
| `Pixel1_Healthbar_0002_pixel1_border.png` | 130×89 | `[6, 65, 83, 11]` | Component/composite on a padded canvas; use a reviewed AtlasTexture region. |
| `Pixel1_Healthbar_0003_pixel1_healthbarcomplete.png` | 130×89 | `[6, 14, 83, 11]` | Component/composite on a padded canvas; use a reviewed AtlasTexture region. |
| `Pixel1_Healthbar_0004_Background.png` | 130×89 | `[0, 0, 130, 89]` | Opaque presentation background, not a transparent UI component. |
| `Pixel2_Healthbar_0000_Pixel2_HealthBarComplete.png` | 236×173 | `[25, 52, 123, 34]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel2_Healthbar_0001_pixel2_EmblemSpace.png` | 236×173 | `[25, 52, 32, 34]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel2_Healthbar_0002_pixel2_Border.png` | 236×173 | `[42, 116, 106, 21]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel2_Healthbar_0003_pixel2_HealthBars.png` | 236×173 | `[42, 93, 105, 18]` | Packed options/components; crop deliberately before use as a widget. |
| `Pixel2_Healthbar_0004_Background.png` | 236×173 | `[0, 0, 236, 173]` | Opaque presentation background, not a transparent UI component. |
| `RPG Style (1).png` | 162×132 | `[2, 2, 89, 74]` | Packed options/components; crop deliberately before use as a widget. |
| `RPG Style (2).png` | 162×132 | `[16, 2, 73, 84]` | Packed options/components; crop deliberately before use as a widget. |

## Authoring and reference files

| File | Canvas | Frames | Inspection |
|---|---:|---:|---|
| `Enemies/Demon_Sword/Sword.aseprite` | 128×64 | 61 | Aseprite header, all frame/chunk bounds and tags/durations parsed. |
| `Enemies/Demon_Sword/eg/Sword_eg.aseprite` | 768×750 | 22 | Aseprite header, all frame/chunk bounds and tags/durations parsed. |
| `Enemies/Demon_Sword/eg/Sword_eg.gif` | 768×750 | 22 | All GIF frames decoded; durations recorded in catalog. |
| `Enemies/Demon_Sword/eg/eg_run2.aseprite` | 960×720 | 8 | Aseprite header, all frame/chunk bounds and tags/durations parsed. |
| `Enemies/Demon_Sword/eg/sowrd_eg2.gif` | 960×720 | 20 | All GIF frames decoded; durations recorded in catalog. |
| `UI/Pixel Health Bar Asset Pack 1 by Adwit Rahman/Health Bar Asset Pack by Adwit Rahman.psd` | 162×132 | 20 | PSD header and flattened composite decoded; layer composition not edited or validated in Photoshop. |
| `UI/Pixel Health Bar Asset Pack 1 by Adwit Rahman/Pixel1_Healthbar.psd` | 130×89 | 5 | PSD header and flattened composite decoded; layer composition not edited or validated in Photoshop. |
| `UI/Pixel Health Bar Asset Pack 1 by Adwit Rahman/Pixel2_Healthbar.psd` | 236×173 | 5 | PSD header and flattened composite decoded; layer composition not edited or validated in Photoshop. |

`Sword_eg.gif` has 22 frames, matching its 22-frame example Aseprite canvas (768×750). `sowrd_eg2.gif` has 20 frames, while the other example source `eg_run2.aseprite` has 8 (960×720); their filename/content relationship is not established, so neither is used as the enemy animation manifest. Source editors were not installed/run. Only the supplied runtime PNG supplies preview pixels.

## Configuration review and isolation

- Commit `51231d1` (“Art assets”) changed the tested feature marker from `4.6` to `4.7` without a demonstrated feature migration and removed explicit stretch `keep`. Restored **4.6 / GL Compatibility** and **window/stretch/aspect="keep"**. Godot 4.6.3 is the available/tested runtime; no 4.7-only feature is needed by the uploads or preview.
- Commit `74ee68d` intentionally selected nearest filtering and pixel transform snapping alongside `docs/ART_DIRECTION.md`. Those pixel-art settings are **retained**, not reverted. Preview nodes additionally set nearest filtering locally and use integer zoom. Pixel snapping does not fix non-integer actor scale, camera zoom or UI stretch by itself.
- Main scene, viewport/window sizes, title/icon/version, renderer, editor plugins, inputs, game actors and original assets are otherwise untouched. No preview autoload or gameplay hook was added.
- Both existing export presets now exclude `preview/*` and `assets/Art/*`. Previously `all_resources` could bundle unused, unverified art even without scene references. A real exported PCK was checked: gameplay scenes remain present; all 39 uploaded PNG resources and preview scene/scripts/catalog are absent. This review did **not** rebuild or publish a Windows executable.

## Reproduce and validate

```sh
# Inspect image/source metadata and refresh the JSON catalog (Pillow required only here).
python3 tools/audit_art_assets.py
# Import and validate the separate scene (Godot itself needs no Python/Pillow).
godot --headless --editor --path . --import
godot --headless --path . --script tests/asset_preview_validation.gd
# Existing gameplay regression suite.
godot --headless --path . --script tests/regression.gd
# Render the preview tests on a working desktop/X11 display.
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script tests/asset_preview_validation.gd
# Check actual release-resource isolation, without a native Windows executable.
godot --headless --editor --path . --export-pack "Windows Desktop" /tmp/stylebreaker-preview-isolation.pck
godot --headless --main-pack /tmp/stylebreaker-preview-isolation.pck --script "$PWD/tests/asset_preview_pack_validation.gd" -- "$PWD/preview/art_catalog.json"
```

Final results are recorded below after validation. Machine-local logs and rendered inspection screenshots stay outside Git. The catalog stores dimensions, frame/cell rectangles, source tags/durations, alpha bounds, import settings and SHA-256 for every uploaded file. Running the audit regenerates **metadata only**, never art or gameplay resources.

## Actual validation results

Tested with **Godot 4.6.3.stable.official.7d41c59c4** on Linux:

| Check | Actual result |
|---|---|
| Image/source audit | All 86 files inventoried; 39 PNGs decoded, all GIF frames and PSD composites decoded; Aseprite headers/chunk bounds/tags parsed. Zero missing import sources or invalid character grids. Deterministic JSON regeneration confirmed. |
| Headless Godot import | Passed; no script/resource/import errors. Uploaded `.import` files remained unchanged. |
| Headless preview validation | **80 checks, 0 failures**, covering every PNG and all 181 regions, metadata-only source entries, filtering, search/selection, FPS playback, loop/step/scrub, focused Space input, sheet/alpha modes and export configuration. |
| Rendered preview validation | **83 checks, 0 failures** on X11/OpenGL 4.5 using Mesa llvmpipe. Three actual inspection screenshots rendered and visually checked (character, enemy sheet and UI). Audio driver Dummy. One platform warning: virtual display cannot change V-Sync. No game/script/resource errors. |
| Existing arena regression | **47 checks, 0 failures**; includes actual input/physics/hitboxes, moves, dash, enemy attacks, Style, pause/restart and all five waves with scripted win/loss. No gameplay code was changed. |
| Exported PCK isolation | Real `--export-pack` succeeded without a Windows executable build. Loaded that PCK from `/tmp`; confirmed original gameplay scenes present and all 39 new PNGs plus preview scene/script/catalog absent. Both release presets use the same exclusions. |
| Scope / source integrity | `git diff --exit-code origin/main -- actors combat levels systems ui assets/Art` passed. SHA-256 verified all 86 uploads unchanged. `git diff --check` and Python syntax check passed. |

Not tested: native Aseprite/Photoshop editing or full PSD layer correctness, permission/entitlement with asset creators, Windows executable execution, physical controller/audio devices, or a new playable integration of the uploaded art. No new Windows executable was built or published by this review. The preview is an inspection tool, not approval of rights or an integrated combat animation set.

## Separate review branch / PR status

Committed on `review/art-asset-preview-2026-10-15`, based on `origin/main` at `74ee68d`, and pushed successfully. Automatic PR creation was attempted with `gh pr create`; GitHub's API returned `Post "https://api.github.com/graphql": Forbidden`, so this environment could not create the requested PR. [Open the separate branch comparison](https://github.com/dekiencute/2d_hack_and_slash/compare/main...review/art-asset-preview-2026-10-15?expand=1); [the prepared PR description](ART_PREVIEW_PR_DESCRIPTION.md) contains scope, findings and validation for review.
