# Event contracts — pre-alpha 0.1.0

Implemented signals:

| Source | Signal | Consumer |
|---|---|---|
| Player | `health_changed(current, maximum)` | Arena forwards HP to HUD. |
| Player | `died` | Arena ends the run. |
| Player | `attack_started(data)` | CombatFeedback plays swing VFX/SFX. |
| Player | `dash_started`, `damaged` | CombatFeedback plays dash/hurt feedback. |
| AttackHitbox | `hit_confirmed(target, data, direction)` | CombatFeedback plays impact VFX/SFX after `receive_hit`. |
| Enemy | `died(enemy)` | Arena releases attack token and advances waves. |
| StyleSystem | `style_changed(rank, score)` | HUD displays live Style. |
| HUD | `start_requested`, `restart_requested`, `pause_requested` | Arena owns run/menu state. |

A confirmed hit still follows `AttackData → AttackHitbox → target.receive_hit(AttackData, facing, attacker)`. Style and hitstop remain downstream of the confirmed hit. Presentation consumes signals without calculating damage or changing move timing. `attack_started` has no actor argument because each feedback service belongs to this single-player arena.

Future shared actor events (`damage_dealt`, `enemy_launched`, `combat_started`, `combat_finished`) remain unimplemented and must not be assumed to exist. New weapons and combat graph changes are outside this release.
