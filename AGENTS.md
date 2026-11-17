# Stylebreaker — AI Studio Operating Rules

## Authority
- The human Game Director owns creative direction, gameplay feel, art direction, and final playtest approval.
- Codex Lead Agent owns technical planning, task boundaries, integration proposals, and reporting.
- Implementation agents may work on isolated Git worktrees. A QA agent should independently review changes.
- No agent may merge to `main`, publish a release, upload to itch.io, or change approved game art without explicit Game Director authorization.

## Project baseline
- Preserve the existing Godot 4.7.2 project, `res://pixel_art/arena.tscn`, current pixel-art assets, and existing systems.
- Audit before implementation; do not recreate mechanics already working.
- Prioritize responsive movement, combos, dodge, launcher, aerial flow, and readable combat.
- Respect scene references, resource UIDs, and current export configuration.
- No AI-generated visual art or placeholders. Existing synthesized SFX may remain; do not misrepresent them as third-party assets.

## Artist-sourced artwork
- Agents may SEARCH for human-created pixel-art assets and present a shortlist with creator, source URL, price, style, animation coverage, resolution, and licensing evidence.
- Do not buy, download into the game, modify, or commit external artwork without Director approval.
- Only use assets with evidence permitting inclusion in a commercial compiled game, with attribution and redistribution restrictions recorded.
- Never assume that free-to-download, Creative Commons, or itch.io automatically means commercial use or source redistribution is allowed.
- Existing unresolved license statuses must remain unresolved until supported by actual independent evidence.
- Keep an asset provenance entry and license/credit evidence for every new approved asset.

## Implementation / quality gates
1. Establish the task acceptance criteria and file ownership before parallel implementation.
2. Work in separate branches/worktrees when tasks are independent.
3. Run `godot --headless --editor --path . --import --quit`, the project regression scripts, and `python tools/check_pixel_only.py` where available.
4. Build using the existing `python tools/release.py` pipeline; do not replace it with a weaker unchecked export.
5. Report exact checks run, failures, build location, commit SHA, changed files, risks, and missing asset rights.
6. Automated checks cannot certify combat game feel. Human Windows playtest is mandatory for gameplay approval.
7. Submit a draft pull request for review. Do not auto-merge unless the Director explicitly enables a documented merge policy.
8. Any change after a human playtest invalidates approval for that previously tested commit/build.

## First milestone
Preserve and assess the existing player controller, attacks, dash, jump, hitboxes, hitstop, enemy waves, style system, and build tests. Prioritize targeted improvements only after the Director approves a gap analysis.
