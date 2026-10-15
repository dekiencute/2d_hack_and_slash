Add `res://tests/background_preview.tscn` as an isolated preview of the twelve uploaded 928×793 forest PNGs. Open the scene and press F6; F5 remains the existing arena. No combat/main-scene/project settings or original PNGs are changed, and no artwork is generated.

Use ten bounded Parallax2D depth groups, nearest filtering, snapped camera motion and integer zoom. The two low-alpha white Lights images remain unshaded alpha overlays, parented to their corresponding depth groups so they track the artwork. Provide auto/manual camera tests, flat/parallax comparison, independent light toggles, an opaque-base selector and a hideable HUD. No seamless tiling is claimed because most layer edges do not match.

Godot 4.6.3 validation: 61 headless checks and 65 X11/OpenGL rendered checks pass. All PNGs load; initial registration, differential parallax movement, light alignment/alpha, camera controls/bounds and main-scene isolation are checked. Actual Lights on/off rendered pixels differ, and three captures were visually inspected. Only virtual-display warning: unsupported V-Sync. No Windows build or gameplay integration is claimed.

See `docs/BACKGROUND_PREVIEW.md` for layer dimensions/transparency, inferred order, depth factors, controls, prior asset-license context and reproduction commands. This PR is for review only; do not merge automatically.
