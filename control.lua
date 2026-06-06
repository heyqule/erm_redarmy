--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:04 PM
-- To change this template use File | Settings | File Templates.
--

local handler = require("event_handler")
handler.add_lib(require('scripts/initialize'))
handler.add_lib(require('scripts/base_building'))
handler.add_lib(require('scripts/nuclear_silo'))
handler.add_lib(require('scripts/artillery'))

local RemoteApi = require('scripts/remote')
remote.add_interface("erm_redarmy", RemoteApi)


---
--- Register required remote interfaces
---
--- Register boss attacks
--- Interface Name: {race_name}_boss_attacks
---
local BossAttack = require("scripts/boss_attacks")
remote.add_interface("erm_redarmy_boss_attacks", {
    get_attack_data = BossAttack.get_attack_data,
})


