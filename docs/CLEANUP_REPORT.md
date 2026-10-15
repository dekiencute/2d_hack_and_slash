# Pixel-art-only cleanup

The standalone pixel arena is the only supported presentation. The owner explicitly authorized permanent removal of the earlier generated artwork, old visual scenes/tools and backup build artifacts. No copies of deleted artwork were created. Historical Git commits are not rewritten.

## Inventories

- Every deleted source/artifact/cache file and reason: [CLEANUP_DELETIONS.csv](CLEANUP_DELETIONS.csv), **1,681 distinct paths**, including 110 tracked old paths removed or migrated, ignored prior builds and caches. All 14 generated SVGs and their sidecars are gone. The subsequent export repair also removes an unused root `main.tscn` restored in 788caee, which referenced deleted legacy art/scripts. Fresh Godot caches and the tested pixel-only build can regenerate under the same cache/output directories; they contain the current presentation.
- Every retained uploaded visual/source file, SHA-256, runtime selection and purpose: [PIXEL_ASSET_INVENTORY.json](PIXEL_ASSET_INVENTORY.json), **59 files** (51 PNGs and eight authoring/reference files). Uploaded source bytes and import sidecars were preserved.
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

## Historical cleanup validation / build

These results describe the earlier private QA artifact, not the current Windows export workflow. See [WINDOWS_EXPORT.md](WINDOWS_EXPORT.md) for normal exports with nonblocking license warnings.

Tested on Linux with **Godot 4.6.3.stable.official.7d41c59c4** and matching official Release templates. Build source commit: **049a2e48a7e69b3e8008aa2d2163b5ba4452a258**, clean tracked worktree at export. Later documentation commits record these results without changing game code.

| Check | Actual result |
|---|---|
| Editor/headless source and isolated export-copy imports | Passed; no parser/resource errors or warnings |
| Source combat regression | 47 checks, zero failures |
| Source pixel/frame/AnimationPlayer/collision/camera/health-bar validation | 62 checks, zero failures |
| Source controller/death | 13 checks, zero failures; synthetic joypad events |
| Rendered Linux combat regression | 51 checks, zero failures, including four viewport captures |
| Rendered pixel validation | 62 checks, zero failures; integer camera/visibility at tested window sizes |
| Windows x86_64 Release and Linux validation exports | Both succeeded; matching template hashes verified |
| Linux exported-game startup | Passed |
| Extracted Windows executable's PCK, loaded by Linux Godot | 67 dependency/startup checks, 47 combat regression checks, 13 controller/death checks; zero failures |
| Actual exported pack cleanup / imported-media reconciliation | Passed; 123 pack files, exactly 26 PNG-derived textures and seven WAV-derived samples; no SVG, legacy scene/art, unused PNG or PSD/Aseprite/GIF source |
| ZIP | CRC, fresh extraction, every package file hash, manifest equality and extracted EXE identity passed; 14 ZIP entries |
| Protected sources | All 70 pre-cleanup protected file hashes unchanged (uploaded art/source files, AttackData, player controller and hitbox code); seven moved sound samples separately match origin/main byte-for-byte |
| Historical license-policy test | The then-current script rejected incomplete evidence (exit 1); this policy was subsequently removed at the owner's request |
| Native Windows executable, physical controller and audible output | **NOT TESTED** |

The regression exercises actual physics, damage overlaps, timing/cancel races, Style, title, pause/resume, restart, defeat and wave counts **2 / 3 / 3 / 4 / 5**. Progression tests defeat enemies programmatically; they do not establish human difficulty/balance or a complete manual playthrough. Rendered runs used a dummy audio driver and virtual X11: each emitted the driver's unsupported V-Sync-setting warning. There were no Godot parser/resource/runtime errors. An initial cleanup-audit false positive treated freshly regenerated pixel caches as removed source; it was corrected and the complete packaging pipeline rerun successfully. No failed-attempt ZIP was retained.

Exact export/test commands and working directories: [CLEANUP_COMMANDS.json](CLEANUP_COMMANDS.json). Template provenance, hashes and detailed outcomes: [CLEANUP_BUILD.json](CLEANUP_BUILD.json). Actual embedded file inventory: [CLEANUP_PACK_CONTENTS.json](CLEANUP_PACK_CONTENTS.json). Full local logs: `builds/rc-private-qa/logs/`.

Private owner QA artifacts (ignored by Git):

- Executable: `builds/rc-private-qa/windows/Stylebreaker.exe`
- ZIP: `dist/private-qa/Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-PRIVATE-QA-NOT-FOR-DISTRIBUTION.zip`
- SHA-256: **75c41f488946db5053f8424a6016d74de8fa78138e89ac3df6d381b8f2d27fdb**, also in the adjacent `.sha256` file.

Open `project.godot` with Godot 4.6.3 and press **F5** to try the standalone scene. Review actual captures: [title](media/cleanup/01-title.png), [arena](media/cleanup/02-arena.png), [combat](media/cleanup/03-combat.png), [victory](media/cleanup/04-victory.png). Rebuild with `python3 tools/release.py --private-qa` after installing the matching templates; see recorded XDG paths for this machine. The subsequent Windows workflow removes editor-preset quarantine; the normal preset selects the pixel runtime and `python tools/release.py` runs mandatory technical checks without blocking incomplete license evidence.

## Remaining blockers / visual gaps

**Public release: NOT READY.** Character/enemy/UI actual creator terms are still independently pending; provisional credits and owner confirmation do not supply creator terms. These are nonblocking export warnings in the current workflow. Forest compiled-game use is documented with credit; raw source-asset redistribution remains prohibited. See [asset-license report](RC_ASSET_LICENSE_REPORT.md). Native Windows playtesting and physical-device/audio sign-off remain pending on the exact extracted artifact: [Windows checklist](RC_WINDOWS_PLAYTEST.md).

No uploaded app icon or separate pixel hit/dash particle set is selected. No replacement is generated: the executable keeps its engine shell icon, attacks use authored sheet pixels, and impact/dash feedback uses existing sounds, tint, health, hitstop and functional warning text. These presentation gaps are documented separately from release-blocking rights and native testing.

Separate branch: `cleanup/pixel-art-only`. No automatic merge or itch.io publication.

## Delivery

The cleanup commits are pushed to `origin/cleanup/pixel-art-only` and the remote head was verified with `git ls-remote`. Creating the PR with `gh pr create --repo dekiencute/2d_hack_and_slash --base main --head cleanup/pixel-art-only` failed: `Post "https://api.github.com/graphql": Forbidden` (environment network policy). No PR number or successful creation is claimed. [Prepared PR description](CLEANUP_PR.md); [open the review form](https://github.com/dekiencute/2d_hack_and_slash/pull/new/cleanup/pixel-art-only). No merge or publication was performed.
