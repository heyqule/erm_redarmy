--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:04 PM
-- To change this template use File | Settings | File Templates.
--

local Game = require('__stdlib__/stdlib/game')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local CustomAttacks = require('__erm_redarmy__/scripts/custom_attacks')

local Event = require('__stdlib__/stdlib/event/event')
local String = require('__stdlib__/stdlib/utils/string')

require('__erm_redarmy__/global')
-- Constants

local createRace = function()
    local force = game.forces[FORCE_NAME]
    if not force then
        force = game.create_force(FORCE_NAME)
    end

    force.ai_controllable = true;
    force.disable_research()
    force.friendly_fire = false;

    if settings.startup['enemyracemanager-free-for-all'].value then
        ErmForceHelper.set_friends(game, FORCE_NAME, false)
    else
        ErmForceHelper.set_friends(game, FORCE_NAME, true)
    end

    ErmForceHelper.set_neutral_force(game, FORCE_NAME)
end

local addRaceSettings = function()
    local race_settings = remote.call('enemyracemanager', 'get_race', MOD_NAME)
    if race_settings == nil then
        race_settings = {}
    end

    race_settings.race =  race_settings.race or MOD_NAME
    race_settings.label = {'gui.label-redarmy'}
    race_settings.level =  race_settings.level or 1
    race_settings.tier =  race_settings.tier or 1
    race_settings.evolution_point =  race_settings.evolution_point or 0
    race_settings.evolution_base_point =  race_settings.evolution_base_point or 0
    race_settings.attack_meter = race_settings.attack_meter or 0
    race_settings.attack_meter_total = race_settings.attack_meter_total or 0
    race_settings.next_attack_threshold = race_settings.next_attack_threshold or 0

    race_settings.units = {
        { 'human-miner', 'human-pistol', 'human-machinegun' },
        { 'human-sniper', 'tank-cannon', 'plane-dropship', 'human-engineer' },
        { 'human-heavy-machinegun', 'human-shotgun', 'tank-explosive-cannon', 'plane-gunner', 'plane-bomber' },
    }
    race_settings.turrets = {
        { 'gun-turret', 'laser-turret' },
        {},
        {},
    }
    race_settings.command_centers = {
        { 'lab' },
        {},
        {}
    }
    race_settings.support_structures = {
        { 'assemble-machine' },
        { 'electric-furnace' },
        { },
    }
    race_settings.timed_units = {
    }
    race_settings.flying_units = {
        {'plane-gunner'},
        {'plane-dropship'},
        {'plane-bomber'}
    }
    race_settings.dropship = 'plane-dropship'
    race_settings.droppable_units = {
        {{ 'human-miner', 'human-pistol' },{3,1}},
        {{ 'human-machinegun', 'tank-cannon' },{4,2}},
        {{ 'human-heavy-machinegun', 'human-shotgun', 'tank-cannon', 'tank-explosive-cannon' },{4,2,1,1}},
    }
    race_settings.construction_buildings = {
        {{ 'gun-turret-short'},{1}},
        {{ 'gun-turret-short'},{1}},
        {{ 'gun-turret-short','lab'},{2,1}},
    }
    race_settings.featured_groups = {
        -- Unit list, spawn ratio, unit attack point cost
        {{'human-heavy-machinegun', 'human-shotgun', 'human-sniper','human-engineer' }, {2, 2, 1, 1}, 20},
        {{'human-machinegun', 'human-heavy-machinegun', 'human-sniper', 'tank-explosive-cannon'}, {2, 2, 1, 1}, 25},
        {{'tank-cannon', 'tank-explosive-cannon'}, {2, 1}, 35},
        {{'human-shotgun','tank-cannon', 'tank-explosive-cannon', 'plane-gunner', 'plane-bomber'}, {2, 1, 1, 1, 1}, 25},
        {{'human-sniper','tank-cannon', 'tank-explosive-cannon','plane-gunner', 'plane-bomber'}, {2,1,1,1,1}, 25},
    }
    race_settings.featured_flying_groups = {
        {{'plane-gunner', 'plane-bomber'}, {3, 2}, 75},
        {{'plane-gunner', 'plane-dropship'}, {2, 1}, 75},
        {{'plane-bomber'}, {1}, 75},
        {{'plane-gunner'}, {1}, 50}
    }

    if game.active_mods['Krastorio2'] then
        race_settings.enable_k2_creep = settings.startup['erm_redarmy-k2-creep'].value
    end

    ErmRaceSettingsHelper.process_unit_spawn_rate_cache(race_settings)

    remote.call('enemyracemanager', 'register_race', race_settings)

end

Event.on_init(function(event)
    createRace()
    addRaceSettings()
end)

Event.on_load(function(event)
end)

Event.on_configuration_changed(function(event)
    createRace()
    addRaceSettings()
end)

local attack_functions =
{
    [DROPSHIP_ATTACK] = function(args)
        CustomAttacks.process_dropship(args)
    end,
    [ENGINEER_ATTACK] = function(args)
        CustomAttacks.process_engineer(args)
    end
}
Event.register(defines.events.on_script_trigger_effect, function(event)
    if  attack_functions[event.effect_id] and
            CustomAttacks.valid(event, MOD_NAME)
    then
        attack_functions[event.effect_id](event)
    end
end)

local RemoteApi = require('scripts/remote')
remote.add_interface("erm_redarmy", RemoteApi)



