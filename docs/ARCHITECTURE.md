# Architecture v0.1

## Rule

Combat behavior must remain data-driven. Do not add move-specific damage logic to `player.gd`.

## Modules

- `actors/player`: locomotion and player combat orchestration
- `actors/enemies`: enemy state/reaction implementation
- `combat/attacks`: reusable AttackData schema
- `combat/hitboxes`: hit detection and DamageEvent boundary
- `resources/attacks`: tunable move definitions
- `systems/style`: style scoring independent from player code
- `systems/hitstop.gd`: impact freeze service
- `ui`: presentation only

## Agent ownership

- Combat Engineer: player combat, AttackData, hitbox contracts
- Enemy AI Agent: enemy states; must consume AttackData rather than inspect player internals
- Technical Designer: `.tres` tuning only unless spec requires code change
- VFX Agent: reacts to combat events; must not calculate damage
- QA Agent: regression scenarios and edge-case reproduction

## Non-negotiable contract

A hit goes through:

`AttackData -> AttackHitbox -> target.receive_hit(AttackData, facing, attacker)`

Style scoring is downstream of a confirmed hit.
