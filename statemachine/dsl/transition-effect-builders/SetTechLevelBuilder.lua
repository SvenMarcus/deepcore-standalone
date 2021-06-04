require("deepcore/std/class")
require("deepcore/std/callable")
require("eawx-util/StoryUtil")

---@class SetTechLevelBuilder
SetTechLevelBuilder = class()

---@param level number
function SetTechLevelBuilder:new(level)
    self.level = level

    ---@type PlayerObject
    self.factions = {}
end

---@param factions string
function SetTechLevelBuilder:for_factions(factions)
    self.factions = factions
    return self
end

function SetTechLevelBuilder:build()
    return callable {
        factions = self.factions,
        tech_level = self.level,
        call = function(self)
            for _, faction in pairs(self.factions) do
                local player_object = Find_Player(faction)
                StoryUtil.SetTechLevel(player_object, self.tech_level)
            end
        end
    }
end
