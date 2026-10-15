# Stylebreaker Prototype

Godot 4.x greybox prototype for a 2D stylish hack & slash inspired by the combat principles of Devil May Cry.

## Current playable slice

- Run and directional facing
- Double jump
- Ground/air dash
- 3-hit light combo
- Heavy ground launcher
- Air light attack
- Air heavy finisher
- Input buffering
- Enemy hitstun / knockback / launch / aerial juggle
- Hitstop
- Style score with repetition penalty and decay
- Two resettable training dummies

## Controls

| Action | Keyboard | Controller |
|---|---|---|
| Move | A / D | Left stick |
| Jump / Double Jump | Space | South / A |
| Dash | Shift | East / B |
| Light Attack | J | West / X |
| Heavy / Launcher | K | North / Y |
| Reset | R | - |

Suggested test combo:

`J → J → K → Jump → J → J → K`

## Run

Open this directory in Godot 4.x and press F6/F5.

This milestone intentionally uses vector placeholders. Art integration comes after combat timing is validated.

## Playtest Arena build
This revision is a five-wave combat playtest rather than a static dummy room.

- A / D: move
- Space: jump / double jump
- Shift: dash (invulnerable during the dash)
- J: light combo
- K: ground launcher / air heavy
- R: restart the arena

The player has 100 HP. Enemies telegraph attacks by turning yellow/orange, and only two enemies may attack at the same time. Clear five waves to finish the run.
