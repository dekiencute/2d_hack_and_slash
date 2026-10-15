# Uploaded background preview

Open **`res://tests/background_preview.tscn`** in Godot and press **F6** (Run Current Scene). F5 still opens the combat arena. Or run:

```sh
godot --path . tests/background_preview.tscn
```

The scene starts a gentle automatic camera test. Controls are also shown in its HUD:

| Control | Action |
|---|---|
| WASD / arrow keys | Manual pan; stops automatic movement |
| Space / Auto pan checkbox | Toggle automatic camera motion |
| R / Center button | Center camera and stop auto pan |
| P / Parallax checkbox | Compare parallax against flat layer motion |
| L | Toggle both Lights overlays |
| Lights 0007 / Lights 0004 checkboxes | Toggle either light overlay independently |
| B / Base selector | Compare the two uploaded opaque base images |
| H | Hide/show the inspection HUD |

## Image inspection and inferred order

All **12 uploaded PNGs are 928×793**. Ten have RGBA pixels: eight use binary transparency (alpha 0 or 255), and the two Lights layers use partial alpha only (0–31). The remaining two bases are RGB images and fully opaque. Every file decoded successfully; there are no missing images.

The shared canvas and reversed export-prefix order suggest this **back-to-front** composition. The final suffixes count base 0 through foreground 9, while export prefixes run in the opposite direction. This order is inferred from filenames and pixel content; no source PSD or authored depth metadata was supplied with this upload. Parallax factors below are preview choices, not claimed original metadata.

Both bases cover the entire canvas. Stacking them would completely hide base 0; the selector keeps one visible at a time, defaulting to base 1. Both files are referenced in the scene.

| Uploaded PNG | Mode / alpha | Visible bounds `(x,y,w,h)` | Role / order | Parallax `(x,y)` |
|---|---|---|---|---|
| `Layer_0011_0.png` | RGB / opaque | `(0, 0, 928, 793)` | Opaque base 0 (alternative) | (0, 0) |
| `Layer_0010_1.png` | RGB / opaque | `(0, 0, 928, 793)` | Opaque base 1 (default) | (0, 0) |
| `Layer_0009_2.png` | RGBA / 0–255 | `(0, 379, 928, 414)` | Distant forest | (0.10, 0.08) |
| `Layer_0008_3.png` | RGBA / 0–255 | `(0, 458, 928, 271)` | Forest depth 3 | (0.22, 0.16) |
| `Layer_0007_Lights.png` | RGBA / 0–31 | `(248, 458, 479, 178)` | Lights over depth 3 | same parent as depth 3 |
| `Layer_0006_4.png` | RGBA / 0–255 | `(0, 458, 928, 271)` | Forest depth 4 | (0.36, 0.28) |
| `Layer_0005_5.png` | RGBA / 0–255 | `(0, 458, 928, 271)` | Forest depth 5 | (0.50, 0.40) |
| `Layer_0004_Lights.png` | RGBA / 0–31 | `(13, 458, 603, 220)` | Lights over depth 5 | same parent as depth 5 |
| `Layer_0003_6.png` | RGBA / 0–255 | `(30, 458, 898, 272)` | Near forest | (0.66, 0.56) |
| `Layer_0002_7.png` | RGBA / 0–255 | `(0, 195, 928, 277)` | Canopy | (0.82, 0.76) |
| `Layer_0001_8.png` | RGBA / 0–255 | `(0, 723, 928, 70)` | Ground | (1, 1) |
| `Layer_0000_9.png` | RGBA / 0–255 | `(0, 716, 928, 77)` | Foreground | (1, 1) |

## Parallax, pixel filtering and Lights

Ten `Parallax2D` groups preserve the full uploaded canvas without trimming/resampling. All Sprite2D origins are `(-464,-590)` so camera zero inspects the forest and ground. Slow distant groups, faster near groups and camera-speed ground give depth. The two Lights sprites share their corresponding depth group's parent and origin, so they cannot slide away from that artwork. Their draw order remains between the same neighboring exported layers.

The Lights PNGs are already painted **white overlays with alpha at most 31/255**, not PointLight2D masks. The preview preserves their original alpha/modulation with **normal mix blending and unshaded CanvasItemMaterial**. It adds no glow, generated texture, point light, shader or substitute artwork. Rendered checks compare the actual scene pixels with Lights on/off and confirm a visible contribution.

The preview root explicitly uses nearest filtering, enables pixel transform snapping for its running viewport, rounds camera positions to source pixels, disables camera smoothing and selects an integer camera zoom. It temporarily disables window resampling **inside the preview process only**; it does not change `project.godot`. At 1280×720 the camera uses 2× zoom; resizing selects an integer zoom that keeps the visible source area at most 640×360.

Each Parallax2D uses `ignore_camera_scroll=true` and receives this scene's rounded camera offset through `screen_offset`. This avoids viewport-top-left offsets shifting independently layered full-canvas images out of registration at rest or at different zoom levels. Native Parallax2D applies the depth factors; no artwork is changed to compensate.

Camera motion is bounded to **±128 source pixels horizontally and ±16 vertically**. Most transparent layer edges do not match, so `repeat_size` stays zero: no seamless/infinite tiling is claimed. The bounded camera framing stays inside the supplied image canvas; it is a finite background inspection, not a new level.

## Isolation and asset integrity

Only these uploaded PNGs supply scene artwork. No PNG was generated, replaced, trimmed, recolored or edited. The 12 new `.png.import` sidecars are Godot's lossless texture settings, with mipmaps disabled and no size limit. Generated cache files are ignored by Git. Machine-local screenshots are test evidence, not new committed art.

Combat scenes/scripts, main scene selection, existing preview, `project.godot` and export presets are unchanged from `origin/main` (`bc392fe`). No input actions/autoloads or gameplay hooks were added. Existing release exclusions already cover `tests/*` and `assets/Art/*`, keeping this review scene and its source art out of playable release exports. No merge, upload or publication is performed.

These 12 hashes match the previously inventoried Eder Muniz “Free Pixel Art Forest” files. The earlier [asset audit](ASSET_AUDIT_2026-10-15.md) records its custom terms (game use with credit; source asset redistribution restricted). This inspection does not assign CC0 or establish new rights to those files; preserve/verify the original terms before distribution.

## Validation

```sh
godot --headless --editor --path . --import
godot --headless --path . --script tests/background_preview_validation.gd
# On an available desktop/X11 display:
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script tests/background_preview_validation.gd
```

Tested with **Godot 4.6.3.stable.official.7d41c59c4** on Linux. Headless validation passes **61 checks**: all 12 textures, 10 Parallax2D groups, shared registration, nearest filtering/integer zoom, alpha materials, light/art alignment during movement, camera clamp/auto/manual/reset, opaque-base selection, absence of combat actors, and unchanged main-scene selection. Rendered X11/OpenGL validation passes **65 checks**, including three captures and an actual rendered-pixel comparison of Lights on/off. Mesa llvmpipe reports only the virtual driver's unsupported V-Sync warning; no script/resource errors were reported. The centered and panned captures were visually inspected.

Native Windows and integrated combat/background behavior were not tested or changed. No new Windows build is claimed. This is a standalone review scene, not a gameplay integration.

## Review branch and PR status

Pushed on the separate `review/background-parallax-preview` branch. `gh pr create` was attempted, but GitHub's API returned `Post "https://api.github.com/graphql": Forbidden`; this environment could not create the PR. [Open the separate comparison](https://github.com/dekiencute/2d_hack_and_slash/compare/main...review/background-parallax-preview?expand=1) and use [the prepared PR description](BACKGROUND_PREVIEW_PR.md). Nothing was merged automatically.
