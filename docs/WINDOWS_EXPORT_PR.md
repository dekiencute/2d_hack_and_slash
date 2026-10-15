Normal Windows builds previously failed when character/enemy/UI license evidence was incomplete, and the editor presets excluded the approved pixel arena/assets. `python tools/release.py` now reports those permissions as warnings and completes the Windows x86_64 ZIP. The normal Windows Desktop preset selects the pixel runtime directly. Credits, evidence and unverified statuses remain; export success does not clear permissions.

Windows portability fixes use the running Python interpreter, UTF-8 files, forward-slash resource identifiers, Godot executable detection/explicit paths, native template locations and optional `--templates-dir`. Windows no longer requires or tries to execute a Linux template. Windows hosts perform headless startup checks of both exported and extracted EXEs. Linux retains its supplemental native export/startup test. Output directories are created automatically; failed reruns remove stale final archives/checksums. Optional `--private-qa` labeling remains supported.

All technical import, missing-resource, regression, export dependency, PE/embedded-pack, media, ZIP and SHA-256 checks remain mandatory. Packaging includes runtime files, reports/player instructions and required notices, excluding unused source media and developer files. The root `main.tscn` restored in 788caee referenced deleted legacy SVGs/scripts and was removed; no gameplay, animations, approved art, audio or main-scene settings changed.

Validation on Linux, Godot 4.6.3 stable with matching official templates:

- Normal command without `--private-qa`: succeeded with three visible permission warnings.
- Python portability/policy tests: 8 passed.
- Source combat / pixel / synthetic controller: 47 / 62 / 13 checks, zero failures.
- Extracted Windows game data: 67 dependency/startup, 47 combat and 13 controller checks, zero failures.
- Normal editor preset exported without workflow modifications: isolated pack validation 67/67.
- Complete media audit: 123 pack files, 26 uploaded textures + seven sounds, no old SVG/legacy scenes or unused authoring assets.
- ZIP CRC, fresh extraction and all hashes passed; 12 package entries.
- SHA-256: `48eeae72463c59c1896421a284811d505a69add629dce0b6f26c65d8665ad708`. Local ZIP: `dist/release-candidate/Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-RELEASE-CANDIDATE.zip`.

**Native Windows/PowerShell execution and interactive playtesting were NOT tested.** Windows path/detection/template branches have Python unit coverage on Linux. Physical controller/audio remain untested. Programmatic wave progression is not a human playthrough. Permission evidence is still independently pending for Joe Idaho character, Immortal Burrito enemy and Adwit Rahman UI; statuses were not promoted and no art was labeled CC0.

PowerShell: `py -3 .\tools\release.py` (Godot 4.6.3 on PATH, `GODOT_BIN`, or `--godot "C:\Tools\Godot\Godot_v4.6.3-stable_win64_console.exe"`).

[Windows setup/commands](https://github.com/dekiencute/2d_hack_and_slash/blob/release/windows-export-no-license-gate/docs/WINDOWS_EXPORT.md) · [Full validation and limits](https://github.com/dekiencute/2d_hack_and_slash/blob/release/windows-export-no-license-gate/docs/WINDOWS_EXPORT_VALIDATION.md) · [Build hashes](https://github.com/dekiencute/2d_hack_and_slash/blob/release/windows-export-no-license-gate/docs/WINDOWS_EXPORT_BUILD.json)

No automatic merge or itch.io upload/publication.
