require("deepcore/std/class")
require("deepcore/std/callable")
StoryUtil = require("eawx-util/StoryUtil")

---@class SpawnHeroBuilder
SpawnHeroBuilder = class()

---@param hero string
function SpawnHeroBuilder:new(hero)
    self.hero = {hero}

    self.Active_Planets = {}
    ---@type PlayerObject
    self.faction = nil

    ---@type string
    self.planet = nil
end

---@param factions string
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
        hero = self.hero,
        planet = self.planet,
        Active_Planets = self.Active_Planets,
        call = function(self)
            self.Active_Planets = StoryUtil.GetSafePlanetTable()
            local player_object = Find_Player(self.faction)
            StoryUtil.SpawnAtSafePlanet(self.planet, player_object, self.Active_Planets, self.hero)
        end
    }
end
