require("deepcore/std/class")
require("deepcore/std/callable")
require("eawx-util/ChangeOwnerUtilities")
require("deepcore/statemachine/dsl/conditions")
require("eawx-util/StoryUtil")

---@class PlanetTransferBuilder
PlanetTransferBuilder = class()

---@vararg string
function PlanetTransferBuilder:new(...)
    ---@type table<number, string>
    self.planets = arg

    self.Active_Planets = {}

    ---@type PlayerObject
    self.target_owner = nil

    ---@type fun(): boolean
    self.condition = function()
        return true
    end
end

---@param faction_name string
function PlanetTransferBuilder:to_owner(faction_name)
    self.target_owner = Find_Player(faction_name)
    return self
end


---@param condition fun(): boolean
function PlanetTransferBuilder:if_(condition)
    self.condition = condition
    return self
end

function PlanetTransferBuilder:build()
    return callable {
        planets = self.planets,
        new_owner = self.target_owner,
        condition = self.condition,
        Active_Planets = self.Active_Planets,
        call = function(self) 
            self.Active_Planets = StoryUtil.GetSafePlanetTable()
            for _, planet in ipairs(self.planets) do
                if self.Active_Planets[planet] then
                    local planet_object = self:get_planet(planet)
                    if self.condition(planet_object) then
                        ChangePlanetOwnerAndRetreat(planet_object, self.new_owner)
                    end
                end
            end
        end,
        get_planet = function(self, planet_like)
            if type(planet_like) == "userdata" then
                return planet_like
            end

            if type(planet_like) == "table" and planet_like.get_game_object then
                return planet_like:get_game_object()
            end

            return FindPlanet(planet_like)
        end
    }
end

return PlanetTransferBuilder
