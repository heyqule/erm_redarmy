---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/28/2021 9:38 PM
---

ErmRedArmy = {}
require('util')
require('__erm_redarmy__/global')
require "prototypes.noise-functions"


local DataHelper = require('__enemyracemanager__/lib/rig/data_helper')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')

local WeaponRig = require('__enemyracemanager__/lib/rig/weapon')

-- This set of data is used for set up default autoplace calculation.
data.erm_registered_race = data.erm_registered_race or {}
data.erm_registered_race[MOD_NAME] = true
data.erm_spawn_specs = data.erm_spawn_specs or {}
table.insert(data.erm_spawn_specs, {
    mod_name = MOD_NAME,
    force_name = FORCE_NAME,
    moisture = 2, -- 1 = Dry and 2 = Wet
    aux = 2, -- -- 1 = red desert, 2 = sand
    elevation = 1, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
    temperature = 2, --1,2,3 (1 cold, 2. normal, 3 hot)
})

data:extend(
        {
            {
                type = "ammo-category",
                name = "redarmy-damage"
            },
        })

local cannon_projectile = WeaponRig.standardize_cannon_projectile(
        util.table.deepcopy(data.raw['projectile']['cannon-projectile']),
        MOD_NAME..'--cannon-projectile'
)
cannon_projectile['force_condition'] = "not-same"
cannon_projectile['hit_collision_mask'] = { layers = {player = true, train = true,   [DataHelper.getFlyingLayerName()] = true}}

local cannon_explosive_projectile = WeaponRig.standardize_explosive_cannon_projectile(
        util.table.deepcopy(data.raw['projectile']['explosive-cannon-projectile']),
        MOD_NAME..'--explosive-cannon-projectile'
)
cannon_explosive_projectile['force_condition'] = "not-same"
cannon_explosive_projectile['hit_collision_mask'] = { layers = {player = true, train = true,   [DataHelper.getFlyingLayerName()] = true}}

local rocket = WeaponRig.standardize_explosive_rocket_damage(
        util.table.deepcopy(data.raw['projectile']['explosive-rocket']),
        MOD_NAME..'--explosive-rocket',
        3
)
rocket['turn_speed'] = nil
rocket['turning_speed_increases_exponentially_with_projectile_speed'] = false
rocket['smoke'][1]['frequency'] = 1 / 5

rocket['action']['action_delivery']['target_effects'][2] = {
    type = "damage",
    damage = { amount = 3.5, type = "explosion" },
}

data:extend({ cannon_projectile, cannon_explosive_projectile, rocket })

local fire_stream = util.table.deepcopy(data.raw['stream']['flamethrower-fire-stream'])
fire_stream['name'] = MOD_NAME..'--flamethrower-fire-stream'
fire_stream['action'][1]['action_delivery']['target_effects'][1]['sticker'] = MOD_NAME..'--fire-stickerer'

local fire_sticker = util.table.deepcopy(data.raw['sticker']['fire-sticker'])
fire_sticker['name'] = MOD_NAME..'--fire-stickerer'

data.extend({
    fire_sticker,
    fire_stream,
})

require "prototypes.building.gun-turret"
require "prototypes.building.laser-turret"
require "prototypes.building.rocket-turret"
require "prototypes.building.lab"
require "prototypes.building.electric-furnace"
require "prototypes.building.assemble-machine"

require "prototypes.enemy.corpse"
require "prototypes.enemy.human-miner"
require "prototypes.enemy.human-pistol"
require "prototypes.enemy.human-machinegun"
require "prototypes.enemy.human-engineer"
require "prototypes.enemy.human-sniper"
require "prototypes.enemy.human-shotgun"
require "prototypes.enemy.human-flamethrower"
require "prototypes.enemy.tank-cannon"
require "prototypes.enemy.tank-explosive-cannon"
require "prototypes.enemy.plane-gunner"
require "prototypes.enemy.plane-bomber"
require "prototypes.enemy.plane-dropship"

local max_level = GlobalConfig.MAX_LEVELS

for i = 1, max_level do
    ErmRedArmy.make_human_miner(i)
    ErmRedArmy.make_human_pistol(i)
    ErmRedArmy.make_human_machinegun(i)
    ErmRedArmy.make_human_sniper(i)
    ErmRedArmy.make_human_engineer(i)
    ErmRedArmy.make_human_shotgun(i)
    ErmRedArmy.make_human_heavy_machinegun(i)
    ErmRedArmy.make_tank(i)
    ErmRedArmy.make_explosive_tank(i)
    ErmRedArmy.make_gunner_plane(i)
    ErmRedArmy.make_bomber_plane(i)
    ErmRedArmy.make_dropship_plane(i)
end

for i = 1, max_level do
    ErmRedArmy.make_gun_turret(i)
    ErmRedArmy.make_laser_turret(i)
    ErmRedArmy.make_lab(i)
    ErmRedArmy.make_furnace(i)
    ErmRedArmy.make_machine(i)
end


data.erm_land_scout = data.erm_land_scout or {}
data.erm_land_scout[MOD_NAME] = 'human-miner'

data.erm_aerial_scout = data.erm_aerial_scout or {}
data.erm_aerial_scout[MOD_NAME] = 'plane-gunner'


require "prototypes.planets"