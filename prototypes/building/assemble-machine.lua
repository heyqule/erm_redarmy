---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/28/2021 9:38 PM
---



require("util")

local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
local ERM_UnitTint = require('__enemyracemanager__/lib/rig/unit_tint')
local ERM_Sound = require('prototypes.sound')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')

local enemy_autoplace = require("__enemyracemanager__/prototypes/enemy-autoplace")
local name = 'assemble-machine'

-- Hitpoints

local hitpoint = 450
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value * 2


-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 50
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 50
-- Handles fire and explosive resistance
local base_fire_resistance = 10
local incremental_fire_resistance = 40
-- Handles laser and electric resistance
local base_electric_resistance = 10
local incremental_electric_resistance = 40
-- Handles cold resistance
local base_cold_resistance = 10
local incremental_cold_resistance = 40

-- Animation Settings

local pollution_absorption_absolute = 50
local spawning_cooldown = { 600, 300 }
local spawning_radius = 10
local max_count_of_owned_units = 8
local max_friends_around_to_spawn = 5
local spawn_table = function(level)
    local res = {}
    --Tire 1
    res[1] = { MOD_NAME .. '--human-miner--' .. level, { { 0.0, 1 }, { 0.2, 0.7 }, { 0.4, 0.5 }, { 0.6, 0.4 }, { 0.8, 0.3 }, { 1.0, 0.1 } } }
    res[2] = { MOD_NAME .. '--human-pistol--' .. level, { { 0.0, 0 }, { 0.2, 0.25 }, { 0.4, 0.35 }, { 0.6, 0.2 }, { 0.8, 0.0 }, { 1.0, 0.0 } } }
    --Tire 2
    res[3] = { MOD_NAME .. '--human-machinegun--' .. level, { { 0.0, 0.0 }, { 0.2, 0.05 }, { 0.4, 0.1 }, { 0.6, 0.3 }, { 0.8, 0.2 }, { 1.0, 0.1 } } }
    res[4] = { MOD_NAME .. '--human-sniper--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.05 }, { 0.6, 0.1 }, { 0.8, 0.1 }, { 1.0, 0.1 } } }
    res[5] = { MOD_NAME .. '--tank-cannon--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.05 }, { 1.0, 0.05 } } }
    res[6] = { MOD_NAME .. '--plane-gunner--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.05 }, { 1.0, 0.2 } } }
    --Tire 3
    res[7] = { MOD_NAME .. '--human-engineer--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.05 }, { 1.0, 0.05 } } }
    res[8] = { MOD_NAME .. '--human-flamethrower--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.1 }, { 1.0, 0.1 } } }
    res[9] = { MOD_NAME .. '--human-shotgun--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.1 }, { 1.0, 0.1 } } }
    res[10] = { MOD_NAME .. '--tank-explosive-cannon--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.0 }, { 1.0, 0.05 } } }
    res[11] = { MOD_NAME .. '--plane-bomber--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.05 }, { 1.0, 0.1 } } }
    res[12] = { MOD_NAME .. '--plane-dropship--' .. level, { { 0.0, 0.0 }, { 0.2, 0.0 }, { 0.4, 0.0 }, { 0.6, 0.0 }, { 0.8, 0.0 }, { 1.0, 0.05 } } }
    return res
end

local collision_box = { { -2.5, -2.5 }, { 2.5, 2.5 } }
local map_generator_bounding_box = { { -4, -4 }, { 4, 4 } }
local selection_box = { { -3, -3 }, { 3, 3 } }

function ErmRedArmy.make_machine(level)
    level = level or 1

    local tint_red = ERM_UnitTint.tint_red_crimson();
    tint_red['a'] = 8

    data:extend({
        {
            type = "unit-spawner",
            name = MOD_NAME .. '--' .. name .. '--' .. level,
            localised_name = { 'entity-name.' .. MOD_NAME .. '--' .. name, GlobalConfig.QUALITY_MAPPING[level] },
            icons = {
                {
                    icon = "__base__/graphics/icons/assembling-machine-1.png",
                    icon_size = 64,
                },
                {
                    icon = "__base__/graphics/icons/signal/signal_red.png",
                    icon_size = 64,
                    scale = 0.2,
                    shift = { -9, -9 }
                },
            },
            flags = { "placeable-player", "placeable-enemy" },
            max_health = ERM_UnitHelper.get_building_health(hitpoint, max_hitpoint_multiplier, level),
            order = MOD_NAME .. '--building--' .. name .. '--' .. level,
            subgroup = "enemies",
            vehicle_impact_sound = ERM_Sound.generic_impact(),
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
            graphics_set = {
                animations = {
                    layers = {
                        {
                            filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1.png",
                            priority = "high",
                            width = 214,
                            height = 226,
                            frame_count = 1,
                            line_length = 8,
                            shift = util.by_pixel(0, 2),
                            scale = 1
                        },
                        {
                            filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1-shadow.png",
                            priority = "high",
                            width = 190,
                            height = 165,
                            frame_count = 1,
                            line_length = 1,
                            repeat_count = 1,
                            draw_as_shadow = true,
                            shift = util.by_pixel(8.5, 5),
                            scale = 1
                        }
                    }
                },                
            },
            map_color = ERM_UnitHelper.format_map_color(settings.startup[FORCE_NAME.."-map-color"].value),
            healing_per_tick = ERM_UnitHelper.get_building_healing(hitpoint, max_hitpoint_multiplier, level),
            collision_box = collision_box,
            map_generator_bounding_box = map_generator_bounding_box,
            selection_box = selection_box,
            absorptions_per_second = { pollution = { absolute = pollution_absorption_absolute, proportional = 0.01 } },
            corpse = "assembling-machine-1-remnants",
            dying_explosion = "assembling-machine-1-explosion",
            max_count_of_owned_units = max_count_of_owned_units,
            max_friends_around_to_spawn = max_friends_around_to_spawn,
            result_units = spawn_table(level),
            -- With zero evolution the spawn rate is 6 seconds, with max evolution it is 2.5 seconds
            spawning_cooldown = spawning_cooldown,
            spawning_radius = spawning_radius,
            spawning_spacing = 3,
            max_spawn_shift = 0,
            max_richness_for_spawn_shift = 100,
            -- distance_factor used to be 1, but Twinsen says:
            -- "The number or spitter spwners should be roughly equal to the number of biter spawners(regardless of difficulty)."
            -- (2018-12-07)
            autoplace =  enemy_autoplace.enemy_spawner_autoplace({
                probability_expression = "erm_redarmy_autoplace_base(0, 5)",
                force = FORCE_NAME,
                control = AUTOCONTROL_NAME
            }),
            call_for_help_radius = 50,
            spawn_decorations_on_expansion = false,
        }
    })
end