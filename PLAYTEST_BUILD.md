# Stylebreaker Arena Playtest

This build is intentionally focused on combat feel rather than content.

## Goal
Clear five waves. Enemies become slightly tougher each wave. A maximum of two enemies are allowed to attack at once so encounters stay readable.

## Controls
- A / D — Move
- Space — Jump / Double jump
- Shift — Dash; the player is invulnerable during the dash window
- J — Ground/Air light combo
- K — Ground launcher / Air heavy slam
- R — Restart the whole arena

## Suggested combo
J -> J -> K -> Jump -> J -> J -> K

Air light hits briefly suspend both the player and an airborne enemy, helping you continue a juggle.

## What to evaluate
1. Does moving into an attack feel responsive?
2. Does the launcher naturally invite you to jump after the enemy?
3. Does air suspension make juggling satisfying or too floaty?
4. Are enemy yellow/orange attack telegraphs readable?
5. Does fighting 2-5 enemies create pressure without feeling random?
6. Is Dash useful enough as a defensive/cancel tool?

## Architecture change in this build
AnimatedSprite2D no longer owns playback timing. AnimationPlayer now keys both `Sprite.animation` and `Sprite.frame`, while AnimationTree chooses the state. This prevents one-shot attacks such as Launcher from stopping AnimatedSprite2D playback and leaving later animations frozen.
