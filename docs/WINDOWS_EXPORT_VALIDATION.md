# Windows export workflow validation — 15 October 2026

Branch: `release/windows-export-no-license-gate`, based on `origin/main` 788caee.

Completed so far: Python packaging tests (8 passed), source cleanup/missing-resource audit, Godot 4.6.3 source import and an actual export using the unchanged normal Windows Desktop preset. The normal preset now includes approved pixel assets without quarantine. No Godot errors/warnings were reported in those import/export logs. Full normal-command ZIP and extracted-pack checks are in progress; final results will replace this progress note.

No player/enemy gameplay code, animation/collision resources, uploaded artwork, attack data, main scene setting or audio files were changed. The unused root `main.tscn` restored in 788caee referenced deleted SVGs and scripts; it was removed and recorded in the deletion ledger.

Three character/enemy/UI evidence groups remain unverified. Their status is reported, not used as a hard-fail condition. Forest terms, creator credits and all existing evidence remain. No new art, merge, publication or upload.

This execution environment is Linux. Windows path/template branches have unit coverage; no native Windows, PowerShell, physical controller or audible-output test is claimed. The script supports host Windows startup checks, but those require an actual Windows run.
