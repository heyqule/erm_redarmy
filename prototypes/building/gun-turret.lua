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

local name = 'gun-turret'
local short_range_name = 'gun-turret-short'

-- Hitpoints

local hitpoint = 350
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

-- Handles damages

local base_physical_damage = 5
local incremental_physical_damage = 55

-- Handles Attack Speed

local base_attack_speed = 60
local incremental_attack_speed = 45

local collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } }
local map_generator_bounding_box = { { -2.5, -2.5 }, { 2.5, 2.5 } }
local selection_box = { { -1, -1 }, { 1, 1 } }

function ErmRedArmy.make_gun_turret(level)
    level = level or 1

    local attack_range = ERM_UnitHelper.get_attack_range(level) + 16

    local redarmy_gun_turret = util.table.deepcopy(data.raw['ammo-turret']['gun-turret'])

    -- Base changes
    redarmy_gun_turret['type'] = 'turret'
    redarmy_gun_turret['subgroup'] = 'enemies'
    redarmy_gun_turret['name'] = MOD_NAME .. '/' .. name .. '/' .. level
    redarmy_gun_turret['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. name, level }
    redarmy_gun_turret['flags'] = { "placeable-player", "placeable-enemy" }
    redarmy_gun_turret['max_health'] = ERM_UnitHelper.get_building_health(hitpoint, hitpoint * max_hitpoint_multiplier, level)
    redarmy_gun_turret['healing_per_tick'] = ERM_UnitHelper.get_building_healing(hitpoint, max_hitpoint_multiplier, level)
    redarmy_gun_turret['order'] = MOD_NAME .. "-" .. name
    redarmy_gun_turret['minable'] = nil
    redarmy_gun_turret['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, level) }
    }
    redarmy_gun_turret['map_color'] = ERM_UnitHelper.format_map_color(settings.startup['erm_redarmy-map-color'].value)
    redarmy_gun_turret['collision_box'] = collision_box
    redarmy_gun_turret['selection_box'] = selection_box
    redarmy_gun_turret['map_generator_bounding_box'] = map_generator_bounding_box
    redarmy_gun_turret['autoplace'] = enemy_autoplace.enemy_worm_autoplace(0, FORCE_NAME)
    redarmy_gun_turret['call_for_help_radius'] = 50
    redarmy_gun_turret['spawn_decorations_on_expansion'] = false

    -- Attack Changes
    redarmy_gun_turret['attack_parameters']['ammo_category'] = "redarmy-damage"
    redarmy_gun_turret['attack_parameters']['cooldown'] = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed, level)
    redarmy_gun_turret['attack_parameters']['cooldown_deviation'] = 0.1
    redarmy_gun_turret['attack_parameters']['range'] = attack_range
    redarmy_gun_turret['attack_parameters']['ammo_type'] = {
        category = "redarmy-damage",
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                source_effects = {
                    type = "create-explosion",
                    entity_name = "explosion-gunshot-small"
                },
                target_effects = {
                    {
                        type = "create-entity",
                        entity_name = "explosion-hit"
                    },
                    {
                        type = "damage",
                        damage = { amount = ERM_UnitHelper.get_damage(base_physical_damage, incremental_physical_damage, level), type = "physical" }
                    }
                }
            }
        }
    }

    -- Animation Changes
    ERM_UnitTint.mask_tint(redarmy_gun_turret['base_picture']['layers'][2], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(redarmy_gun_turret['folded_animation']['layers'][2], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(redarmy_gun_turret['preparing_animation']['layers'][2], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(redarmy_gun_turret['prepared_animation']['layers'][2], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(redarmy_gun_turret['folding_animation']['layers'][2], ERM_UnitTint.tint_red())

    data:extend({
        redarmy_gun_turret
    })

    local short_redarmy_gun_turret = util.table.deepcopy(redarmy_gun_turret)

    short_redarmy_gun_turret['name'] = MOD_NAME .. '/' .. short_range_name .. '/' .. level
    short_redarmy_gun_turret['attack_parameters']['range'] = ERM_Config.get_max_attack_range()
    short_redarmy_gun_turret['autoplace'] = nil

    data:extend({
        short_redarmy_gun_turret
    })
end
