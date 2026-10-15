# Native Windows sign-off — NOT TESTED

Owner-local QA only; asset rights remain unresolved. Do not distribute the private QA ZIP. Linux embedded-pack tests do not complete this checklist.

Record before play:

- Tester/date: **pending**
- Windows version / x86_64: **pending**
- GPU / driver / display resolution: **pending**
- Controller model / connection: **pending**
- ZIP and executable SHA-256: compare with [artifact record](RC_ARTIFACTS.json).

PowerShell hash check:

```powershell
Get-FileHash .\Stylebreaker.exe -Algorithm SHA256
```

Extract the entire archive to a fresh folder outside the repository/editor. Keep credits/licenses alongside the executable. Run the actual `Stylebreaker.exe`, not Godot loading its data pack.

- [ ] Starts outside editor without missing resources, DLL errors, crash or black screen; default scene shows pixel-art forest, fighter and health bar.
- [ ] Title: keyboard Enter and actual controller A start; instructions and buttons readable.
- [ ] A/D and stick movement, single/double jump, both facings, dash and invulnerability/cancel work.
- [ ] J/light ground chain, K/launcher, aerial chain and slam connect; damage/HP/Style behave as described.
- [ ] Enemy warning/attack/damage/death visible; sprites align with feet and floor.
- [ ] Camera/parallax/Lights behave at arena edges, during jump and fullscreen/window resize; no blurry pixel scaling or hidden critical HUD.
- [ ] Actual controller A/B/X/Y, Start and Back work; reconnect/device behavior recorded.
- [ ] Audible SFX work; M mute/unmute; pause/resume and F11 work.
- [ ] Clear all five waves by normal play; verify counts 2/3/3/4/5 and victory/retry.
- [ ] Trigger defeat, retry, restart during attacks/impact and pause; no stuck timers/input or leftover enemies.
- [ ] Record performance/frame pacing and balance problems; no unexplained repeatable input failures.

Outcome: **PENDING — native Windows execution has not been tested.**

Attach hardware details, exact artifact hashes and defects/pass results. Even a completed private QA playtest cannot clear missing art rights. After licensing changes require a new public candidate, repeat extraction/hash/startup checks on that exact candidate before approval.
