require("deepcore/std/class")
require("deepcore/std/callable")

---@class PlanetTransferBuilder
PlanetTransferBuilder = class()

---@vararg string
function PlanetTransferBuilder:new(...)
    ---@type table<number, string>
    self.planets = arg

    self.Active_Planets = {}

    ---@type PlayerObject
    self.target_owner = nil

    ---@param planet PlanetObject
    ---@param new_owner PlayerObject
    ---@return nil
    function self.change_owner_strategy(planet, new_owner)
        planet.Change_Owner(new_owner)
    end

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

---@param func fun(planet: PlanetObject, new_owner: PlayerObject): nil
function PlanetTransferBuilder:with_change_owner_strategy(func)
    self.change_owner_strategy = func
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
        change_owner_strategy = self.change_owner_strategy,
        call = function(self)
            for _, planet in ipairs(self.planets) do
                local planet_object = self:get_planet(planet)
                if self.condition(planet_object) then
                    self.change_owner_strategy(planet_object, self.new_owner)
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
