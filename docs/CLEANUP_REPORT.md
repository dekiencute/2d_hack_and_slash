# Pixel-art-only cleanup

The standalone pixel arena is the only supported presentation. The owner explicitly authorized permanent removal of the earlier generated artwork, old visual scenes/tools and backup build artifacts. No copies of deleted artwork were created. Historical Git commits are not rewritten.

## Inventories

- Every deleted source/artifact/cache file and reason: `CLEANUP_DELETIONS.csv` (includes tracked source removals, migrated old paths and ignored build/cache files).
- Every retained uploaded visual/source file, SHA-256, runtime selection and purpose: `PIXEL_ASSET_INVENTORY.json`.
- Runtime media: **26 uploaded PNGs + seven unchanged audio WAVs**, explicit `tools/release_assets.json`. All owner source PNG/PSD/Aseprite/GIF options remain in the repository; unused/reference files are excluded from game packaging.

## Migration

- Main arena owns gameplay nodes directly; no inherited main scene or runtime texture swaps.
- Player SpriteFrames refer directly to uploaded character PNGs. Frame regions/speeds/durations and every AnimationPlayer key/track are checked against numeric pre-cleanup contracts; those contracts contain no artwork.
- Enemies start with the supplied sheet and native pixel HP bar. Their state observer does not schedule damage or alter AI. Warning rings/arcs are removed; existing `! STRIKE !` text and yellow tint remain functional indicators.
- Integer camera/parallax framing is a dedicated Camera2D script. Approved forest hierarchy, Lights alpha/order, floor registration and health-bar regions are retained.
- HUD uses the supplied pixel health bar directly. Text/buttons and a plain menu dimmer are functional UI controls, not replacement illustrations. Rounded decorative panels and generated health widgets are removed.
- Audio-only combat feedback retains all seven sound samples; no drawn hit/slash/dash particles remain. Supplied attack-sheet pixels, tint, health changes and hitstop remain. No new art is generated.
- Required gameplay scripts/data, collision shapes, input bindings, scoring and five-wave progression (2/3/3/4/5) remain. Player controller and hitbox code and all AttackData bytes are unchanged. Enemy code changes remove drawing/redraw calls and type the native texture HP bar; AI/timers/damage stay intact.
- Seven retained sounds/license moved to an audio-only resource directory; audio bytes are unchanged. Required Godot/font notices and third-party license evidence remain. App icon artwork is not supplied; default engine shell icon is a packaging limitation.

## Validation / build

Validation is in progress. Results, exact commands, Windows export and fresh extracted-pack inventory will be recorded here after completion. No native Windows execution is claimed. Public packaging remains license-gated; character/enemy/UI actual creator terms are still independently pending. Forest compiled-game use is documented with credit; raw source-asset redistribution remains prohibited.

Separate branch: `cleanup/pixel-art-only`. No automatic merge or itch.io publication.
