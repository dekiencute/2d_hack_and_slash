# Asset audit — 15 October 2026

The release tree contains original procedural game art and synthesized audio.
No external art or audio is needed to play. This audit records supplied evidence;
missing evidence is not a finding that the original owner infringed anyone's rights.

| Original group | Files, including sidecars | Evidence in repository | Release action |
|---|---:|---|---|
| `resources/Characters/Dante` | 38 | No author, license, source URL or purchase record. Named third-party character; rights cannot be established. | Removed; original teal masked fighter with matching animation atlases. |
| Free Pixel Art Forest | 39 | Eder Muniz custom license allows personal/commercial games with credit, but forbids sharing source assets even when modified. It calls itself “closest” to CC BY 4.0; it is **not** unmodified CC BY. | Removed unused pack from the distributable source tree. |
| Sideview Fantasy Patreon Collection | 775 | One dragon subfolder contains a Luis Zuno/ansimuz license conditional on current/past Patreon support. No entitlement evidence; no basis to extend it to every folder. The active scene used mist-forest layers. | Entire pack removed; original geometric arena. |
| Monster Creatures Fantasy | 16 | No license or purchase evidence supplied. | Removed unused pack; original sentinel artwork. |
| Old `.exe` / `.pck` builds | 3 | Contents, provenance and runtime status unverified; may contain legacy art. | Deleted from current tree; new output ignored by Git. |

[REMOVED_ASSETS_2026-10-15.csv](REMOVED_ASSETS_2026-10-15.csv) records all **871** removed paths and SHA-256 hashes against the original checkout. It retains no source images or binary data. Git history still contains the legacy files; removal here does not license that history. Release the new candidate ZIP, not an old build or historical source snapshot.

## New and retained material

- `resources/original/player_*.svg`: 11 original animation strips. Frame regions and AnimationPlayer timing are retained from the existing scene; art is new geometry.
- `resources/original/enemy.svg`, `arena.svg`, `icon.svg`: three original game images.
- `resources/original/audio/*.wav`: seven original mono PCM effects for slash, hit, dash, hurt, wave, victory and defeat. Seeded noise and mathematical oscillators; no samples, recordings or outside compositions.
- `systems/combat_feedback.gd`: original line/arc VFX, driven by confirmed-hit and player signals. It does not calculate damage.
- `docs/media`: actual Godot screenshots and an original 630 × 500 cover. Text uses Godot's bundled font; no external font files are added.
- New art/audio/cover: **CC0 1.0**, full legal text in `resources/original/LICENSE.txt`. Regenerate game media with `python3 tools/generate_assets.py`; no network or third-party Python packages required. CC0 does not change the license of pre-existing project code.
- Existing nine AttackData resources and combat/wave tuning are preserved.
- Godot 4.6.3, its libraries and bundled Noto Sans: required MIT/OFL and other notices are in `docs/licenses`. The packaging script copies these notices into the ZIP.
- `addons/godot_mcp` is development tooling, has no bundled license file, and is disabled/excluded from runtime exports. It is not part of the shipped asset set.

All required basic prototype visuals, UI, VFX and SFX are present. Music, richer character animation, additional enemy art, and more arenas are outside this pre-alpha's scope.
