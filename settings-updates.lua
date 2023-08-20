require 'global'

table.insert(data.raw["string-setting"]["enemyracemanager-2way-group-enemy-positive"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-2way-group-enemy-negative"].allowed_values, MOD_NAME)

table.insert(data.raw["string-setting"]["enemyracemanager-4way-top-left"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-4way-top-right"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-4way-bottom-right"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-4way-bottom-left"].allowed_values, MOD_NAME)

if mods['Krastorio2'] then
    data:extend {
        {
            type = "bool-setting",
            name = "erm_redarmy-k2-creep",
            description = "erm_redarmy-k2-creep",
            setting_type = "startup",
            default_value = true,
            order = "erm_redarmy-120",
        },
    }
end
