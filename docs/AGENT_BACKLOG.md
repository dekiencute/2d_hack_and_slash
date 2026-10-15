# Agent Backlog

## P0 — Combat Engineer
- Replace permissive dash cancel with per-move cancel windows.
- Add ComboGraph resource.
- Add gun shot that preserves juggle.

## P0 — QA Agent
Test cases:
- Ground light chain always advances 1 -> 2 -> 3.
- Combo resets after timeout.
- Heavy launches grounded dummy.
- Air light can hit launched dummy.
- Air heavy sends target downward.
- Same-move spam awards less style.
- Dash does not leave hitbox active.

## P1 — Enemy AI Agent
- Create Grunt with idle/chase/telegraph/attack/hitstun/airborne/dead states.
- Only one attack slot until CombatDirector exists.

## P1 — VFX Agent
- Hit spark event consumer.
- Slash trail placeholder.
- Camera punch on launcher/heavy.

## Human gate
Do not proceed to content production until this combo feels good:

`Light -> Light -> Launcher -> Jump -> Air Light -> Air Light -> Air Heavy`
