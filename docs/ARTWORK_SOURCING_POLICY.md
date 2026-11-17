# Artwork sourcing and approval — Stylebreaker

**Direction:** human-created pixel art only. Generative AI imagery and AI-generated placeholder sprites are not acceptable for game artwork.

## Agent sourcing workflow

1. Search artist storefronts and asset libraries (e.g., itch.io asset packs, OpenGameArt, GameDev Market, artist portfolios).
2. Provide candidate source links, creator names, preview images where legitimately available, licensing evidence, dimensions, animation list, price, and style-compatibility notes.
3. Check that the source actually states permission to use the artwork in a **commercial compiled game**. Also check attribution, modification, credit, exclusivity, and asset source-file redistribution restrictions.
4. Mark evidence as **verified**, **pending**, or **not permitted** with dated links or saved license documents.
5. Get the Game Director's approval **before acquiring and importing** a candidate.
6. For approved assets, retain source/provenance in the project manifest, record required credits, and run pixel-art validation. Never silently replace existing sprites.

## Candidate evaluation
- Aesthetic: cohesive with existing Stylebreaker pixel art, readable attacks and silhouettes.
- Technical: consistent pixels-per-unit, frame dimensions, pivots, directional coverage, required actions.
- Gameplay: attack wind-up, recovery, telegraph clarity, air-combat states, hit reaction animations.
- Licensing: commercial compiled-game permission is mandatory; don't bundle source art if prohibited.

## Existing rights
See `docs/RC_ASSET_LICENSE_REPORT.md` and `tools/release_assets.json`. Some current character, enemy, and UI licenses are still **pending independent evidence**. Preserve these statuses. A build warning is not a license clearance and a playable QA export is not public distribution approval.

## Director sign-off template
- Asset/source:
- Creator:
- Commercial-use evidence:
- Source redistribution/attribution terms:
- Style fit and intended gameplay purpose:
- Director decision: Approve / Reject / Request alternatives
- Approved on / reference:
