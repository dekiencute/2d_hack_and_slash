# Prepare Stylebreaker Pre-Alpha v0.1.0 Windows candidate

**NOT READY for public release.** The pixel-art arena is owner-approved; character/enemy/UI redistribution rights remain unverified, forest terms/provenance need review, and native Windows playtesting is pending. Nothing is merged, uploaded or published automatically.

## Result

- Default/F5 now starts `res://pixel_art/arena.tscn`, game title **Stylebreaker**. Previous `levels/main.tscn` remains available with F6/direct launch and in the private QA pack.
- Fixes confirmed missing controller-A menu confirmation with one `ui_accept` binding. Combat timing/hitboxes/AI/Style/waves/animation resources remain unchanged. No artwork generated, edited or removed.
- Adds asset inventory/rights reports and a fail-closed public packaging command. Private owner QA uses a temporary explicit-resource export; unused art/options, source PSD/Aseprite/GIF files, previews and editor tooling are excluded. Committed public asset quarantine remains.
- Fixes initial selected-resource omissions for script-loaded scenes/AttackData/global classes. Source/pack startup testing caught this before ZIP creation.
- Prepares player installation/controls, credits/notices, changelog, draft itch.io copy, fresh gameplay captures and a native Windows test checklist.

## Tested

Godot **4.6.3.stable.official.7d41c59c4**, official matching Windows/Linux Release templates (fingerprints recorded), Linux host:

| Validation | Result |
|---|---|
| Source / QA import | Pass, no final Godot errors |
| Default pixel / fallback combat | **47/47 each** |
| Synthetic controller and actual enemy death/removal | **13/13** |
| Pixel presentation | **55 headless / 57 rendered** |
| Background / asset inspectors | **61 / 80 headless** |
| Rendered gameplay, actual captures | **51/51**, normal clock, X11/Mesa llvmpipe/Dummy audio |
| Windows x86_64 / Linux Release exports | Pass; independent Linux startup passes |
| Fresh extracted Windows pack startup/resource/mapping checks | **80/80** under Linux Godot |
| Same Windows pack combat / controller-death | **47/47 + 13/13** under Linux Godot |
| Included media | Exactly **47 declared sources / 47 imported media files**, **156 total pack files** inventoried |
| ZIP | **12 members**, CRC and every packaged file hash verified; SHA-256 produced |
| Public rights gate | Expected refusal before export; no new public ZIP |

**Windows PE was not executed on Windows.** Controller events are synthetic; physical hardware/audio, human balance/performance and native Windows sign-off remain pending. Scripted lethal hits advance later waves in regression tests.

## Private QA artifact

Local, ignored by Git: `dist/private-qa/Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-PRIVATE-QA-NOT-FOR-DISTRIBUTION.zip`.

SHA-256: `2afcca7cd9544a81cb50fa2eb792ca3907e27c041b682d8948e2924084a12e8f`

Build source **842c15a**, clean worktree. No binary/ZIP attached to GitHub or itch.io. The private artifact contains unresolved uploaded art for owner-local QA and must not be treated as the public download. A distributable public ZIP remains blocked.

## Review / reproduce

F5 starts pixel gameplay. `python3 tools/release.py --audit-only` reports rights; normal invocation refuses unresolved rights. `--private-qa` runs the full gated QA pipeline with matching templates installed. `python3 tools/audit_rc_pack.py` reconciles all imported media. See [exact commands/results](https://github.com/dekiencute/2d_hack_and_slash/blob/release/prealpha-v0.1.0-rc/docs/RC_VALIDATION.md), [asset report](https://github.com/dekiencute/2d_hack_and_slash/blob/release/prealpha-v0.1.0-rc/docs/RC_ASSET_LICENSE_REPORT.md), [artifact hashes](https://github.com/dekiencute/2d_hack_and_slash/blob/release/prealpha-v0.1.0-rc/docs/RC_ARTIFACTS.json), [draft itch.io copy](https://github.com/dekiencute/2d_hack_and_slash/blob/release/prealpha-v0.1.0-rc/docs/ITCHIO_PREALPHA_V0.1.0.md) and [Windows checklist](https://github.com/dekiencute/2d_hack_and_slash/blob/release/prealpha-v0.1.0-rc/docs/RC_WINDOWS_PLAYTEST.md).

The earlier ignored fallback binaries remain recoverable and are not this RC. Do not release them as the new pixel version. Clear rights, rebuild a licensed public candidate and perform native Windows sign-off before release approval.

## Actual pixel-gameplay captures — review only until rights are cleared

![Pixel arena](https://raw.githubusercontent.com/dekiencute/2d_hack_and_slash/refs/heads/release/prealpha-v0.1.0-rc/docs/media/rc-v0.1.0/02-arena.png)

![Pixel combat](https://raw.githubusercontent.com/dekiencute/2d_hack_and_slash/refs/heads/release/prealpha-v0.1.0-rc/docs/media/rc-v0.1.0/03-combat.png)

![Five-wave victory](https://raw.githubusercontent.com/dekiencute/2d_hack_and_slash/refs/heads/release/prealpha-v0.1.0-rc/docs/media/rc-v0.1.0/04-victory.png)
