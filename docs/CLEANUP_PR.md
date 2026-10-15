The approved pixel arena previously depended on the legacy scene, generated SVG atlases and presentation adapters. It now owns its gameplay nodes directly and uses uploaded pixel sprites and health bars natively. F5 starts `res://pixel_art/arena.tscn`; the five-wave combat director, player controller, hitboxes, AttackData, animation timings and AI behavior are preserved.

Removed the generated artwork, old scene/preview adapters, illustrative geometric VFX, generation tools and historical build/cover artifacts as explicitly requested. No artwork was generated or backed up; Git history remains intact. Seven audio samples were moved unchanged to an audio-only directory. Functional warning text/tint and existing sound/hitstop remain; there is no new particle art or app icon.

### Review evidence

- [Full cleanup report](https://github.com/dekiencute/2d_hack_and_slash/blob/cleanup/pixel-art-only/docs/CLEANUP_REPORT.md), including every migration and remaining limitation.
- [Every deleted file](https://github.com/dekiencute/2d_hack_and_slash/blob/cleanup/pixel-art-only/docs/CLEANUP_DELETIONS.csv): 1,680 paths, including tracked removals/moves and ignored old builds/caches.
- [Retained visual/source inventory](https://github.com/dekiencute/2d_hack_and_slash/blob/cleanup/pixel-art-only/docs/PIXEL_ASSET_INVENTORY.json): all 59 uploaded files, purpose and hash.
- [Exact commands](https://github.com/dekiencute/2d_hack_and_slash/blob/cleanup/pixel-art-only/docs/CLEANUP_COMMANDS.json), [build hashes/results](https://github.com/dekiencute/2d_hack_and_slash/blob/cleanup/pixel-art-only/docs/CLEANUP_BUILD.json), [actual embedded-pack inventory](https://github.com/dekiencute/2d_hack_and_slash/blob/cleanup/pixel-art-only/docs/CLEANUP_PACK_CONTENTS.json).

### Validation

Godot 4.6.3 stable with matching official templates: clean source/export-copy imports; source combat 47/47, pixel/frame/AnimationPlayer/collision/camera validation 62/62, synthetic controller/death 13/13. Rendered Linux checks: combat 51/51 (four actual captures), pixel validation 62/62. All five waves (2/3/3/4/5), victory, defeat, pause, restart, hitbox/cancel timing and Style pass automated checks. Progression tests defeat enemies programmatically; no manual balance/playthrough claim.

Windows x86_64 Release and Linux validation exports succeeded. The freshly extracted Windows executable's embedded data pack passed 67 dependency/startup, 47 combat and 13 controller/death checks under Linux Godot. Exactly 33 declared imported media files (26 pixel PNGs + seven sounds), 123 pack files; no legacy artwork, SVG or unused authoring source. ZIP CRC, fresh extraction, all packaged file hashes and EXE identity verified. Initial cleanup audit falsely rejected regenerated pixel caches; corrected before a complete successful pipeline rerun. Rendered X11 runs report only unsupported V-Sync-setting driver warnings.

Private QA ZIP stays local and ignored by Git; source commit `049a2e48a7e69b3e8008aa2d2163b5ba4452a258` had a clean tracked worktree at export. SHA-256: `75c41f488946db5053f8424a6016d74de8fa78138e89ac3df6d381b8f2d27fdb`.

### Try it / limitations

Open `project.godot` in Godot 4.6.3 and press F5. Controls: A/D, Space, Shift, J/K, Esc, R; Xbox-style pad mappings remain. Rebuild owner QA using `python3 tools/release.py --private-qa` with matching templates.

**NOT READY FOR PUBLIC RELEASE.** Native Windows execution, physical controller and audible output are NOT TESTED. Character/enemy/UI creator terms remain independently pending; forest compiled-game permission and credit are documented. Owner confirmation does not clear the mandatory license gate: public packaging's negative test correctly rejects these three groups. Credits, engine/font notices and private QA workflow remain. No merge, publication or itch.io upload.

Actual rendered combat capture (review evidence, not cleared public marketing):

![Pixel-only gameplay](https://github.com/dekiencute/2d_hack_and_slash/blob/cleanup/pixel-art-only/docs/media/cleanup/03-combat.png?raw=true)
