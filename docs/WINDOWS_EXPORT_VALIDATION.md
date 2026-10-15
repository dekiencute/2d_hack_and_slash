# Windows export workflow validation — 15 October 2026

**The normal `python tools/release.py` command completed successfully**, despite the three independently unverified character/enemy/UI permission groups. It produced a technically verified Windows x86_64 candidate ZIP. `--private-qa` was not used. Permission warnings remain visible in the console, `BUILD_STATUS.txt` and both asset reports; `asset_rights_cleared` and `public_release_approved` remain false.

Branch: `release/windows-export-no-license-gate`, based on `origin/main` 788caee. Build source commit: **65e6d6e43974bff51399cc7961fb3313136797d2**, clean tracked worktree at export. Later commits add review/test documentation only.

## Actual checks

Test host: **Linux**, Godot **4.6.3.stable.official.7d41c59c4**, matching official Windows/Linux templates verified against recorded SHA-256 values.

| Check | Result |
|---|---|
| Python release/Windows-path tests | 8 passed |
| Source missing-resource / pixel-only cleanup audit | Passed |
| Source and isolated export-copy headless imports | Passed, no Godot errors/warnings |
| Source gameplay regression | 47 checks, zero failures |
| Source pixel/animation/collision/camera validation | 62 checks, zero failures |
| Source controller/death validation | 13 checks, zero failures, synthetic events |
| Windows x86_64 Release export | Passed, PE architecture and embedded PCK verified |
| Supplemental Linux Release export and startup | Passed |
| Fresh ZIP's Windows embedded-pack validation under Linux Godot | 67 checks, zero failures; pixel arena starts at title |
| Fresh ZIP's embedded-pack combat / controller-death | 47 / 13 checks, zero failures |
| Pack cleanup and complete imported-media reconciliation | Passed; 123 pack files, exactly 26 uploaded textures + seven audio samples |
| ZIP | 12 entries; CRC, fresh extraction, all packaged file hashes, manifest equality and extracted executable identity passed |
| Normal Windows Desktop preset, without export-copy modifications | Export succeeded; isolated exported-pack validation 67/67; same clean 123-file/33-media inventory |

The gameplay regression checks actual physics, hitboxes/damage, timing/cancel races, Style, double jump, dash invulnerability, ground/air attacks, launcher/slam, pause, restart, defeat and five-wave progression **2 / 3 / 3 / 4 / 5** to victory. Progression defeats enemies programmatically; this is not a human playthrough or balance test.

An initial ad-hoc normal-preset pack check ran from the project working directory and saw unpacked source files through Godot's resource filesystem. The same pack was checked again from an isolated directory: 67/67 passed; both inventories contain exactly the same clean resource paths. The complete normal-command packaging pipeline passed from fresh extraction without this issue. There were no Godot errors or warnings in the final pipeline or isolated normal-preset validation logs.

## Artifact and evidence

- ZIP: `dist/release-candidate/Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-RELEASE-CANDIDATE.zip`
- SHA-256: **48eeae72463c59c1896421a284811d505a69add629dce0b6f26c65d8665ad708**, also in the adjacent `.sha256` file.
- Executable: `builds/rc-release-candidate/windows/Stylebreaker.exe`
- Full local logs and pack inventory: `builds/rc-release-candidate/`.
- [Exact commands and environment](WINDOWS_EXPORT_COMMANDS.json); [hashes, package inventory and detailed results](WINDOWS_EXPORT_BUILD.json).
- [PowerShell/setup instructions](WINDOWS_EXPORT.md).

The archive includes the executable, README, credits, status/build/asset reports and five required engine/font/forest/audio license files. No legacy SVGs/scenes, unused PNGs, authoring PSD/Aseprite/GIF, screenshots or developer tooling are shipped. Original evidence and source options remain in the repository.

No player/enemy gameplay code, animation/collision resources, uploaded artwork, attack data, main scene setting or audio files changed. The unused root `main.tscn` restored in 788caee referenced deleted SVGs/scripts; it was removed and recorded in the deletion ledger. The standalone pixel arena remains the default.

## Limits and permissions

**Native Windows execution, PowerShell execution, interactive Windows playtesting, physical controller and audible output were NOT TESTED.** Windows detection/template/path behavior has Python unit coverage on Linux; this does not establish a native Windows host run. On Windows the script additionally performs exported/extracted EXE headless startup checks, while avoiding the Linux template/executable entirely. Interactive sign-off remains in the [Windows checklist](RC_WINDOWS_PLAYTEST.md). Optional private-QA feature/preset behavior has unit coverage; this task did not create another complete private-QA ZIP.

Character (Joe Idaho), enemy (Immortal Burrito) and UI (Adwit Rahman) creator terms remain independently unverified. Forest compiled-game permission/credit evidence and all creator credits remain. Missing evidence is a nonblocking warning, not a grant of commercial or source-sharing rights. No asset was relabeled CC0 or cleared to make the export pass. No automatic merge, publication or itch.io upload.
