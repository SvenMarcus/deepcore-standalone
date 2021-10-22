require("deepcore/std/callable")

---@class conditions
local conditions = {}

function conditions.owned_by(faction_name)
    return callable {
        faction_name = faction_name,
        call = function(self, game_object)
            return Find_Player(self.faction_name) == game_object.Get_Owner()
        end
    }
end


return conditions