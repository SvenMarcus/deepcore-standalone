--******************************************************************************
--     _______ __
--    |_     _|  |--.----.---.-.--.--.--.-----.-----.
--      |   | |     |   _|  _  |  |  |  |     |__ --|
--      |___| |__|__|__| |___._|________|__|__|_____|
--     ______
--    |   __ \.-----.--.--.-----.-----.-----.-----.
--    |      <|  -__|  |  |  -__|     |  _  |  -__|
--    |___|__||_____|\___/|_____|__|__|___  |_____|
--                                    |_____|
--*   @Author:              [TR]Pox
--*   @Date:                2018-03-10T03:05:37+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            GalacticConquest.lua
--*   @Last modified by:    [TR]Pox
--*   @Last modified time:  2018-03-10T19:27:15+01:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

require("eawx-std/class")
require("eawx-galaxy/GalacticEvents")
require("eawx-galaxy/Planet")

---@class GalacticConquest
GalacticConquest = class()

function GalacticConquest:new(playableFactions)
    self.HumanPlayer = self:FindHumanPlayerInTable(playableFactions)

    ---@type Planet[]
    self.Planets = self:GetPlanets()

    self.Events = {
        PlanetOwnerChanged = PlanetOwnerChangedEvent(self.Planets),
        GalacticProductionStarted = ProductionStartedEvent(self.Planets),
        GalacticProductionFinished = ProductionFinishedEvent(self.Planets),
        GalacticProductionCanceled = ProductionCanceledEvent(self.Planets),
        GalacticHeroKilled = GalacticHeroKilledEvent(),
        TacticalBattleStarting = TacticalBattleStartingEvent(),
        TacticalBattleEnding = TacticalBattleEndingEvent()
    }
end

---@private
function GalacticConquest:FindHumanPlayerInTable(factions)
    for _, faction in pairs(factions) do
        local player = Find_Player(faction)
        if player.Is_Human() then
            return player
        end
    end
end

---@private
function GalacticConquest:GetPlanets()
    local all_planets = FindPlanet.Get_All_Planets()

    local planets = {}
    for _, planet in pairs(all_planets) do
        local planet_name = planet.Get_Type().Get_Name()
        planets[planet_name] = Planet(planet_name, self.HumanPlayer)
    end

    return planets
end

return GalacticConquest
