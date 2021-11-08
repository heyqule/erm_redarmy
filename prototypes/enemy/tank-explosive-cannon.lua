---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/3/2021 11:54 PM
---

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/3/2021 11:54 PM
---

require('__stdlib__/stdlib/utils/defines/time')
require ("util")
local Sprites = require('__stdlib__/stdlib/data/modules/sprites')
local Table = require('__stdlib__/stdlib/utils/table')

local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
local ERM_UnitTint = require('__enemyracemanager__/lib/rig/unit_tint')
local ERM_AnimationRig = require('__enemyracemanager__/lib/rig/animation')
local ERM_WeaponRig = require('__enemyracemanager__/lib/rig/weapon')
local ERM_Config = require('__enemyracemanager__/lib/global_config')

local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')

local ERM_Sound = require('prototypes.sound')

local name = 'tank-explosive-cannon'

local health_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local hitpoint = 600
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
local base_explosive_damage = 50
local incremental_explosive_damage = 200

-- Handles Attack Speed
local attack_speed_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local base_attack_speed = 300
local incremental_attack_speed = 180

local attack_range = 12

local movement_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local base_movement_speed = 0.1
local incremental_movement_speed = 0.125

-- Misc settings
local vision_distance = 30

local pollution_to_join_attack = 400
local distraction_cooldown = 20

-- Animation Settings
local unit_scale = 1

local collision_box = {{-0.5, -0.66}, {0.5, 0.66}}
local selection_box = {{-0.9, -1.3}, {0.9, 1.3}}

function ErmRedArmy.make_explosive_tank(level)
    level = level or 1

    local tank = util.table.deepcopy(data.raw['car']['tank'])
    --Level 1 animation, level 2 and 3 are armored animations
    -- types: running, running_with_gun, mining_with_tool
    local tank_animation = tank['animation']
    ERM_UnitTint.mask_tint(tank_animation['layers'][2], ERM_UnitTint.tint_red_crimson())

    local gun_animation = tank['turret_animation']
    ERM_UnitTint.mask_tint(gun_animation['layers'][2], ERM_UnitTint.tint_red_crimson())
    ERM_AnimationRig.adjust_repeat_count_all(gun_animation['layers'], 2)
    ERM_AnimationRig.adjust_max_advance_all(gun_animation['layers'], 1)

    local new_animation = {
        layers = {
            tank_animation['layers'][1],
            gun_animation['layers'][1],
            tank_animation['layers'][2],
            gun_animation['layers'][2],
            tank_animation['layers'][3],
            gun_animation['layers'][3],
        }
    }

    data:extend({
        {
            type = "unit",
            name = MOD_NAME .. '/' .. name .. '/' .. level,
            localised_name = { 'entity-name.' .. MOD_NAME .. '/' .. name, level },
            icons = {
                {
                    icon = "__base__/graphics/icons/tank.png",
                    icon_size = 64,
                },
                {
                    icon = "__base__/graphics/icons/signal/signal_red.png",
                    icon_size = 64,
                    scale = 0.2,
                    shift = {-9,-9}
                },
            },
            flags = {"placeable-enemy", "placeable-player", "placeable-off-grid"},
            has_belt_immunity = true,
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
            healing_per_tick = ERM_UnitHelper.get_healing(hitpoint, max_hitpoint_multiplier, health_multiplier, level),
            collision_box = collision_box,
            selection_box = selection_box,
            vision_distance = vision_distance,
            movement_speed = ERM_UnitHelper.get_movement_speed(base_movement_speed, incremental_movement_speed, movement_multiplier, level),
            pollution_to_join_attack = pollution_to_join_attack,
            distraction_cooldown = distraction_cooldown,
            ai_settings = biter_ai_settings,
            attack_parameters =
            {
                type = "projectile",
                ammo_category = "redarmy-damage",
                range = attack_range,
                min_attack_distance = attack_range - 4,
                cooldown = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed, attack_speed_multiplier, level),
                projectile_creation_distance = 1.6,
                projectile_center = {-0.15625, -0.07812},
                sound = ERM_Sound.tank_gunshot(),
                ammo_type = {
                    category = "redarmy-damage",
                    target_type = "direction",
                    action = {
                        type = "direct",
                        action_delivery = {
                            type = "projectile",
                            projectile = "explosive-cannon-projectile-no-damage",
                            starting_speed = 1,
                            target_effects = {
                                {
                                    type = "damage",
                                    damage = { amount = ERM_UnitHelper.get_damage(base_explosive_damage, incremental_explosive_damage, damage_multiplier, level) * 0.65, type = "explosion" },
                                },
                                {
                                    type = "nested-result",
                                    action =
                                    {
                                        type = "area",
                                        force = "not-same",
                                        radius = 3,
                                        action_delivery =
                                        {
                                            type = "instant",
                                            target_effects =
                                            {
                                                {
                                                    type = "damage",
                                                    damage = {amount = ERM_UnitHelper.get_damage(base_explosive_damage, incremental_explosive_damage, damage_multiplier, level) * 0.35, type = "explosion"}
                                                },
                                                {
                                                    type = "create-entity",
                                                    entity_name = "explosion"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                animation = new_animation
            },
            distance_per_frame = 1,
            run_animation = new_animation,
            corpse = "erm-tank-remnants",
            dying_explosion = "tank-explosion"
        }
    })
end
