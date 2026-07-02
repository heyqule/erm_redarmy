## How to set up custom city builder for your own race?

### First, Copy the following to your mod
1. script/base_building.sample.lua, rename to base_building.lua
2. base.lua
3. .city_json folder 
4. Add the following to your control.lua
```lua
local handler = require("event_handler")
handler.add_lib(require('scripts/base_building'))
```

### Setting up scripts/base_building.lua
- This handles the spawn logics.
- Change it to fit your use case as it's designed for red army.

### Setting up base.lua
- Set up the types of town/city.
- Get the centered blueprint string with .city_json/city_blueprint.py
- Set weight.

### Using .city_json/city_blueprint.py to center {x=0,y=0} the blueprint base.
- Copy your base blueprint to building.txt
- run the script ```python -r .city_json/city_blueprint.py```
- copy the text from result.txt to your base.lua.
- you can also verify the entity output in result.json.