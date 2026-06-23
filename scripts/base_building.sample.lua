-----
--- Different between this and base_build.lua is that this one doesn't depends on factorio-world remote calls
--- It serve as sample implementation for other races.  It also has additional documentations.
--- Not tested, used at your own risk.
require('__erm_redarmy__/global')
local CustomAttacks = require('__erm_redarmy__/scripts/custom_attacks')
local Position = require("__erm_libs__/stdlib/position")
local Bases = require('__erm_redarmy__/bases')

-- Constants
local CHUNK_SIZE = 32

--- This allow placement of one of assembling-machine, lab or electric-furnace
local random_bit_spawner = 1
local random_bit_turret = 2
--- Entities that need conversion
--- The size of both entities should be the same or similar.  Otherwise, they may collide.
--- You have to test conversion to see whether the city look fine.
local entity_conversions = {
    ['gun-turret'] = true,
    ['laser-turret'] = true,
    ['tesla-turret'] = true,
    ['rocket-turret'] = true,
    ['electric-turret'] = true,
    ['rocket-silo'] = true,
    --- same name use true, e.g. gun-turret >> "enemy_erm_redarmy--gun-turret--1"
    ['artillery-turret'] = true,
    --- different name use string map, e.g. "assembling-machine-1" >> "enemy_erm_redarmy--assemble-machine--1"
    ['assembling-machine-1'] = 'assemble-machine',
    ['electric-furnace'] = true,
    ['lab'] = true,
    --- beacon handle random spawner placement.  
    ['beacon'] = random_bit_spawner
    
    --- You can do random_bit for random turret as well, it'll need a new random_bit number and minor change to convert_name function.
    --- ['something_else'] = random_bit_turret
}
--- spawner list for random pick
local spawners = {'assemble-machine', 'lab', 'electric-furnace'}
local spawners_count = #spawners

--- turret list for beacon's random pick
---local turrets = {'gun-turret', 'laser-turret'}
---local turrets_count = #turrets

--- set which surface can build town
local can_build_town_surfaces = {
    earth = true
}

local table_deepcopy = util.table.deepcopy
local table_insert = table.insert
local math_random = math.random
local group_tile = "ground_tile"

local convert_name = function(name, quality)
    if entity_conversions[name] then
        if entity_conversions[name] == true then
            return MOD_NAME .. '--' ..  name .. '--' .. quality
        elseif entity_conversions[name] == random_bit_spawner then
            return MOD_NAME .. '--' ..  spawners[math_random(1, spawners_count)] .. '--' .. quality
        --- elseif entity_conversions[name] == random_bit_turret then
        ---     return MOD_NAME .. '--' ..  turrets[math_random(1, turrets_count)] .. '--' .. quality            
        else
            return MOD_NAME .. '--' ..  entity_conversions[name] .. '--' .. quality
        end
    end
    
    return name
end

local is_invalid_surface = function(surface)
    return not surface or not surface.valid or not can_build_town_surfaces[surface.name]
end

--- All matching entity should be wipe before the base being build.
local removable_type = {
    tree = true,
    ["simple-entity"] = true,
    ["unit"] = true,
    ["unit-spawner"] = true,
    ["turret"] = true,
    ["wall"] = true
}

local build_base = function(queue_data)
    local surface = queue_data.surface
    if surface and surface.valid then
        queue_data.type = nil
        local created = surface.create_entity(queue_data)
        if created then
            local tile = surface.get_tile(created.position.x, created.position.y)
            if tile and tile.collides_with(group_tile) == false then
                table_insert(storage.landfill_queue, {
                    surface = surface,
                    position = created.position
                })
            end
        end
    end
end

local remove_entity = function(queue_data)
    local surface = queue_data.surface
    if surface or surface.valid then
        local position = queue_data.position
        local radius = queue_data.radius
        local removal_area = {
            {x = position.x - radius, y =  position.y - radius},
            {x = position.x + radius, y =  position.y + radius},
        }

        local entities = surface.find_entities(removal_area)

        for _, entity in pairs(entities) do
            if removable_type[entity.type] then
                entity.destroy({raise_destroy=true})
            end
        end
    end
end

local QUEUE_TYPE_REMOVE_ENTITY = 1
local QUEUE_TYPE_BUILD_BASE = 2
local build_functions = {
    remove_entity, build_base
}

local build_entities =  function(event)
    local i = 0
    for idx, queue_data in pairs(storage.build_queue) do
        if i == 12 then
            break
        end
        build_functions[queue_data.type](queue_data)
        storage.build_queue[idx] = nil
    end
end

local LANDFILL_RADIUS = 2
local LANDFILL_NAME = 'landfill'
local remove_lanfill_queue_at = function(key)
    if key then
        storage.landfill_queue[key] = nil
    end
end
local process_landfill_queue = function()
    if not next(storage.landfill_queue) then
        return
    end
    
    local tiles = {}
    local surface
    for idx = 1, 12 do
        local key, entry = next(storage.landfill_queue)
        if not entry or not entry.surface.valid then
            remove_lanfill_queue_at(key)
            break
        end

        surface = entry.surface
        local pos = entry.position
        for dx = -LANDFILL_RADIUS, LANDFILL_RADIUS do
            for dy = -LANDFILL_RADIUS, LANDFILL_RADIUS do
                local tile = surface.get_tile(pos.x + dx, pos.y + dy)
                if tile and tile.collides_with(group_tile) == false then
                    table_insert(tiles, {name = LANDFILL_NAME, position = {pos.x + dx, pos.y + dy}})
                end
            end
        end

        remove_lanfill_queue_at(key)
    end

    if surface and next(tiles) then
        surface.set_tiles(tiles, true, false, false, false)
    end
end

local build_blueprint_base = function(data)
    local surface = data.surface
    local blueprint_string = data.blueprint_string
    local town_size = data.town_size
    local position = data.position
    
    local x_offset = position.x or 0
    local y_offset = position.y or 0
    local radius = town_size / 2 + 4
    local bp_entity = surface.create_entity { name = "item-on-ground", position = { 999, 999 }, stack = "blueprint" }
    bp_entity.stack.import_stack(blueprint_string)
    local bp_entities = bp_entity.stack.get_blueprint_entities()
    bp_entity.destroy()

    table_insert(storage.build_queue, { 
        surface = surface,
        position = position,
        radius = radius,
        type = QUEUE_TYPE_REMOVE_ENTITY,
    })

    local quality = remote.call('enemyracemanager', 'roll_quality', FORCE_NAME, surface.name)

    for _, entity in pairs(bp_entities) do
        if entity.name then
            entity.name = convert_name(entity.name, quality)
        end
        entity.position = { entity.position.x + x_offset, entity.position.y + y_offset}
        entity.force = FORCE_NAME
        entity.raise_built = true
        entity.surface = surface
        entity.type = QUEUE_TYPE_BUILD_BASE,
        table_insert(storage.build_queue, entity)
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
--- Minimal distance to build town from spawn point, 512 tile
local TOWN_MIN_SPAWN_DISTANCE = 16 * CHUNK_SIZE

--- Minimal distance to build large town from spawn point, ~1000 tile
local LARGE_TOWN_MIN_SPAWN_DISTANCE = 32 * CHUNK_SIZE
local LARGE_TOWN_CHANCE = settings.startup[FORCE_NAME.."-large-town-spawn-chance"].value
local ARTILLERY_TOWN_CHANCE = settings.startup[FORCE_NAME.."-artillery-town-spawn-chance"].value
--- Minimal gap between each artillery town
local ARTILLERY_TOWN_GAP_DISTANCE = 16 * CHUNK_SIZE
--- Minimal distance to build large town from spawn point, ~1500 tile
local ARTILLERY_TOWN_MIN_SPAWN_DISTANCE = 48 * CHUNK_SIZE


local CITY_BEACON = 'erm_city_beacon'
local CITY_BEACON_SEARCH_RANGE = 16 * CHUNK_SIZE
--- Normal city - under 32 chunks
local ARTILLERY_CITY_CHANCE = settings.startup[FORCE_NAME.."-artillery-city-spawn-chance"].value
local ARTILLERY_CITY_MIN_SPAWN_DISTANCE = 32 * CHUNK_SIZE

local NUCLEAR_CITY_CHANCE = settings.startup[FORCE_NAME.."-atomic-city-spawn-chance"].value
local NUCLEAR_CITY_MIN_SPAWN_DISTANCE = 64 * CHUNK_SIZE

local get_town_type = function(surface, town_position, spawn_location)
    local distance = Position.distance(town_position, spawn_location)
    if CustomAttacks.can_spawn(ARTILLERY_TOWN_CHANCE) and distance >= ARTILLERY_TOWN_MIN_SPAWN_DISTANCE then
        local count = surface.count_entities_filtered {
            type = "artillery-turret",
            force = FORCE_NAME,
            radius = ARTILLERY_TOWN_GAP_DISTANCE,
            position = town_position,
        }

        if count < 1 then
            return Bases.types.artillery_towns
        end
    elseif CustomAttacks.can_spawn(LARGE_TOWN_CHANCE) and distance >= LARGE_TOWN_MIN_SPAWN_DISTANCE then
        return Bases.types.large_towns
    end
    
    return Bases.types.towns
end

local get_city_type = function(surface, town_position, spawn_location)
    local distance = Position.distance(town_position, spawn_location)
    if CustomAttacks.can_spawn(NUCLEAR_CITY_CHANCE) and distance >= NUCLEAR_CITY_MIN_SPAWN_DISTANCE then
        return Bases.types.nuclear_cities
    elseif distance >= ARTILLERY_CITY_MIN_SPAWN_DISTANCE and CustomAttacks.can_spawn(ARTILLERY_CITY_CHANCE) then
        local count = surface.count_entities_filtered {
            type = "artillery-turret",
            force = FORCE_NAME,
            radius = ARTILLERY_TOWN_GAP_DISTANCE,
            position = town_position,
            limit = 1
        }

        if count < 1 then
            return Bases.types.artillery_cities
        end
    end
    
    return Bases.types.cities
end

--- Get blueprint to build and setup a city/town beacon
local build_base = function(surface, chunk_center, beacon, town_type)
    local town_data, town_width = Bases.get_town(town_type)
    build_blueprint_base({
        surface = surface, 
        blueprint_string = town_data,
        position = chunk_center, 
        town_size = town_width,
    })

    surface.create_entity({
        name = beacon,
        force = FORCE_NAME,
        position = chunk_center
    })
end

--- Setup condition to allow building a town
local can_spawn_town = function(surface, area)
    if not CustomAttacks.can_spawn(5) then
        return false
    end
    
    local left_top = area.left_top
    local beacons = surface.find_entities_filtered({
        name = {TOWN_BEACON, CITY_BEACON},
        radius = TOWN_BEACON_SEARCH_RANGE,
        position = left_top,
        limit = 1
    })
    
    if next(beacons) then
        return false
    end

    --- Check water tile
    local offset = 24
    local positions = {
        {x = left_top.x + offset,y = left_top.y + offset},
        {x = left_top.x - offset,y = left_top.y - offset},
        {x = left_top.x + offset,y = left_top.y - offset},
        {x = left_top.x - offset,y = left_top.y + offset},
    }

    for _, position in pairs(positions) do
        local tile = surface.get_tile(position.x, position.y)
        if tile.prototype.collision_mask.layers.water_tile then
            return false
        end
    end

    return true
end

--- Setup condition to allow building a city
local can_spawn_city = function(surface, area)
    if not CustomAttacks.can_spawn(1) then
        return false
    end

    local left_top = area.left_top
    local beacons = surface.find_entities_filtered({
        name = {CITY_BEACON},
        radius = CITY_BEACON_SEARCH_RANGE,
        position = left_top,
        limit = 1
    })

    if next(beacons) then
        return false
    end

    --- Check water tile
    local offset = 24
    local positions = {
        {x = left_top.x + offset,y = left_top.y + offset},
        {x = left_top.x - offset,y = left_top.y - offset},
        {x = left_top.x + offset,y = left_top.y - offset},
        {x = left_top.x - offset,y = left_top.y + offset},
    }

    for _, position in pairs(positions) do
        local tile = surface.get_tile(position.x, position.y)
        if tile.prototype.collision_mask.layers.water_tile then
            return false
        end
    end
    
    return true
end

local get_earth_landing_location = function(surface, chunk_center)
    local spawn_location = storage.earth_landing_location
    if not spawn_location then
        local player_forces = remote.call('enemyracemanager', 'get_player_forces')
        for _, force in pairs(player_forces) do
            local force_spawn_location = game.forces[force].get_spawn_position(surface)
            if force_spawn_location then
                spawn_location = force_spawn_location
                storage.earth_landing_location = force_spawn_location
                break
            end
        end
    end
    return spawn_location
end

local scale = 12
local on_chunk_generated = function(event)
    local surface = event.surface
    if is_invalid_surface(surface) then
        return
    end
    
    local chunk_center = center_beacon_position(event.area)
    --- don't let it build towns near spawn locations
    local spawn_location = get_earth_landing_location(surface, chunk_center)

    if spawn_location == nil or Position.distance(spawn_location, chunk_center) < TOWN_MIN_SPAWN_DISTANCE then
        return
    end

    if can_spawn_city(surface, event.area) then
        local city_circle = rendering.draw_sprite({
            sprite = "entity/"..CITY_BEACON,
            x_scale = scale,
            y_scale = scale,
            target = chunk_center,
            surface = surface,
            render_mode="chart",
        })
        storage.town_beacons[city_circle.id] = {
            icon = city_circle,
            chunk_center = chunk_center,
            spawn_location = spawn_location,
        }
        local city_type = get_city_type(surface, chunk_center, spawn_location)
        build_base(surface, chunk_center, CITY_BEACON, city_type)
    elseif can_spawn_town(surface, event.area) then
        local town_circle = rendering.draw_sprite({
            sprite = "entity/"..TOWN_BEACON,
            x_scale = scale,
            y_scale = scale,
            target = chunk_center,
            surface = surface,
            render_mode="chart",
        })
        storage.town_beacons[town_circle.id] = {
            icon = town_circle,
            chunk_center = chunk_center,
            spawn_location = spawn_location,
        }
        local town_type = get_town_type(surface, chunk_center, spawn_location)
        build_base(surface, chunk_center, TOWN_BEACON, town_type)
    end
end

--- When enemy base builder reach its destination and is close to a previous town and city location.  
--- They build a town/city block instead
local on_build_base_arrived = function(event)
    local entity = event.group
    if not entity or not entity.valid then
        return
    end
    
    local surface = entity.surface
    if is_invalid_surface(surface) then
        return 
    end
    
    local position = entity.position
    local beacons = surface.find_entities_filtered {
        type = {CITY_BEACON, TOWN_BEACON},
        force = entity.force,
        position = position,
        radius = 64,
        limit = 1
    }
    local idx, beacon = next(beacons)
    if beacon then
        local beacon_data = storage.town_beacons[beacon.id]
        if beacon.name == CITY_BEACON then
            local city_type = get_city_type(surface, beacon_data.chunk_center, beacon_data.spawn_location)
            build_base(surface, beacon_data.chunk_center, CITY_BEACON, city_type)
        else
            local town_type = get_town_type(surface, beacon_data.chunk_center, beacon_data.spawn_location)
            build_base(surface, beacon_data.chunk_center, TOWN_BEACON, town_type)
        end
    end

    for _, member in pairs(event.group.members) do
        member.destroy()
    end
end

local BaseBuilding = {}

BaseBuilding.events = {
    [defines.events.on_chunk_generated] = on_chunk_generated,
    [defines.events.on_build_base_arrived] = on_build_base_arrived,
}

BaseBuilding.on_nth_tick = {
    [29] = build_entities,
    [63] = process_landfill_queue
}


local init = function(event)
    storage.landfill_queue = storage.landfill_queue or {}
    storage.build_queue = storage.build_queue or {}
    storage.town_beacons = storage.town_beacons or {}
    storage.earth_landing_location = storage.earth_landing_location or nil
end

BaseBuilding.on_configuration_changed = init

BaseBuilding.on_init = init

return BaseBuilding