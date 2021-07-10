---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/3/2021 7:29 PM
---
require('__stdlib__/stdlib/utils/defines/time')
require('util')

local Table = require('__stdlib__/stdlib/utils/table')
local ERM_UnitTint = require('__enemyracemanager__/lib/unit_tint')
local ERM_AnimationRig = require('__enemyracemanager__/lib/rig/animation')

require('__base__/prototypes/entity/character-animations')

function process_level1()
    local layers = {
        character_animations.level1.dead,
        character_animations.level1.dead_mask,
        character_animations.level1.dead_shadow
    }
    ERM_AnimationRig.adjust_direction_count_all(layers, 1)
    ERM_UnitTint.mask_tint(layers[2], ERM_UnitTint.tint_red_madder())
    return layers
end

function process_level2()
    local layers = {
        character_animations.level1.dead,
        character_animations.level1.dead_mask,
        character_animations.level2addon.dead,
        character_animations.level2addon.dead_mask,
        character_animations.level1.dead_shadow
    }
    ERM_AnimationRig.adjust_direction_count_all(layers, 1)
    ERM_UnitTint.mask_tint(layers[2], ERM_UnitTint.tint_red_crimson())
    ERM_UnitTint.mask_tint(layers[4], ERM_UnitTint.tint_red_crimson())
    return layers
end

function process_level3()
    local layers = {
        character_animations.level1.dead,
        character_animations.level1.dead_mask,
        character_animations.level3addon.dead,
        character_animations.level3addon.dead_mask,
        character_animations.level1.dead_shadow
    }
    ERM_AnimationRig.adjust_direction_count_all(layers, 1)
    ERM_UnitTint.mask_tint(layers[2], ERM_UnitTint.tint_red())
    ERM_UnitTint.mask_tint(layers[4], ERM_UnitTint.tint_red())
    return layers
end

if data.raw['corpse']['common-army-corpse'] == nil then
    data:extend({
        {
            type = "corpse",
            name = 'common-red-army-corpse',
            icon = "__core__/graphics/icons/entity/character.png",
            icon_size = 64,
            flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map"},
            selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
            selectable_in_game = false,
            time_before_removed = defines.time.minute * settings.startup["enemyracemanager-enemy-corpse-time"].value / 20,
            final_render_layer = "lower-object-above-shadow",
            subgroup = "corpses",
            order = "x-common-red-army-corpse",
            animation = {
                {
                    layers = process_level1()
                }
            }
        },
        {
            type = "corpse",
            name = 'common-red-army-corpse-2',
            icon = "__core__/graphics/icons/entity/character.png",
            icon_size = 64,
            flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map"},
            selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
            selectable_in_game = false,
            time_before_removed = defines.time.minute * settings.startup["enemyracemanager-enemy-corpse-time"].value / 20,
            final_render_layer = "lower-object-above-shadow",
            subgroup = "corpses",
            order = "x-common-red-army-corpse-2",
            animation = {
                {
                    layers = process_level2()
                }
            }
        },
        {
            type = "corpse",
            name = 'common-red-army-corpse-3',
            icon = "__core__/graphics/icons/entity/character.png",
            icon_size = 64,
            flags = { "placeable-off-grid", "building-direction-8-way", "not-on-map" },
            selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
            selectable_in_game = false,
            time_before_removed = defines.time.minute * settings.startup["enemyracemanager-enemy-corpse-time"].value / 20,
            final_render_layer = "lower-object-above-shadow",
            subgroup = "corpses",
            order = "x-common-red-army-corpse-3",
            animation = {
                {
                    layers = process_level3()
                }
            }
        },
    })
end

if data.raw['corpse']['erm-tank-remnants'] == nil then
    local tank_corpse = util.table.deepcopy(data.raw['corpse']['tank-remnants'])
    tank_corpse['name'] = 'erm-tank-remnants'
    tank_corpse['time_before_removed'] = defines.time.minute * settings.startup["enemyracemanager-enemy-corpse-time"].value
    data:extend({
        tank_corpse
    })
end

if data.raw['corpse']['erm-medium-remnants'] == nil then
    local medium_corpse = util.table.deepcopy(data.raw['corpse']['medium-remnants'])
    medium_corpse['name'] = 'erm-medium-remnants'
    medium_corpse['time_before_removed'] = defines.time.minute * settings.startup["enemyracemanager-enemy-corpse-time"].value
    data:extend({
        medium_corpse
    })
end
