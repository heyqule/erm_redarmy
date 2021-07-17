---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/28/2021 9:38 PM
---

ErmRedArmy = {}

require('__erm_redarmy__/global')
require('util')

local ErmConfig = require('__enemyracemanager__/lib/global_config')

local ERM_WeaponRig = require('__enemyracemanager__/lib/rig/weapon')

data:extend(
        {
            {
                type = "ammo-category",
                name = "redarmy-damage"
            },
        })


data:extend({
    ERM_WeaponRig.remove_damage_from_cannon_projectile(
        util.table.deepcopy(data.raw['projectile']['cannon-projectile']),
        'cannon-projectile-no-damage'
    )
})

data:extend({
    ERM_WeaponRig.remove_damage_from_explosive_cannon_projectile(
        util.table.deepcopy(data.raw['projectile']['explosive-cannon-projectile']),
        'explosive-cannon-projectile-no-damage'
    )
})

data:extend({
    ERM_WeaponRig.remove_damage_from_rocket(
        util.table.deepcopy(data.raw['projectile']['rocket']),
            'rocket-no-damage'
    )
})

require "prototypes.building.gun-turret"
require "prototypes.building.laser-turret"
require "prototypes.building.lab"
require "prototypes.building.electric-furnace"
require "prototypes.building.assemble-machine"

require "prototypes.enemy.corpse"
require "prototypes.enemy.human-miner"
require "prototypes.enemy.human-pistol"
require "prototypes.enemy.human-machinegun"
require "prototypes.enemy.human-sniper"
require "prototypes.enemy.human-shotgun"
require "prototypes.enemy.human-heavy-machinegun"
require "prototypes.enemy.tank-cannon"
require "prototypes.enemy.tank-explosive-cannon"
require "prototypes.enemy.plane-gunner"
require "prototypes.enemy.plane-bomber"

local level = ErmConfig.MAX_LEVELS

for i = 1, level do
    ErmRedArmy.make_gun_turret(i)
    ErmRedArmy.make_laser_turret(i)
    ErmRedArmy.make_lab(i)
    ErmRedArmy.make_furnace(i)
    ErmRedArmy.make_machine(i)

    ErmRedArmy.make_human_miner(i)
    ErmRedArmy.make_human_pistol(i)
    ErmRedArmy.make_human_machinegun(i)
    ErmRedArmy.make_human_sniper(i)
    ErmRedArmy.make_human_shotgun(i)
    ErmRedArmy.make_human_heavy_machinegun(i)
    ErmRedArmy.make_tank(i)
    ErmRedArmy.make_explosive_tank(i)
    ErmRedArmy.make_gunner_plane(i)
    ErmRedArmy.make_bomber_plane(i)
end

