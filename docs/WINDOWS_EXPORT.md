# Windows release export

The normal exporter and **Windows Desktop** preset include the approved pixel-art runtime. Incomplete character/enemy/UI creator-license evidence is reported in the console and package, **without blocking export**. Statuses, source URLs and creator credits remain unchanged. Export success does not establish commercial/source redistribution permission or publish anything.

## Windows setup and command

Install Python **3.9+**, Godot **4.6.3 stable** and its matching official export templates (Godot: **Editor → Manage Export Templates**). Use the official Windows x86_64 console executable for CLI output. Keep both files from the portable Windows editor download together; the console executable may need its companion editor executable. A short checkout path such as `C:\src\Stylebreaker` avoids older Windows path-length restrictions.

From PowerShell in the repository:

```powershell
py -3 .\tools\release.py
```

Detection checks `GODOT_BIN`, common Godot command names on PATH, and the official `Godot_v4.6.3-stable_win64_console.exe`/editor filename in the checkout or PATH directories (also common Windows install folders). If Godot is elsewhere, specify its path; spaces are supported:

```powershell
py -3 .\tools\release.py --godot "C:\Tools\Godot\Godot_v4.6.3-stable_win64_console.exe"
```

Default Windows templates: `%APPDATA%\Godot\export_templates\4.6.3.stable`. For a portable/self-contained/custom template installation:

```powershell
py -3 .\tools\release.py --godot "C:\Tools\Godot\Godot_v4.6.3-stable_win64_console.exe" --templates-dir "C:\Tools\Godot Templates\4.6.3.stable"
```

The directory must contain `version.txt` and `windows_release_x86_64.exe`, matching recorded official SHA-256 fingerprints. Windows does **not** require or run a Linux template. On Linux, the workflow also requires the matching Linux Release template for its supplemental exported-game startup check. macOS uses its native Godot editor for the Windows data-pack tests without launching a Linux binary. Linux/macOS invocation: `python3 tools/release.py`.

## Outputs and mandatory checks

The script creates `dist/` and build/log directories automatically:

- `dist/release-candidate/Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-RELEASE-CANDIDATE.zip`
- Adjacent `.sha256` checksum file.
- `builds/rc-release-candidate/windows/Stylebreaker.exe`
- `builds/rc-release-candidate/logs/`, `COMMANDS.json`, `SHA256.json`, asset-license report and actual pack inventory.

The embedded game starts `res://pixel_art/arena.tscn`. The ZIP contains the executable, player instructions, credits, license/status reports, build manifest and required engine/font/forest/audio notices. Authoring PSD/Aseprite/GIF, unused PNG options, developer tooling, legacy SVGs/scenes, tests and screenshots are excluded. No new artwork is created.

All builds must pass missing-resource/source cleanup checks, exact engine/template checks, headless import, Python packaging tests, combat regression (including all five waves and outcomes), pixel/animation validation, controller-event tests, Windows x86_64 PE/embedded-pack checks, exported pack startup/dependency and combat checks, complete media reconciliation, ZIP CRC, fresh extraction and per-file SHA-256 verification. A failed rerun removes the previous final ZIP/checksum rather than presenting it as a newly verified output.

On Windows, the script additionally launches both the exported and extracted Windows executables headlessly. These automated launches do **not** count as an interactive playtest. Builds made on Linux/macOS load the actual embedded Windows game data with host Godot; they do not execute Windows machine code. Manifests and `BUILD_STATUS.txt` record the actual host and distinguish these cases. Native interactive Windows, physical-controller and audible-output sign-off remain separate: [Windows playtest checklist](RC_WINDOWS_PLAYTEST.md).

Verify the ZIP in PowerShell before extraction:

```powershell
$zip = ".\dist\release-candidate\Stylebreaker-PreAlpha-v0.1.0-windows-x86_64-RELEASE-CANDIDATE.zip"
Get-FileHash $zip -Algorithm SHA256
Get-Content ($zip -replace '\.zip$', '.sha256')
```

Optional `--private-qa` preserves the existing owner-only name, `private_qa` feature and output directories; it runs the same technical checks. `--audit-only` writes the permission report and produces no ZIP. Neither flag is required for normal builds.

## Editor preset and remaining permission evidence

The normal Windows Desktop preset uses explicit selected runtime resources and exports an embedded x86_64 executable to `dist/Stylebreaker.exe` by default. It no longer excludes `pixel_art/` or `assets/Art/`. Editor export alone does not run all regression/ZIP audits; use the Python command for the tested package.

Character (Joe Idaho), enemy (Immortal Burrito) and UI (Adwit Rahman) creator terms remain independently unverified. Forest game-use terms and required Eder Muniz credit are documented; source asset redistribution is restricted. See [asset-license report](RC_ASSET_LICENSE_REPORT.md), [credits](RC_CREDITS.txt) and `tools/release_assets.json`. The owner explicitly requested nonblocking export warnings; this policy does not mark missing evidence as verified or apply the audio CC0 license to artwork.

Actual test/build results for this change: [WINDOWS_EXPORT_VALIDATION.md](WINDOWS_EXPORT_VALIDATION.md). No automatic merge, itch.io upload or publication.
