# Event Contracts v0.1

Planned stable gameplay events:

- `attack_started(actor, attack_data)`
- `damage_dealt(attacker, victim, attack_data)`
- `enemy_launched(enemy, velocity)`
- `enemy_killed(enemy)`
- `style_changed(rank, score)`
- `combat_started(arena)`
- `combat_finished(arena)`

Only `style_changed(rank, score)` exists in the current slice. Other events are reserved for the next refactor so agents can integrate VFX, audio, telemetry and encounters without cross-module dependencies.
