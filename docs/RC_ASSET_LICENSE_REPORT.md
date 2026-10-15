# Release-candidate asset rights — 15 October 2026

**Status: NOT READY. No public pixel-art release is approved.** Owner approval of the integrated arena is separate from the third-party right to distribute artwork commercially.

The selected build media inventory is **47 files**: 11 character PNG sheets, one enemy PNG, two UI PNGs, 12 forest PNGs, and 21 existing original SVG/WAV files. `tools/release_assets.json` is the explicit inventory; generated `ASSET_LICENSE_REPORT.json` gives each path, byte count, SHA-256, evidence, credit and clearance status. The exported pack is separately inventoried in `PACK_CONTENTS.json`, including scripts, imported/remapped resources and metadata. Built-in fonts/libraries reside in the engine and are covered by the bundled Godot notices.

| Included assets | Evidence / redistribution status | Required action |
|---|---|---|
| Character: Idle, Run, JumpAndFall, Dash, Die, GroundCombo1/2/3, AirCombo1/2/3 (11 PNGs) | All match historical `resources/Characters/Dante` hashes. No creator URL, license, entitlement or underlying character permission supplied. **UNVERIFIED.** | Review original commercial game-use terms, entitlement if required and underlying character rights. Attribution unresolved. |
| Demon Sword: `Sword.png` (1 PNG) | Source availability is not a license. No commercial terms or creator evidence supplied. **UNVERIFIED.** | Obtain creator/source/license and any required entitlement. |
| Adwit Rahman Pixel1 health bar fill and border (2 PNGs) | Credit `Adwit Rahman / @adwitr_itch.io` exists; no permission text supplied. **UNVERIFIED.** | Verify commercial compiled-game use and attribution requirements. |
| Eder Muniz Free Pixel Art Forest (12 PNGs) | Exact hash match to historical pack; recovered custom terms permit personal/commercial games and modification, require credit and forbid source asset redistribution even when modified. **CONDITIONAL: original provenance/current terms and packaging need review.** Not plain CC BY or CC0. | Preserve “Forest art by Eder Muniz,” review evidence and compiled-game packaging. Do not distribute source asset bundles. |
| Original media (14 SVGs, 7 WAVs) and existing VFX | `resources/original/LICENSE.txt`, CC0 1.0; original synthesized PCM, no external samples. **VERIFIED for original media.** | Preserve notice; do not extend it to uploaded art or pre-existing code. |
| Godot 4.6.3, bundled Noto Sans and libraries | Existing Godot MIT/OFL and third-party notices. **VERIFIED notice set.** | Bundle full `GODOT_LICENSE.txt` and `GODOT_COPYRIGHT.txt`. |

Unused uploaded PNG alternatives, gun strips, LungingStab/TakeHit, extra UI options and all PSD/Aseprite/GIF source/reference files are excluded from the QA export. Source files remain in the repository and receive no redistribution clearance. Editor addons, previews, tests, tooling and docs are excluded from game data. Original fallback resources remain because the inherited arena needs them and the fallback is retained.

No new license evidence was supplied by the owner during this task. Public packaging fails before export when any selected asset group is not verified with evidence. Committed public presets retain their pixel-asset quarantine; **do not bypass the packaging gate with a manual public export**. A direct export with those presets cannot be treated as a validated pixel release while startup dependencies are quarantined. Private QA uses a temporary selected-resource configuration and never modifies that quarantine.

The private QA archive deliberately includes integrated uploaded art for owner review. **It is NOT a distributable/public release.** Its filename, embedded feature flag, credits, report, manifest and build status retain that restriction. No public pixel ZIP is produced while issues remain unresolved.

Evidence: [historical audit](ASSET_AUDIT_2026-10-15.md), [upload review](ART_ASSET_REVIEW_2026-10-15.md), [integration report](PIXEL_ART_INTEGRATION.md), and recovered `docs/licenses/FOREST_HISTORICAL_TERMS.txt`. Hash identity does not supply missing permission.
