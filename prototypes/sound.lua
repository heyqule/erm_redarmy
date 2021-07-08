---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/3/2021 10:29 PM
---

local RedArmySound = {}

local base_sound = require('__base__/prototypes/entity/sounds')

function RedArmySound.pistol()
    return  base_sound.light_gunshot
end

function RedArmySound.tank_gunshot()
    return  base_sound.tank_gunshot
end

function RedArmySound.machine_gun()
    return  base_sound.submachine_gunshot
end

function RedArmySound.heavy_machine_gun()
    return  base_sound.gun_turret_gunshot
end

function RedArmySound.sniper()
    return  base_sound.heavy_gunshot
end

function RedArmySound.generic_impact()
    return base_sound.generic_impact
end

function RedArmySound.shotgun()
    return  base_sound.shotgun
end

function RedArmySound.pistol()
    return  base_sound.light_gunshot
end

function RedArmySound.death(volume)
    return  {
        variations = {
            {
                filename = "__erm_redarmy__/sounds/die1.ogg",
                volume = volume
            },
            {
                filename = "__erm_redarmy__/sounds/die2.ogg",
                volume = volume
            },
            {
                filename = "__erm_redarmy__/sounds/die3.ogg",
                volume = volume
            },
        }
    }
end

function RedArmySound.mining(volume)
    return {
        variations = {
            {
                filename = "__core__/sound/axe-mining-stone-1.ogg",
                volume = volume
            },
            {
                filename = "__core__/sound/axe-mining-stone-2.ogg",
                volume = volume
            },
            {
                filename = "__core__/sound/axe-mining-stone-3.ogg",
                volume = volume
            },
            {
                filename = "__core__/sound/axe-mining-stone-4.ogg",
                volume = volume
            },
            {
                filename = "__core__/sound/axe-mining-stone-5.ogg",
                volume = volume
            },
            {
                filename = "__core__/sound/axe-mining-stone-6.ogg",
                volume = volume
            },
            {
                filename = "__core__/sound/axe-mining-stone-7.ogg",
                volume = volume
            },
        }
    }
end

return RedArmySound;