# Stylebreaker — Pre-Alpha v0.1.0 release-candidate record

**NOT READY FOR PUBLIC RELEASE.** Character, enemy and UI rights are unresolved; forest terms/provenance need review. Native Windows, physical controller/audio and manual balance/performance tests remain pending. No merge or itch.io upload is authorized by this record.

Branch: `release/prealpha-v0.1.0-rc`, based on approved integration merge `d319aae`.
Default startup: `res://pixel_art/arena.tscn`; fallback: `res://levels/main.tscn`.
Combat timings, hitboxes, AI, scoring and wave progression are unchanged. Input setup gains the missing controller-A menu confirmation binding; this fixes a reproduced startup issue.

## Validation record

Godot 4.6.3 stable; official Windows/Linux release templates fingerprinted in
[template provenance](RC_TEMPLATE_PROVENANCE.json). Validation is running; final
commands, results, artifact locations and checksums will be recorded here after it completes.

Machine-local logs/artifacts are under `builds/rc-private-qa/`. Public packaging
stops on unresolved rights, without a new public ZIP. Private QA exports use a
temporary selected-resource preset; committed public exclusions remain intact.

See [asset report](RC_ASSET_LICENSE_REPORT.md), [player instructions](PLAYER_README.txt),
[credits](RC_CREDITS.txt), [changelog](RC_CHANGELOG.md) and [draft itch.io page](ITCHIO_PREALPHA_V0.1.0.md).
