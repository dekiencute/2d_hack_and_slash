# Stylebreaker — Pre-Alpha 0.1.0 release gate (15 October 2026)

Goal: publish a **working Windows prototype** on itch.io today, marked **In development**. Do not ship if the exported build does not start or assets are unlicensed.

## Confirmed from source
- Godot project name: `Stylebreaker Prototype`; main scene `res://levels/main.tscn`.
- Game loop: 5 waves, HP, enemy attack-token cap, defeat/victory and R restart.
- Player scene has animated sprite references, including `resources/Characters/Dante/`.
- Environment in `levels/main.tscn` references the mist-forest-background layer textures.
- Existing controls: A/D, Space, Shift, J, K, R.
- `export_presets.cfg` contains a Windows Desktop preset with an export path in `builds/`.
- The project's `project.godot` declares `config/features=PackedStringArray("4.7")`; verify installed Godot and compatible export templates.

## BLOCKING checks (complete before Public)
- [ ] Open exact clone in Godot; import finishes without errors and main scene starts with F5.
- [ ] Confirm all sprite/background/resource files referenced from .tscn exist in the clone.
- [ ] Confirm license and redistribution rights for ALL character/environment/audio assets. Especially review any "Dante" character sprites for copyrighted game-derived material. Replace unauthorized art before publishing.
- [ ] Confirm five waves, game over, victory, R restart, inputs and HUD work in a playtest.
- [ ] Export Windows release build; ensure .exe and .pck are both included if PCK is separate; launch it outside the editor.
- [ ] Test archive extracted to a fresh directory; check missing DLL/assets and crash behavior.
- [ ] Prepare actual in-game screenshots, a game cover, credits/licenses, and an honest limitations note.
- [ ] Upload the verified ZIP to itch.io; select Windows and **In development**, then validate download on itch.io.

## Priorities / scope freeze
P0: resolve launch/import failures; licensing; five-wave combat loop; Windows export.
P1: coherent original/player/enemy/environment sprites, hit effects, basic SFX, title/controls/credits, cover and screenshots.
P2: Web export (only if Windows passes), polish, new mechanics.
Avoid adding a new combat system, extra weapons, a boss or extensive menus before the initial release.

## Windows export instructions
1. Godot > Editor > Manage Export Templates; install templates matching the installed Godot version.
2. Project > Export > Windows Desktop; choose a valid export path, such as `builds/Stylebreaker-PreAlpha-0.1.0.exe`.
3. Export Project (release build). Depending on the embed PCK setting, keep the resulting .pck alongside the .exe.
4. ZIP the build output and test the extracted ZIP on Windows.

## Cloud workflow
- Codex Cloud can inspect and edit this GitHub repo without a local VS Code MCP login.
- Codex's cloud environment is distinct from the Godot Editor on your PC. Do not claim editor integration or game execution without actual tool/runtime evidence.
- Ask Codex to run Godot headless import + scene validation if a matching Godot binary is available; otherwise run locally in Godot.
- Merge reviewed changes, then in GitHub Desktop Fetch origin > Pull origin before local playtesting/export.
- Commit only source/assets to Git; do not commit generated Godot cache or packaged builds.

## Go/no-go
**GO**: licensed assets + repeatable 5-wave run + exported archive independently opens + download works.
**NO-GO**: any critical crash, missing resource or unclear rights to shipped sprites. Itch.io page can stay Draft/Restricted until ready.
