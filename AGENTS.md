# ERM Redarmy — AGENTS.md

## What this is

Factorio 2.0 mod adding a human Red Army enemy force (units, turrets, buildings, planet Earth, boss mode). Requires `enemyracemanager >= 2.0.46` as the framework.

## Architecture

- **Force name / MOD_NAME**: `enemy_erm_redarmy` (set in `global.lua`)
- **Entrypoints** (loaded by Factorio in order):
  - `global.lua` — constants, toggle `DEBUG_MODE = true`
  - `data.lua` — prototypes for all units/turrets/buildings, boss data, economy, planets, tips
  - `data-updates.lua` — mods map-gen presets & Nauvis autoplace controls
  - `settings.lua` / `settings-updates.lua` — registers map color, inserts MOD_NAME into ERM multi-force settings, tunes factorio-world defaults
  - `control.lua` — runtime: init, base building, nuclear silo, artillery, remote API
- **No build system, no tests, no linter, no CI** — standard Factorio mod, zip & drop into mods folder
- **`scripts/`** — runtime logic (event-driven, Factorio control stage)
- **`prototypes/`** — data stage definitions (entities, enemies, buildings, economy, planets, noise functions)
- **`city_jsons/`** — Python tool (`city_blueprint.py`) to decode/center/encode Factorio blueprint strings
- **`locale/`** — translations (en, ru, uk, de, fr)
- **`migrations/`** — Factorio migration JSON for save compat
- **`bases.lua`** — hardcoded blueprint strings for town/city generation on planet Earth

## Key conventions

- All entity names are prefixed with `enemy_erm_redarmy--` (e.g. `enemy_erm_redarmy--human-miner--3`)
- Units are created per-level via a loop calling `ErmRedArmy.make_<unit>(i)` for `i=1..max_level` in `data.lua`
- Quality system is used for leveling (not old leveling system) — Factorio 2.0 quality spawning
- Boss mode only activates when both `space-age` and `quality` mods are present
- `DEBUG_MODE` in `global.lua` is `true` — boss idle attacks are 5 ticks instead of real intervals when on
- All units have `can_open_gate = true`
- Flat resistances: 75% for units/turrets, 50% for spawners
- Scout units: land = `human-miner`, aerial = `plane-gunner`

## Planet Earth

- Requires `factorio-world >= 2.1.3`; only builds towns on surface named `earth`
- Town/city generation via blueprint strings in `bases.lua` + on_chunk_generated event
- `space-age` required for Earth as a space-travel destination (space-connection, planet-discovery tech, psi-radar)
- Tuned default factorio-world settings in `settings-updates.lua`: map-gen-scale=10, safe-zone-size=12
- Earth is ignored for interplanetary attacks and indestructible rail entities

## Economy (space-age only)

- Organs (`enemy_erm_redarmy--organ`) drop from Lab spawners (tiers 2-5); furnace/assembling-machine have 33% drop probability
- Recipes convert organs → biter eggs, nutrients, military items, promethium; organs spoil → spoilage

## Boss mode

- Boss building: `boss_rocket_silo` (spawned via `boss_custom_spawn` remote API)
- Assisted spawner: `boss_lab`
- Attack data registered as `mod-data` in data stage, consumed at runtime by `enemyracemanager`
- Five attack phases: Defense, Ultimate, Special, Assist, Heavy, Basic
- Boss tiers: 5 (matching `GlobalConfig.BOSS_MAX_TIERS`)

## Remote API (`scripts/remote.lua`)

Exposed as `remote.add_interface("erm_redarmy", ...)`:
- `register_new_enemy_race()` — returns `MOD_NAME`
- `milestones_preset_addons()` — milestone kill tracking
- `print_global()` — dumps `storage` to file for debug
- `refresh_custom_attack_cache()` — reloads custom attack group settings
- `interplanetary_attack_ignore_planets()` / `register_ignore_planet_for_indestructible_entity()` — return `{'earth'}`
- `advanced_target_priorities_register_section_data()` — targeting priority config
- `boss_custom_spawn(radar, is_test)` — converts nearest level-5 rocket silo to boss

## Enemy race registration (`scripts/initialize.lua`)

- 3 tiers of units, turrets, command centers, support structures
- Custom attacks: dropship (`emrmy-dsh`), engineer builder (`emrmy-gin`), guerrilla (`emrmy-grl`)
- Featured squad groups for ground and flying units
- Emotion/behavior system via `enemyracemanager` framework

## City blueprint tool (`city_jsons/city_blueprint.py`)

Reads `building.txt`, writes decoded+centered blueprint to `result.json` and re-encoded string to `result.txt`.

## Other

- No npm/pip/package manager needed
- Mod zip filename pattern: `erm_redarmy_<version>.zip`
- `.gitignore` excludes `.png`, `.ogg`, `sounds/`, `graphics/`, `*.txt`, `*.json`, and binary artifacts
- `LICENSE` is GPL v3