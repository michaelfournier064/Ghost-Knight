# Ghost Knight

A 3D horror-themed wave-survival action game built with **Godot 4.5**. Play as a skeleton knight fighting off waves of enemy skeletons in a haunted graveyard — survive for 7 minutes to win.

![Godot Engine](https://img.shields.io/badge/Godot-4.5-blue?logo=godotengine&logoColor=white)

## Gameplay

- **Genre:** 3D first-person action / wave survival
- **Objective:** Survive increasingly difficult waves of skeleton enemies for 7 minutes
- **Setting:** A haunted graveyard with gravestones, twisted trees, fences, and a haunted house

Enemies spawn on a timer that accelerates over time (from every 5 seconds down to every 1 second), and their speed scales up as the game progresses, creating steadily rising tension.

## Controls

| Action  | Default Binding |
|---------|----------------|
| Move    | W / A / S / D  |
| Sprint  | Shift          |
| Jump    | Space          |
| Dash    | F              |
| Attack  | Left Mouse     |
| Pause   | Escape         |

All key bindings are remappable in the Settings menu.

## Features

- **First-person melee combat** with animated attack sequences
- **Progressive difficulty** — enemy spawn rate and speed increase over time
- **Health & regeneration** — player regenerates 1 HP every 30 seconds
- **Save/Load system** — timestamped save files with full game state persistence (player position, health, enemies, elapsed time)
- **Settings** — master volume control and full key rebinding
- **Multiple UI screens** — title screen, load screen, settings, win/lose screens
- **Horror atmosphere** — background music, environmental sound effects, and dark visual theming
- **Low-poly 3D art style** using the KayKit Skeletons asset pack

## Project Structure

```
Code/              # GDScript source files
├── Player-Controller.gd   # First-person player movement, combat, camera
├── enemy.gd               # Enemy AI (chase/attack states, spawning)
├── FirstLevel.gd          # Level management, spawn timers, win condition
├── GameStateManager.gd    # Runtime game state (autoload singleton)
├── SaveManager.gd         # Save file creation and loading (autoload singleton)
├── SettingsLoader.gd      # Persists audio/input settings (autoload singleton)
├── LevelConfig.gd         # Level name → scene path mapping (autoload singleton)
├── AudioManager.gd        # Music playback and volume control (autoload singleton)
├── InputManager.gd        # Mouse capture mode management
├── settingsControl.gd     # Settings UI logic
├── keyRemapButton.gd      # Input rebinding buttons
├── titleScreen.gd         # Title screen menu
├── LoadScreen.gd          # Save browser UI
├── generalLevelUI.gd      # In-game HUD
├── WinScreen.gd           # Victory screen
├── LoseScreen.gd          # Defeat screen
└── quitGame.gd            # Quit button handler

Scenes/            # Godot scene files (.tscn)
Assets/
├── Images/        # Backgrounds, icons
├── ImportedPackages/  # KayKit Skeletons 3D models
├── ObjectModels/  # Gravestones, trees, fences, haunted house (.glb)
└── Sounds/        # Background music, environmental audio, UI sounds
```

## Architecture

The game uses several **autoload singletons** registered in [project.godot](project.godot):

| Singleton          | Purpose                                      |
|--------------------|----------------------------------------------|
| `AudioManager`     | Background music playback and volume control  |
| `SettingsLoader`   | Persists audio and input settings to disk     |
| `GameStateManager` | Stores and restores full game state as JSON   |
| `LevelConfig`      | Maps level names to scene file paths          |
| `SaveManager`      | Creates/loads timestamped save files          |

### Physics Layers

| Layer | Name          |
|-------|---------------|
| 1     | Player        |
| 2     | Player Attack |
| 3     | Enemy         |
| 4     | Enemy Attack  |
| 5     | Tree          |

## Getting Started

### Prerequisites

- [Godot Engine 4.5](https://godotengine.org/download) or later

### Running the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/michaelfournier064/Ghost-Knight.git
   ```
2. Open Godot Engine and import the project by selecting the `project.godot` file.
3. Press **F5** or click **Run** to start the game.

## Credits

- **3D Models:** [KayKit Skeletons](https://kaylousberg.itch.io/kaykit-skeletons) (free pack)
- **Engine:** [Godot Engine 4.5](https://godotengine.org/)
