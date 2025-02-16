---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/2/2024 7:01 PM
---
---
local simulations = {}

simulations.general = {
    init = [[
require("__core__/lualib/story")
local sim = game.simulation
sim.camera_position = {0, 0}
sim.camera_zoom = 0.85
sim.hide_cursor = true
player = sim.create_test_player{name = "you"}
sim.camera_player = player
game.planets["earth"].create_surface()
local surface = game.surfaces["earth"]
surface.request_to_generate_chunks({0,0}, 2)
surface.force_generate_chunk_requests()


local tank
local story_table =
{
    {
        {
            name = "start",
            init = function()
                local entities = surface.find_entities {{-100, -100}, {100, 100}}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
                player.teleport({-3,10},surface)
                tank = surface.create_entity { name="tank", position={0, 10}, force="player" }
                surface.create_entity { name="enemy_erm_redarmy--human-flamethrower--5", position={8, -2} }
                surface.create_entity { name="enemy_erm_redarmy--tank-explosive-cannon--5", position={8, 2} }
                surface.create_entity { name="enemy_erm_redarmy--plane-gunner--5", position={8, 0} }
                surface.create_entity { name="enemy_erm_redarmy--human-machinegun--5", position={8, 4} }
            end
        },
        {
            condition = story_elapsed_check(3),
            action = function()
                tank.die()
            end
        },
        {
            condition = story_elapsed_check(3),
            action = function()
                story_jump_to(storage.story, "start")
            end
        }
    }
}
tip_story_init(story_table)
    ]],
}



simulations.planet_earth = {
    init = [[
require("__core__/lualib/story")

game.planets["earth"].create_surface()
local earth_surface = game.surfaces["earth"]
earth_surface.request_to_generate_chunks({0,0}, 2)
earth_surface.force_generate_chunk_requests()

local sim = game.simulation
player = sim.create_test_player{name = "you"}
sim.camera_player = player
sim.camera_position = {0, 0}
sim.camera_zoom = 0.5
sim.hide_cursor = true

local story_table =
{
    {
        {
            name = "start",
            init = function()
                local entities = earth_surface.find_entities_filtered {type={"unit","segmented-unit"}}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end

                earth_surface.create_entity { name="cargo-landing-pad", position={-25, -10}, force="player" }
                player.teleport({-22,0}, "earth")
                for _, y in pairs({-5,0,5}) do
                    for _, x in pairs({-20, -17}) do
                        local gun = earth_surface.create_entity { name="gun-turret", position={x, y}, force="player" }
                        local inventory = gun.get_inventory(defines.inventory.turret_ammo)
                        inventory.insert({name = "piercing-rounds-magazine", count = 100})
                    end
                end

                for i = -10, 10, 1 do
                    earth_surface.create_entity { name="stone-wall", position={-15, i}, force="player" }
                end

                earth_surface.create_entity { name="enemy_erm_redarmy--lab--5", position={12, -5} }
                earth_surface.create_entity { name="enemy_erm_redarmy--assemble-machine--5", position={12, 5} }
                earth_surface.create_entity { name="enemy_erm_redarmy--electric-furnace--5", position={16, 0} }
            end,
        },
        {
            condition = story_elapsed_check(2),
            action = function()
                earth_surface.create_entity { name="enemy_erm_redarmy--human-machinegun--5", position={8, 2} }
                earth_surface.create_entity { name="enemy_erm_redarmy--human-sniper--5", position={8, 0} }
                earth_surface.create_entity { name="enemy_erm_redarmy--human-flamethrower--5", position={8, 4} }
            end
        },
        {
            condition = story_elapsed_check(2),
            action = function()
                earth_surface.create_entity { name="enemy_erm_redarmy--tank-cannon--5", position={8, 2} }
                earth_surface.create_entity { name="enemy_erm_redarmy--plane-gunner--5", position={8, 0} }
                earth_surface.create_entity { name="enemy_erm_redarmy--plane-bomber--5", position={8, 4} }
            end
        },
        {
            condition = story_elapsed_check(10),
            action = function()
                story_jump_to(storage.story, "start")
            end
        }
    }
}
tip_story_init(story_table)
]]
}

return simulations