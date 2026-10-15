# Uploaded art preview

Open `art_preview.tscn` in Godot and press **F6**. F5 still opens the arena.

```sh
godot --path . preview/art_preview.tscn
```

Select Characters, Enemy, Pixel UI, or Source/reference. Search, play/pause or step/scrub frames; choose integer zoom, sheet/frame views, cell borders, background and horizontal flip. Space plays/pauses, Left/Right step. UI alpha-bound viewing changes only the displayed rectangle. Scroll to inspect large sheets or high zoom levels.

Source files remain unchanged. FPS is for inspection; character strips have no supplied timing metadata. Enemy AttackCombo and Death counts differ between PNG and Aseprite source and are flagged. Aseprite/PSD/GIF entries show metadata; use native authoring tools to inspect those files further.

All packs need license verification before integration/distribution. Character PNG hashes match the historical Dante assets. Neither upload nor attribution supplies a license.

See [complete asset review](../docs/ART_ASSET_REVIEW_2026-10-15.md). Rebuild only the metadata catalog with `python3 tools/audit_art_assets.py` (Pillow required). The scene itself requires only Godot and the existing uploads. Preview and uploaded art are excluded from release presets.
