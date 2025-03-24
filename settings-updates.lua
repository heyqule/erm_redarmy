require 'global'

table.insert(data.raw["string-setting"]["enemyracemanager-nauvis-enemy"].allowed_values, MOD_NAME)

table.insert(data.raw["string-setting"]["enemyracemanager-2way-group-enemy-positive"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-2way-group-enemy-negative"].allowed_values, MOD_NAME)

table.insert(data.raw["string-setting"]["enemyracemanager-4way-northeast"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-4way-northwest"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-4way-southwest"].allowed_values, MOD_NAME)
table.insert(data.raw["string-setting"]["enemyracemanager-4way-southeast"].allowed_values, MOD_NAME)

if data.raw["string-setting"]["enemyracemanager-2way-group-enemy-positive"].default_value ~= MOD_NAME then
    data.raw["string-setting"]["enemyracemanager-2way-group-enemy-positive"].default_value = MOD_NAME
end

if data.raw["string-setting"]["enemyracemanager-4way-northwest"].default_value ~= MOD_NAME then
    data.raw["string-setting"]["enemyracemanager-4way-northwest"].default_value = MOD_NAME
end

--- Planet earth default setting changes
if mods["factorio-world"] then
    if feature_flags.space_travel then
        data.raw["bool-setting"]["only-apply-to-earth"].default_value = true
    end
    
    data.raw["double-setting"]["map-gen-scale"].default_value = 10
    data.raw["int-setting"]["safe-zone-size"].default_value = 12
end