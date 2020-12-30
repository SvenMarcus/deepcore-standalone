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
--*   @Filename:            GalacticConquest.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx-std/class")
require("eawx-galaxy/GalacticEvents")
require("eawx-galaxy/Planet")

---@class GalacticConquest
GalacticConquest = class()

function GalacticConquest:new()
    self.HumanPlayer = Find_Player("local")

    ---@private
    ---@type table<string, table<string, Planet>>
    self.Planets_By_Faction = {}

    ---@private
    ---@type table<string, number>
    self.Number_Of_Owned_Planets_By_Faction = {}

    ---@type table<string, Planet>
    self.Planets = {}

    self:initialize_galactic_state()

    self.Events = {
        PlanetOwnerChanged = PlanetOwnerChangedEvent(self.Planets),
        GalacticProductionStarted = ProductionStartedEvent(self.Planets),
        GalacticProductionFinished = ProductionFinishedEvent(self.Planets),
        GalacticProductionCanceled = ProductionCanceledEvent(self.Planets),
        GalacticHeroKilled = GalacticHeroKilledEvent(),
        TacticalBattleStarting = TacticalBattleStartingEvent(),
        TacticalBattleEnding = TacticalBattleEndingEvent()
    }

    self.Events.PlanetOwnerChanged:AttachListener(self.update_faction_planet_ownerships, self)
end

---@param faction PlayerObject
function GalacticConquest:get_all_planets_by_faction(faction)
    local faction_name = faction.Get_Faction_Name()
    return self.Planets_By_Faction[faction_name] or {}
end

---@param faction PlayerObject
function GalacticConquest:get_number_of_planets_owned_by_faction(faction)
    local faction_name = faction.Get_Faction_Name()
    return self.Number_Of_Owned_Planets_By_Faction[faction_name] or 0
end

---@private
function GalacticConquest:initialize_galactic_state()
    local all_planets = FindPlanet.Get_All_Planets()

    for _, planet in ipairs(all_planets) do
        local planet_name = planet.Get_Type().Get_Name()
        local planet_object = Planet(planet_name, self.HumanPlayer)
        local owner_name = planet_object:get_owner().Get_Faction_Name()
        self.Planets[planet_name] = planet_object
        self:add_planet_to_faction_table(planet_object)
        self:increase_owned_planet_count_for_faction(owner_name)
    end
end

---@private
---@param planet Planet
function GalacticConquest:add_planet_to_faction_table(planet)
    local planet_owner_name = planet:get_owner().Get_Faction_Name()
    local faction_planet_lookup = self.Planets_By_Faction[planet_owner_name]
    if not faction_planet_lookup then
        self.Planets_By_Faction[planet_owner_name] = {}
        faction_planet_lookup = self.Planets_By_Faction[planet_owner_name]
    end
    faction_planet_lookup[planet:get_name()] = planet
end

---@private
---@param faction_name string
function GalacticConquest:increase_owned_planet_count_for_faction(faction_name)
    if not self.Number_Of_Owned_Planets_By_Faction[faction_name] then
        self.Number_Of_Owned_Planets_By_Faction[faction_name] = 0
    end
    self.Number_Of_Owned_Planets_By_Faction[faction_name] = self.Number_Of_Owned_Planets_By_Faction[faction_name] + 1
end

---@private
---@param planet Planet
---@param new_owner_name string
---@param old_owner_name string
function GalacticConquest:update_faction_planet_ownerships(planet, new_owner_name, old_owner_name)
    self:remove_planet_from_previous_owner_tables(planet, old_owner_name)
    self:add_planet_to_faction_table(planet)
    self:increase_owned_planet_count_for_faction(new_owner_name)
end

---@private
---@param planet Planet
---@param old_owner_name string
function GalacticConquest:remove_planet_from_previous_owner_tables(planet, old_owner_name)
    if self.Planets_By_Faction[old_owner_name] then
        self.Planets_By_Faction[old_owner_name][planet:get_name()] = nil
    end

    if self.Number_Of_Owned_Planets_By_Faction[old_owner_name] then
        self.Number_Of_Owned_Planets_By_Faction[old_owner_name] =
            self.Number_Of_Owned_Planets_By_Faction[old_owner_name] - 1
    end
end

return GalacticConquest
