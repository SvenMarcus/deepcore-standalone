local name_comparable = require("spec.name_comparable")

---@param name string
local function make_fake_player(name)
    local player = name_comparable(name)
    function player.Get_Faction_Name()
        return name
    end

    return player
end

return make_fake_player