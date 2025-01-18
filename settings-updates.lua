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