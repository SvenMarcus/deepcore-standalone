local name_comparable = require("spec.name_comparable")
local make_fake_player = require("spec.fake_playerobject")

---@param name string
---@param owner? string
local function make_fake_planet(name, owner)
    local planet_type = name_comparable(name)
    function planet_type.Get_Name()
        return name
    end

    local planet = name_comparable(name)
    function planet.Get_Type()
        return planet_type
    end

    function planet.Get_Owner()
        return make_fake_player(owner or "OWNER")
    end

    return planet
end

return make_fake_planet