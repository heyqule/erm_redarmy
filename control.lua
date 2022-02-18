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
local CustomAttacks = require('__erm_redarmy__/prototypes/custom_attacks')

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
end

local addRaceSettings = function()
    local race_settings = remote.call('enemy_race_manager', 'get_race', MOD_NAME)
    if race_settings == nil then
        race_settings = {}
    end

    race_settings.race =  race_settings.race or MOD_NAME
    race_settings.version =  race_settings.version or MOD_VERSION
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
        {  },
    }
    race_settings.flying_units = {
        {'plane-gunner'}, -- Fast unit that uses in rapid target attack group
        {'plane-dropship'},
        {'plane-bomber'}
    }
    race_settings.dropship = 'plane-dropship'

    remote.call('enemy_race_manager', 'register_race', race_settings)

    Event.dispatch({
        name = Event.get_event_name(ErmConfig.RACE_SETTING_UPDATE), affected_race = MOD_NAME })

end

Event.on_init(function(event)
    createRace()
    addRaceSettings()
end)

Event.on_load(function(event)
end)

Event.on_configuration_changed(function(event)
    createRace()

    -- Mod Compatibility Upgrade for race settings
    Event.dispatch({
        name = Event.get_event_name(ErmConfig.RACE_SETTING_UPDATE), affected_race = MOD_NAME })
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

---
--- Modify Race Settings for existing game
---
Event.register(Event.generate_event_name(ErmConfig.RACE_SETTING_UPDATE), function(event)
    local race_setting = remote.call('enemy_race_manager', 'get_race', MOD_NAME)
    if (event.affected_race == MOD_NAME) and race_setting then
        if race_setting.version < MOD_VERSION then
            if race_setting.version < 101 then
                race_setting.angry_meter = nil
                race_setting.send_attack_threshold = nil
                race_setting.send_attack_threshold_deviation = nil
                race_setting.attack_meter = 0
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 2, 'plane-dropship')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 3, 'plane-gunner')
                ErmRaceSettingsHelper.remove_unit_from_tier(race_setting, 3, 'plane-laser')
                race_setting.flying_units = {
                    {'plane-gunner'}, -- Fast unit that uses in rapid target attack group
                    {'plane-dropship'},
                    {'plane-bomber'}
                }
                race_setting.dropship = 'plane-dropship'
            end

            if race_setting.version < 102 then
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 2, 'human-engineer')
                ErmRaceSettingsHelper.remove_unit_from_tier(race_setting, 2, 'human-machinegun')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 1, 'human-machinegun')
            end

            race_setting.version = MOD_VERSION
        end
        remote.call('enemy_race_manager', 'update_race_setting', race_setting)
    end
end)




