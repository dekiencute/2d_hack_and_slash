# Stylebreaker pre-alpha playtest

Clear five waves. Enemies get tougher each wave, with at most two attack windups at once. Keyboard/controller controls are on the title and pause screens; see [player readme](docs/PLAYER_README.txt).

Try `J → J → K → Jump → J → J → K`. Double-jump and dash are preserved. Air light hits suspend both the player and an airborne target. Watch the gold rings and `! STRIKE !` before enemy strikes.

Evaluate responsiveness, launcher follow-up/juggles, visibility of warnings in crowds, defensive dash usefulness, and whether move variety feels worthwhile. There are no new weapons or combat rules in this release.

Before public Windows release, extract the candidate ZIP into a fresh directory, run the executable outside the editor, and play through victory and defeat. Check keyboard/controller input, SFX/mute, pause during a windup, R retry during hitstop, and full-screen/resized UI. Record Windows version, GPU and controller. Automated lethal-hit wave progression tests do not validate difficulty or replace a human playthrough.

AnimationPlayer still keys `Sprite.animation` and `Sprite.frame`, with AnimationTree selecting states. The new original atlases retain those frame regions and timings. Move data and five-wave tuning are unchanged.
