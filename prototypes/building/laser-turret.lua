---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/28/2021 9:38 PM
---
require('__stdlib__/stdlib/utils/defines/time')
require('util')

local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
local ERM_UnitTint = require('__enemyracemanager__/lib/rig/unit_tint')
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')
local ERM_Config = require('__enemyracemanager__/lib/global_config')

local enemy_autoplace = require("__enemyracemanager__/lib/enemy-autoplace-utils")

local name = 'laser-turret'

-- Hitpoints

local hitpoint = 400
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value * 2


-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 75
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 85
-- Handles fire and explosive resistance
local base_fire_resistance = 5
local incremental_fire_resistance = 75
-- Handles laser and electric resistance
local base_electric_resistance = 25
local incremental_electric_resistance = 55
-- Handles cold resistance
local base_cold_resistance = 15
local incremental_cold_resistance = 65

-- Handles laser damage multipliers

local base_laser_damage = 2
local incremental_laser_damage = 18

-- Handles Attack Speed

local base_attack_speed = 120
local incremental_attack_speed = 60

local collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } }
local map_generator_bounding_box = { { -2.5, -2.5 }, { 2.5, 2.5 } }
local selection_box = { { -1, -1 }, { 1, 1 } }

function ErmRedArmy.make_laser_turret(level)
    level = level or 1

    local attack_range = ERM_UnitHelper.get_attack_range(level) + 16

    local redarmy_laser_turret = util.table.deepcopy(data.raw['electric-turret']['laser-turret'])

    -- Base changes
    redarmy_laser_turret['type'] = 'turret'
    redarmy_laser_turret['subgroup'] = 'enemies'
    redarmy_laser_turret['name'] = MOD_NAME .. '/' .. name .. '/' .. level
    redarmy_laser_turret['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. name, level }
    redarmy_laser_turret['flags'] = { "placeable-player", "placeable-enemy" }
    redarmy_laser_turret['max_health'] = ERM_UnitHelper.get_building_health(hitpoint, hitpoint * max_hitpoint_multiplier, level)
    redarmy_laser_turret['healing_per_tick'] = ERM_UnitHelper.get_building_healing(hitpoint, max_hitpoint_multiplier, level)
    redarmy_laser_turret['order'] = MOD_NAME .. '/' .. name .. '/'.. level
    redarmy_laser_turret['minable'] = nil
    redarmy_laser_turret['next_upgrade'] = nil
    redarmy_laser_turret['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, level) }
    }
    redarmy_laser_turret['map_color'] = ERM_UnitHelper.format_map_color(settings.startup['erm_redarmy-map-color'].value)
    redarmy_laser_turret['collision_box'] = collision_box
    redarmy_laser_turret['selection_box'] = selection_box
    redarmy_laser_turret['map_generator_bounding_box'] = map_generator_bounding_box
    redarmy_laser_turret['autoplace'] = enemy_autoplace.enemy_worm_autoplace(0, FORCE_NAME)
    redarmy_laser_turret['call_for_help_radius'] = 50
    redarmy_laser_turret['spawn_decorations_on_expansion'] = false
    redarmy_laser_turret['energy_source'] = nil

    -- Attack Changes
    redarmy_laser_turret['attack_parameters']['ammo_category'] = "redarmy-damage"
    redarmy_laser_turret['attack_parameters']['cooldown'] = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed, level)
    redarmy_laser_turret['attack_parameters']['cooldown_deviation'] = 0.1
    redarmy_laser_turret['attack_parameters']['range'] = attack_range
    redarmy_laser_turret['attack_parameters']['damage_modifier'] = ERM_UnitHelper.get_damage(base_laser_damage, incremental_laser_damage, level)

    redarmy_laser_turret['attack_parameters']['ammo_type'] = {
        category = "redarmy-damage",
        action = {
            type = "direct",
            action_delivery = {
                type = "beam",
                beam = "laser-beam",
                max_length = 30,
                duration = 60,
                source_offset = { 0, -1.31439 },
            }
        }
    }

    -- Animation Changes
    ERM_UnitTint.mask_tint(redarmy_laser_turret['folded_animation']['layers'][3], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(redarmy_laser_turret['preparing_animation']['layers'][3], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(redarmy_laser_turret['prepared_animation']['layers'][3], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(redarmy_laser_turret['folding_animation']['layers'][2], ERM_UnitTint.tint_red())

    data:extend({
        redarmy_laser_turret
    })
end
