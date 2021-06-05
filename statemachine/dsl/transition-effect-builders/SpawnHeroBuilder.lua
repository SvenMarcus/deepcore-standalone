require("deepcore/std/class")
require("deepcore/std/callable")

---@class SpawnHeroBuilder
SpawnHeroBuilder = class()

---@param hero_name string
function SpawnHeroBuilder:new(hero_name)
    self.hero_name = hero_name

    ---@type PlayerObject
    self.faction = nil

    ---@type string
    self.planet = nil
end

---@param faction string
function SpawnHeroBuilder:for_faction(faction)
    self.faction = faction
    return self
end

---@param planet string
function SpawnHeroBuilder:on_planet(planet)
    self.planet = planet
    return self
end

function SpawnHeroBuilder:build()
    return callable {
        faction = self.faction,
        hero = self.hero_name,
        planet = self.planet,
        call = function(self)
            local object_type = Find_Object_Type(self.hero)
            local planet_object = FindPlanet(self.planet)
            local player_object = Find_Player(self.faction)
            Spawn_Unit(object_type, planet_object, player_object)
        end
    }
end
