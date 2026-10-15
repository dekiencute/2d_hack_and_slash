# Owner-directed private QA refresh — 15 October 2026

Completed using the approved art, following the owner's instruction to proceed without further document requests. All four source URLs and the owner's repeated commercial-use confirmation are recorded. Forest compiled-game use is documented with required credit and source-asset sharing restrictions. Character/enemy/UI creator terms remain owner-confirmed but not independently verified; this does not block private QA. No artwork, gameplay or export/build code changed. No merge, upload or publication performed.

## Current artifact

- Build source: **06134d7**, clean worktree, Godot **4.6.3.stable.official.7d41c59c4**, matching fingerprinted Release templates.
- Windows executable: `builds/rc-private-qa/windows/Stylebreaker.exe`.
- ZIP: `dist/private-qa/Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-PRIVATE-QA-NOT-FOR-DISTRIBUTION.zip`.
- SHA-256 sidecar alongside the ZIP. [Current artifact record](RC_ARTIFACTS.json).
- ZIP SHA-256: `42fa80da2ef42148250a9285c92914708d82a484db937c4a64397b9b8c4ca4ca`.
- Windows EXE SHA-256: `56cc81f9108ef0342d072339025e9908be5ed6874cfda52cf541938bcab8c92e`.

The refreshed package contains updated credits, source URLs, owner statement, forest README/terms, evidence snapshot, human/machine license reports and normal player/build/engine/font notices. **15 ZIP members**; every packaged file hash and ZIP CRC verified. The exact extracted executable's embedded pack was tested. This is an owner-local private QA artifact, not an approved public download. Native Windows execution remains **NOT TESTED**.

## Actual refreshed checks

| Check | Result |
|---|---|
| Source / temporary QA import | Pass, no final Godot errors |
| Pixel/default / fallback combat | **47 checks each, 0 failures** |
| Pixel presentation | **55 headless checks, 0 failures** |
| Synthetic controller / real enemy death frame and removal | **13 checks, 0 failures** |
| Background / asset inspectors | **61 / 80 headless checks, 0 failures** |
| Windows x86_64 Release and Linux Release exports | Pass; independent Linux startup passes |
| Extracted Windows pack startup/resources/input mappings | **80 checks, 0 failures**, Linux Godot |
| Extracted Windows pack combat / controller-death | **47 / 13 checks, 0 failures**, Linux Godot |
| All included media | **47 declared source assets / exactly 47 imported media files**, **156 total pack files** inventoried |
| Fresh ZIP integrity | CRC, all package hashes, manifest and extracted executable match; 15 members verified |
| Historical build recovery | Previous 842c15a executable, Linux build and ZIP archived; original hashes verified |

No rendered, audible-output, physical-controller or native Windows test was newly run for this metadata-only refresh. Earlier actual gameplay captures and rendered checks remain historical evidence for the unchanged runtime; no replacement artwork or mock screenshots were created. Public packaging continues to refuse unverified character/enemy/UI terms; it was not unlocked by the owner statement alone.

## Reproduce and evidence

```sh
export XDG_DATA_HOME=/tmp/stylebreaker-rc/data
export XDG_CONFIG_HOME=/tmp/stylebreaker-rc/config
export XDG_CACHE_HOME=/tmp/stylebreaker-rc/cache
python3 tools/release.py --private-qa
python3 tools/audit_rc_pack.py
```

[Exact refreshed argv/cwd/exit results](ASSET_LICENSE_QA_COMMANDS.json); matching templates under `$XDG_DATA_HOME/godot/export_templates/4.6.3.stable`. Logs, license report, temporary selected-resource preset and complete pack inventory remain under `builds/rc-private-qa/`. There are no final script/resource errors or instance-leak warnings.

## Prior build retained

The previous verified candidate is preserved without changing its bytes:

- `builds/rc-private-qa-history/842c15a/` contains its original executables/logs/reports.
- `dist/private-qa/history/842c15a/` contains its original ZIP and checksum.
- [Historical artifact record and relocated hashes](RC_ARTIFACTS_842c15a_ARCHIVED.json).
- Original ZIP hash remains `2afcca7cd9544a81cb50fa2eb792ca3907e27c041b682d8948e2924084a12e8f`.

The historical [RC record](RC_VALIDATION.md) and its embedded manifests describe the older build. Current paths/hashes are in this refresh and `RC_ARTIFACTS.json`. Keep the approved visuals and continue private testing; no additional document request is required to proceed with that work. Independent rights clearance and native Windows sign-off remain prerequisites for an approved public release.
