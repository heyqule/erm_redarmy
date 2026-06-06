require('__erm_redarmy__/global')
local CustomAttacks = require('__erm_redarmy__/scripts/custom_attacks')
local Position = require("__erm_libs__/stdlib/position")
local Bases = require('__erm_redarmy__/bases')

-- Constants
local CHUNK_SIZE = 32

--- Entity that need reformat
local entity_conversions = {
    ['gun-turret'] = true,
    ['laser-turret'] = true,
    ['tesla-turret'] = true,
    ['rocket-turret'] = true,
    ['electric-turret'] = true,
    ['rocket-silo'] = true,
    ['artillery-turret'] = true,
    ['assembling-machine-1'] = 'assemble-machine',
    ['electric-furnace'] = true,
    ['lab'] = true,
}

local can_build_town_surfaces = {
    earth = true
}

local table_deepcopy = util.table.deepcopy
local table_insert = table.insert
local math_random = math.random
local group_tile = "ground_tile"

local convert_name = function(name, quality)
    if entity_conversions[name] then
        if type(entity_conversions[name]) == 'string' then
            return MOD_NAME .. '--' ..  entity_conversions[name] .. '--' .. quality
        else
            return MOD_NAME .. '--' ..  name .. '--' .. quality
        end
    end
    
    return name
end

local removable_type = {
    tree = true,
    ["simple-entity"] = true,
    ["unit"] = true,
    ["unit-spawner"] = true,
    ["turret"] = true
}

local build_entities =  function(event)
    if next(storage.base_area_removal) then
        local idx, base_data = next(storage.base_area_removal)
        local surface = base_data.surface
        local position = base_data.position
        local radius = base_data.radius
        
        local removal_area = {
            {x = position.x - radius, y =  position.y - radius},
            {x = position.x + radius, y =  position.y + radius},
        }
        if surface or surface.valid then
            local entities = surface.find_entities(removal_area)

            for _, entity in pairs(entities) do
                if removable_type[entity.type] then
                    entity.destroy({raise_destroy=true})
                end
            end
        end
        
        storage.base_area_removal[idx] = nil
    end
    
    if next(storage.building_entities) then
        local profile = game.create_profiler()
        
        local i = 0
        local surface
        for idx, entity in pairs(storage.building_entities) do
            if i == 24 then
                break
            end

            if surface == nil then
                surface = game.surfaces[entity.surface]
            end

            if surface and surface.valid then
                local created = surface.create_entity(entity)
                if created then
                    local tile = surface.get_tile(created.position.x, created.position.y)
                    if i % 3 == 0 and tile and tile.collides_with(group_tile) == false then
                        table_insert(storage.landfill_queue, {
                            surface = surface,
                            position = created.position
                        })
                    end
                end
            end

            storage.building_entities[idx] = nil
            i = i + 1
        end
        
        profile.stop()
        log({'','build_entities:',profile})
    end
end

local LANDFILL_RADIUS = 2
local process_landfill_queue = function()
    if not next(storage.landfill_queue) then
        return
    end

    local profile = game.create_profiler()
    
    local tiles = {}
    local surface
    for idx = 1, 16 do
        local entry = storage.landfill_queue[idx]
        if not entry then
            break
        end

        surface = entry.surface
        local pos = entry.position
        for dx = -LANDFILL_RADIUS, LANDFILL_RADIUS do
            for dy = -LANDFILL_RADIUS, LANDFILL_RADIUS do
                local tile = surface.get_tile(pos.x + dx, pos.y + dy)
                if tile and tile.collides_with(group_tile) == false then
                    table_insert(tiles, {name = "landfill", position = {pos.x + dx, pos.y + dy}})
                end
            end
        end

        storage.landfill_queue[idx] = nil
    end

    if surface and next(tiles) then
        surface.set_tiles(tiles, true, false, false, false)
    end

    profile.stop()
    log({'','process_landfill_queue:',profile})
end

local build_blueprint_base = function(data)
    local surface = data.surface
    local blueprint_string = data.blueprint_string
    local town_size = data.town_size
    local position = data.position
    
    local x_offset = position.x or 0
    local y_offset = position.y or 0
    local radius = town_size / 2
    local bp_entity = surface.create_entity { name = "item-on-ground", position = { 999, 999 }, stack = "blueprint" }
    bp_entity.stack.import_stack(blueprint_string)
    local bp_entities = bp_entity.stack.get_blueprint_entities()
    bp_entity.destroy()

    table_insert(storage.base_area_removal, { 
        surface = surface,
        position = position,
        radius = radius
    })

    local quality = remote.call('enemyracemanager', 'roll_quality', FORCE_NAME, surface.name)

    for _, entity in pairs(bp_entities) do
        if entity.name then
            entity.name = convert_name(entity.name, quality)
        end
        entity.position = { entity.position.x + x_offset, entity.position.y + y_offset}
        entity.force = "enemy_erm_redarmy"
        entity.raise_built = true
        entity.surface = surface.index
        table_insert(storage.building_entities, entity)
    end
end

local center_beacon_position = function(area)
    local left_top = table_deepcopy(area.left_top)
    left_top.x = left_top.x + 16
    left_top.y = left_top.y + 16
    return left_top
end


local TOWN_BEACON = 'erm_town_beacon'
local TOWN_BEACON_SEARCH_RANGE = 7 * CHUNK_SIZE
local TOWN_MIN_SPAWN_DISTANCE = 16 * CHUNK_SIZE
local ARTILLERY_TOWN_CHANCE = 25
local ARTILLERY_TOWN_MIN_DISTANCE = 24 * CHUNK_SIZE
local ARTILLERY_MIN_SPAWN_DISTANCE = 48 * CHUNK_SIZE
local CITY_BEACON = 'erm_city_beacon'
local NUCLEAR_CITY_CHANCE = 50
local NUCLEAR_CITY_MIN_DISTANCE= 48 * CHUNK_SIZE
local NUCLEAR_CITY_MIN_SPAWN_DISTANCE = 32 * CHUNK_SIZE

local build_base = function(event, beacon)
    local profile = game.create_profiler()
    local surface = event.surface
    local chunk_center = center_beacon_position(event.area)
    build_blueprint_base({
        surface = surface, 
        blueprint_string = Bases.towns[math_random(1, Bases.towns_size)],
        position = chunk_center, 
        town_size = Bases.towns_length,
    })

    surface.create_entity({
        name = beacon,
        force = FORCE_NAME,
        position = chunk_center
    })
    
    profile.stop()
    log({'','Red Army Build Base:',profile})

    if DEBUG_MODE then
        print('Beacon:'..beacon)
        print('Distance:'..Position.distance({x=0,y=0},chunk_center))
        print('Position:'..chunk_center.x..'/'..chunk_center.y)
    end
end

local can_spawn_town = function(event)
    if not CustomAttacks.can_spawn(5) then
        return false
    end

    local surface = event.surface
    if not can_build_town_surfaces[surface.name] then
        return false
    end

    local left_top = event.area.left_top
    local beacons = surface.find_entities_filtered({
        name = {TOWN_BEACON, CITY_BEACON},
        radius = TOWN_BEACON_SEARCH_RANGE,
        position = left_top,
        limit = 5
    })

    if next(beacons) then
        return false
    end

    local offset = 24
    local positions = {
        {x = left_top.x + offset,y = left_top.y + offset},
        {x = left_top.x - offset,y = left_top.y - offset},
        {x = left_top.x + offset,y = left_top.y - offset},
        {x = left_top.x - offset,y = left_top.y + offset},
    }

    for _, position in pairs(positions) do
        if string.find(remote.call('factorio-world', 'get_world_tile_name',position.x, position.y),'water',nil, true) then
            return false
        end
    end

    return true
end

local can_spawn_city = function(event)
    return remote.call('factorio-world', 'has_town_spawn_point', event.surface, event.area)
end

local on_chunk_generated = function(event)
    local surface = event.surface
    local left_top = center_beacon_position(event.area)
    --- don't let it build towns near spawn locations
    for _, force in pairs(game.forces) do
        local spawn_position = force.get_spawn_position(surface)
        if spawn_position and Position.distance(spawn_position, left_top) < TOWN_MIN_SPAWN_DISTANCE then
            return
        end
    end

    if can_spawn_city(event) then
        local city_circle = rendering.draw_sprite({
            sprite = "entity/"..CITY_BEACON,
            x_scale = 10,
            y_scale = 10,
            target = left_top,
            surface = surface,
            render_mode="chart",
        })
        build_base(event, CITY_BEACON)
    elseif can_spawn_town(event) then
        local town_circle = rendering.draw_sprite({
            sprite = "entity/"..TOWN_BEACON,
            x_scale = 10,
            y_scale = 10,
            target = left_top,
            surface = surface,
            render_mode="chart",
        })
        build_base(event, TOWN_BEACON)
    end
end

local BaseBuilding = {}

BaseBuilding.events = {
    [defines.events.on_chunk_generated] = on_chunk_generated
}

BaseBuilding.on_nth_tick = {
    [29] = build_entities,
    [61] = process_landfill_queue
}

return BaseBuilding