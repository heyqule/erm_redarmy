---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/29/2021 2:14 AM
---


require('util')
local biter_ai_settings = require ("__base__.prototypes.entity.biter-ai-settings")
local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
local ERM_UnitTint = require('__enemyracemanager__/lib/rig/unit_tint')
local ERM_AnimationRig = require('__enemyracemanager__/lib/rig/animation')
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')

local ERM_Sound = require('prototypes.sound')
local HumanAnimation = require('prototypes.human_animation')

local name = 'human-miner'

local hitpoint = 85
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value * 8


-- Handles acid and poison resistance
local base_acid_resistance = 10
local incremental_acid_resistance = 65
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 75
-- Handles fire and explosive resistance
local base_fire_resistance = 0
local incremental_fire_resistance = 75
-- Handles laser and electric resistance
local base_electric_resistance = 15
local incremental_electric_resistance = 60
-- Handles cold resistance
local base_cold_resistance = 10
local incremental_cold_resistance = 65

-- Handles physical damages

local base_physical_damage = 10
local incremental_physical_damage = 190

-- Handles Attack Speed

local base_attack_speed = 60
local incremental_attack_speed = 30

local attack_range = 1

local base_movement_speed = 0.1
local incremental_movement_speed = 0.175

-- Misc settings
local vision_distance = ERM_UnitHelper.get_vision_distance(attack_range)

local pollution_to_join_attack = 8
local distraction_cooldown = 300

-- Animation Settings
local unit_scale = 1

local collision_box = { { -0.2, -0.2 }, { 0.2, 0.2 } }
local selection_box = { { -0.4, -1.4 }, { 0.4, 0.2 } }
local sticker_box = { { -0.2, -1 }, { 0.2, 0 } }

function ErmRedArmy.make_human_miner(level)
    level = level or 1

    local human_animation = HumanAnimation.get_animation()
    --Level 1 animation, level 2 and 3 are armored animations
    -- types: running, running_with_gun, mining_with_tool
    local running_animation = human_animation['animations'][1]['running']
    ERM_UnitTint.mask_tint(running_animation['layers'][2], ERM_UnitTint.tint_red_madder())
    ERM_AnimationRig.adjust_still_frame(running_animation['layers'][1], CHARACTER_RIG_STILL_FRAME)
    ERM_AnimationRig.adjust_still_frame(running_animation['layers'][2], CHARACTER_RIG_STILL_FRAME)
    ERM_AnimationRig.adjust_still_frame(running_animation['layers'][3], CHARACTER_RIG_STILL_FRAME)

    local mining_animation = human_animation['animations'][1]['mining_with_tool']
    ERM_UnitTint.mask_tint(mining_animation['layers'][2], ERM_UnitTint.tint_red_madder())

    data:extend({
        {
            type = "unit",
            name = MOD_NAME .. '--' .. name .. '--' .. level,
            localised_name = { 'entity-name.' .. MOD_NAME .. '--' .. name, GlobalConfig.QUALITY_MAPPING[level] },
            icons = {
                {
                    icon = "__core__/graphics/icons/entity/character.png",
                    icon_size = 64,
                },
                {
                    icon = "__base__/graphics/icons/signal/signal_M.png",
                    icon_size = 64,
                    scale = 0.2,
                    shift = { -9, -9 }
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            flags = { "placeable-enemy", "placeable-player", "placeable-off-grid", "breaths-air" },
            has_belt_immunity = false,
            max_health = ERM_UnitHelper.get_health(hitpoint, max_hitpoint_multiplier, level),
            order = MOD_NAME .. '--unit--' .. name .. '--' .. level,
            subgroup = "enemies",
            shooting_cursor_size = 2,
            resistances = {
                { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
                { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
                { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, level) },
                { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
                { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
                { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
                { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
                { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, level) }
            },
            map_color = ERM_UnitHelper.format_map_color(settings.startup[FORCE_NAME.."-map-color"].value),
            healing_per_tick = ERM_UnitHelper.get_healing(hitpoint, max_hitpoint_multiplier, level),
            --collision_mask = { "player-layer" },
            collision_box = collision_box,
            selection_box = selection_box,
            sticker_box = sticker_box,
            vision_distance = vision_distance,
            movement_speed = ERM_UnitHelper.get_movement_speed(base_movement_speed, incremental_movement_speed, level),
            absorptions_to_join_attack = { pollution = ERM_UnitHelper.get_pollution_attack(pollution_to_join_attack, level)},
            distraction_cooldown = distraction_cooldown,
            ai_settings = biter_ai_settings,
            attack_parameters = {
                type = "projectile",
                ammo_category = 'redarmy-damage',
                range = attack_range,
                cooldown = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed, level),
                cooldown_deviation = 0.1,
                ammo_type = ERM_UnitHelper.make_unit_melee_ammo_type(ERM_UnitHelper.get_damage(base_physical_damage, incremental_physical_damage, level)),
                sound = ERM_Sound.mining(0.5),
                animation = mining_animation
            },
            distance_per_frame = 0.1,
            run_animation = running_animation,
            dying_sound = ERM_Sound.death(0.75),
            corpse = "common-red-army-corpse"
        }
    })
end
