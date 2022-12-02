---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/29/2021 2:14 AM
---

require('__stdlib__/stdlib/utils/defines/time')
require('util')
local Sprites = require('__stdlib__/stdlib/data/modules/sprites')
local Table = require('__stdlib__/stdlib/utils/table')

local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
local ERM_UnitTint = require('__enemyracemanager__/lib/rig/unit_tint')
local ERM_AnimationRig = require('__enemyracemanager__/lib/rig/animation')
local ERM_WeaponRig = require('__enemyracemanager__/lib/rig/weapon')
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')

local ERM_Sound = require('prototypes.sound')

local name = 'human-heavy-machinegun'

local health_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local hitpoint = 300
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value

local resistance_mutiplier = settings.startup["enemyracemanager-level-multipliers"].value
-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 85
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 95
-- Handles fire and explosive resistance
local base_fire_resistance = 10
local incremental_fire_resistance = 80
-- Handles laser and electric resistance
local base_electric_resistance = 0
local incremental_electric_resistance = 90
-- Handles cold resistance
local base_cold_resistance = 10
local incremental_cold_resistance = 80

-- Handles physical damages
local damage_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local base_physical_damage = 2
local incremental_physical_damage = 3

-- Handles Attack Speed
local attack_speed_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local base_attack_speed = 60
local incremental_attack_speed = 45

local attack_range = 9

local movement_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local base_movement_speed = 0.075
local incremental_movement_speed = 0.1

-- Misc settings
local vision_distance = 30

local pollution_to_join_attack = 100
local distraction_cooldown = 300

-- Animation Settings
local unit_scale = 1

local collision_box = {{-0.2, -0.2}, {0.2, 0.2}}
local selection_box = {{-0.4, -1.4}, {0.4, 0.2}}
local sticker_box = {{-0.2, -1}, {0.2, 0}}


function ErmRedArmy.make_human_heavy_machinegun(level)
    level = level or 1

    local human_miner = util.table.deepcopy(data.raw['character']['character'])
    --Level 1 animation, level 2 and 3 are armored animations
    -- types: running, running_with_gun, mining_with_tool
    local running_animation = human_miner['animations'][3]['running']
    ERM_UnitTint.mask_tint(running_animation['layers'][2], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(running_animation['layers'][4], ERM_UnitTint.tint_red())
    ERM_AnimationRig.adjust_still_frame_all(running_animation['layers'], CHARACTER_RIG_STILL_FRAME)

    local gun_animation = human_miner['animations'][3]['idle_with_gun']
    ERM_UnitTint.mask_tint(gun_animation['layers'][2], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(gun_animation['layers'][4], ERM_UnitTint.tint_red())

    data:extend({
        {
            type = "unit",
            name = MOD_NAME .. '/' .. name .. '/' .. level,
            localised_name = { 'entity-name.' .. MOD_NAME .. '/' .. name, level },
            icons = {
                {
                    icon = "__core__/graphics/icons/entity/character.png",
                    icon_size = 64,
                },
                {
                    icon = "__base__/graphics/icons/signal/signal_H.png",
                    icon_size = 64,
                    scale = 0.2,
                    shift = {-9,-9}
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            flags = { "placeable-enemy", "placeable-player", "placeable-off-grid", "breaths-air" },
            has_belt_immunity = false,
            max_health = ERM_UnitHelper.get_health(hitpoint, hitpoint * max_hitpoint_multiplier, health_multiplier, level),
            order = MOD_NAME .. '/'  .. name .. '/' .. level,
            subgroup = "enemies",
            shooting_cursor_size = 2,
            resistances = {
                { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
                { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
                { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, resistance_mutiplier, level) },
                { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
                { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
                { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
                { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
                { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, resistance_mutiplier, level) }
            },
            map_color = REDARMY_MAP_COLOR,
            healing_per_tick = ERM_UnitHelper.get_healing(hitpoint, max_hitpoint_multiplier, health_multiplier, level),
            --collision_mask = { "player-layer" },
            collision_box = collision_box,
            selection_box = selection_box,
            sticker_box = sticker_box,
            vision_distance = vision_distance,
            movement_speed = ERM_UnitHelper.get_movement_speed(base_movement_speed, incremental_movement_speed, movement_multiplier, level),
            pollution_to_join_attack = pollution_to_join_attack,
            distraction_cooldown = distraction_cooldown,
            ai_settings = biter_ai_settings,
            spawning_time_modifier = 2,
            attack_parameters =
            {
                type = "projectile",
                ammo_category = "redarmy-damage",
                range = attack_range,
                min_attack_distance = attack_range - 3,
                cooldown = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed, attack_speed_multiplier, level),
                damage_modifier = ERM_UnitHelper.get_damage(base_physical_damage, incremental_physical_damage, damage_multiplier, level),
                shell_particle =
                {
                    name = "shell-particle",
                    direction_deviation = 0.1,
                    speed = 0.1,
                    speed_deviation = 0.03,
                    center = {0, 0.1},
                    creation_distance = -0.5,
                    starting_frame_speed = 0.4,
                    starting_frame_speed_deviation = 0.1
                },
                projectile_creation_distance = 1.125,
                sound = ERM_Sound.heavy_machine_gun(),
                ammo_type = ERM_WeaponRig.get_bullet('redarmy-damage'),
                animation = gun_animation
            },
            distance_per_frame = 0.1,
            run_animation = running_animation,
            dying_sound = ERM_Sound.death(0.75),
            corpse = "common-red-army-corpse-3"
        }
    })
end
