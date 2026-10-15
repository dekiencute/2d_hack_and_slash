The existing arena depended on character art without license evidence, conditionally licensed environment art, stale Windows binaries, and editor-only export assumptions. This prepares a small five-wave pre-alpha candidate with original CC0 geometric art, seven synthesized sounds, hit feedback, readable HUD, title/instructions, pause and retry/results.

Preserves the nine move resources, combat values, AnimationPlayer/AnimationTree timing and wave counts 2/3/3/4/5. Fixes interrupted enemy windups releasing newer attack slots, lingering telegraphs, invisible hit flash, pause behavior of combat timers, and restart during hitstop. The original art packs and old binaries are removed from the current tree; a hashed 871-file inventory and rights audit explain each removal.

Validation with Godot 4.6.3 and matching templates:
- 47 source integration checks pass, including real input, physics and hitbox overlaps, launcher/aerial combat, dash, damage/Style, attack cap, pause, restart, and all waves/win/loss.
- 51 checks pass with X11/OpenGL rendering, including four actual screenshot captures; only the virtual display's unsupported V-Sync warning remains.
- Windows x86_64 release export and independent Linux validation export/startup pass. Packaging verifies ZIP CRC, extracted EXE hash, PE architecture, embedded PCK and all 47 checks against the exact extracted Windows resource bundle using Linux Godot.
- No combat move data changes; 21 generated game art/audio files reproduce byte-for-byte. Import/export/headless checks have no script/resource errors or shutdown warnings.

**Release blockers:** native Windows executable launch and five-wave playtest, physical controller/GPU/audio verification, and itch.io upload/download verification are pending. The Windows PE has not been executed here. Keep itch.io Draft/Restricted until those checks pass. No music, saves, rebinding, extra enemies or arenas are claimed.

See `docs/ITCHIO_RELEASE_2026-10-15.md`, `docs/VALIDATION_2026-10-15.md`, and `tools/release.py`. Builds/ZIPs are ignored by Git; source and original assets only are committed.
