# Western Survive

**Western Survive** is a 2D prototype made in Godot, inspired by arena survival games, featuring a Wild West theme, upgrade progression, local multiplayer, and stages with their own rules.

The project was organized to be lightweight on GitHub: only game files, scripts, scenes, shaders, tests, and documentation are included. Exported builds, local cache, and the portable engine are kept out of the repository.

## Features

- 2D arena survival with a western setting.
- 4 starting stages: Ghost Town, Broken Fort, Red Canyon, and Abandoned Mine.
- 1 bonus stage: Eclipse Rail.
- 4 playable characters: Gunslinger, Sheriff, Bounty Hunter, and Healer.
- 8 base weapons and 4 unlockable secret weapons.
- Upgrade system up to level 5 per weapon.
- Local multiplayer for 1 to 4 players.
- Scenario items, such as food and bombs.
- Abandoned Mine with limited vision and lanterns.
- Code-generated music, with no external audio files.
- Menu with master volume, music, resolution, fullscreen, language, and player count.

## Unlocks

| Condition | Unlock |
| --- | --- |
| Level 5 Revolver in Ghost Town | Golden Revolver |
| Level 5 Shotgun in Broken Fort | Coach Gun |
| Level 5 Rifle in Red Canyon | Rail Spike |
| Level 5 Fire Bottle in Abandoned Mine | Ghost Lantern |
| All 4 secret weapons unlocked | Eclipse Rail |

## Synergies

| Character | Synergy |
| --- | --- |
| Gunslinger | Golden Revolver |
| Sheriff | Coach Gun |
| Bounty Hunter | Rail Spike, with starting rifle |
| Healer | Ghost Lantern |

## Controls

- Player 1: WASD or arrow keys.
- Player 2: IJKL.
- Player 3: TFGH.
- Player 4: Numpad 8456.
- Controller: Left analog stick, one controller per player.
- Player 1 aims with the mouse.
- Esc pauses the game.

Base weapons for Player 1 fire in the direction of the mouse pointer. Extra players aim based on their movement or controller direction. Secret weapons use auto-aim on the nearest enemy.

In local multiplayer, the group shares XP, upgrades, weapons, and unlocks. The run ends when all players fall.

## How to open in Godot

1. Install Godot 4.x.
2. Open the `project/` folder.
3. Run the main scene:

```text
res://scenes/main.tscn
