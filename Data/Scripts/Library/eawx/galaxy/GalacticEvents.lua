--*****************************************************************************
--*    _______ __
--*   |_     _|  |--.----.---.-.--.--.--.-----.-----.
--*     |   | |     |   _|  _  |  |  |  |     |__ --|
--*     |___| |__|__|__| |___._|________|__|__|_____|
--*    ______
--*   |   __ \.-----.--.--.-----.-----.-----.-----.
--*   |      <|  -__|  |  |  -__|     |  _  |  -__|
--*   |___|__||_____|\___/|_____|__|__|___  |_____|
--*                                   |_____|
--*
--*   @Author:              [EaWX]Pox
--*   @Date:                2020-12-23
--*   @Project:             Empire at War Expanded
--*   @Filename:            GalacticEvents.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx/std/class")
require("eawx/std/Observable")
require("eawx/crossplot/crossplot")

---@class PlanetOwnerChangedEvent : Observable
PlanetOwnerChangedEvent = class(Observable)

function PlanetOwnerChangedEvent:new(planets)
    self.planets = planets
    crossplot:subscribe("PLANET_OWNER_CHANGED", self.planet_owner_changed, self)
end

function PlanetOwnerChangedEvent:planet_owner_changed(planet_name, new_owner_name, old_owner_name)
    if not planet_name then
        return
    end

    local planet = self.planets[planet_name]
    self:notify(planet, new_owner_name, old_owner_name)
end

---@class ProductionStartedEvent : Observable
ProductionStartedEvent = class(Observable)

function ProductionStartedEvent:new(planets)
    ---@private
    ---@type Planet[]
    self.planets = planets
    crossplot:subscribe("PRODUCTION_STARTED", self.production_started, self)
end

function ProductionStartedEvent:production_started(planet_name, object_type_name)
    local planet = self.planets[planet_name]
    self:notify(planet, object_type_name)
end

---@class ProductionFinishedEvent : Observable
ProductionFinishedEvent = class(Observable)

function ProductionFinishedEvent:new(planets)
    self.planets = planets
    crossplot:subscribe("PRODUCTION_FINISHED", self.production_finished, self)
end

function ProductionFinishedEvent:production_finished(planet_name, object_type_name)
    local planet = self.planets[planet_name]
    self:notify(planet, object_type_name)
end

---@class ProductionCanceledEvent : Observable
ProductionCanceledEvent = class(Observable)

function ProductionCanceledEvent:new(planets)
    ---@private
    ---@type Planet[]
    self.planets = planets
    crossplot:subscribe("PRODUCTION_CANCELED", self.production_canceled, self)
end

function ProductionCanceledEvent:production_canceled(planet_name, object_type_name)
    local planet = self.planets[planet_name]
    self:notify(planet, object_type_name)
end

---@class GalacticHeroKilledEvent : Observable
GalacticHeroKilledEvent = class(Observable)

function GalacticHeroKilledEvent:new()
    crossplot:subscribe("GALACTIC_HERO_KILLED", self.galactic_hero_killed, self)
end

function GalacticHeroKilledEvent:galactic_hero_killed(hero_name)
    self:notify(hero_name)
end

---@class TacticalBattleEndedEvent : Observable
TacticalBattleEndedEvent = class(Observable)

function TacticalBattleEndedEvent:new()
    crossplot:subscribe("GAME_MODE_ENDING", self.battle_ended, self)
end

function TacticalBattleEndedEvent:battle_ended(mode_name)
    self:notify(mode_name)
end