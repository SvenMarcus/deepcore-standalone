require("deepcore/std/class")
require("deepcore/std/callable")

---@class SetTechLevelBuilder
SetTechLevelBuilder = class()

---@param level number
function SetTechLevelBuilder:new(level)
    self.level = level

    ---@type table<number, string>
    self.factions = {}
end

---@vararg string
function SetTechLevelBuilder:for_factions(...)
    self.factions = arg
    return self
end

function SetTechLevelBuilder:build()
    return callable {
        factions = self.factions,
        tech_level = self.level,
        call = function(self)
            for _, faction in ipairs(self.factions) do
                local player_object = Find_Player(faction)
                if player_object then
                    player_object.Set_Tech_Level(self.tech_level)
                end
            end
        end
    }
end
