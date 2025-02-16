---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/2/2024 7:01 PM
---

local simulations = require("__erm_redarmy__/prototypes/tips_and_tricks/simulations")

data:extend(
        {
            {
                type = "tips-and-tricks-item-category",
                name = FORCE_NAME,
                order = "n02-["..FORCE_NAME.."]"
            },
            {
                type = "tips-and-tricks-item",
                name = FORCE_NAME.."-general-info",
                tag = "[entity="..FORCE_NAME.."--human-flamethrower--1]",
                category = FORCE_NAME,
                order = "a",
                is_title = true,
                starting_status = "suggested",
                simulation = simulations.general
            },
        }
)

if feature_flags.space_travel then
    data:extend(
            {
                {
                    type = "tips-and-tricks-item",
                    tag = "[planet=earth]",
                    name = FORCE_NAME.."-planet-earth",
                    category = FORCE_NAME,
                    order = "c",
                    indent = 1,
                    starting_status = "suggested",
                    simulation = simulations.planet_earth
                },
            })
end