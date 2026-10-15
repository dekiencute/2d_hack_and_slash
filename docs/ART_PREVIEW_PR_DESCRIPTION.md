Add a separate `preview/art_preview.tscn` scene to inspect the uploaded art without touching gameplay scenes, scripts or visuals. F6 opens the browser; F5 remains the arena. The browser provides character/enemy/UI/source categories, search, animation playback/stepping/scrubbing, integer zoom, nearest filtering, grid/sheet/alpha views and original source metadata. No image files or new art were generated or modified.

The audit covers all 86 uploads, 39 PNG textures, 54 browser entries and 181 frame regions. Character strips use 80×48 cells. Enemy AttackCombo and Death PNG counts differ from Aseprite source tags (7/8 and 9/11); UI canvases need selected regions/fill setup. No pack includes a license grant, and all 19 character hashes match historical Dante files, so all uploaded packs need license verification before integration/distribution.

Restore the unrelated 4.7 feature-marker and stretch-setting edits to the tested 4.6/keep baseline while retaining intentional pixel filtering/snapping from ART_DIRECTION.md. Exclude the preview and unverified art from release presets; an actual exported PCK confirms their absence and gameplay resources' presence.

Validation with Godot 4.6.3:
- 80 headless preview checks and 83 X11/OpenGL rendered checks pass, including all PNG loads/regions and UI interactions; three inspection captures visually checked.
- Existing gameplay regression: 47 checks pass.
- Headless import, metadata decoding/regeneration, unchanged-upload hashes and scope/diff checks pass.
- Only rendered-platform warning: virtual display cannot change V-Sync.

Native authoring tools, rights/entitlement and Windows executable execution were not tested; no Windows build/publication is claimed. See `docs/ART_ASSET_REVIEW_2026-10-15.md` for full per-asset dimensions, frame counts, compatibility, license findings and reproduction commands.
