--**************************************************************************************************
--*    _______ __                                                                                  *
--*   |_     _|  |--.----.---.-.--.--.--.-----.-----.                                              *
--*     |   | |     |   _|  _  |  |  |  |     |__ --|                                              *
--*     |___| |__|__|__| |___._|________|__|__|_____|                                              *
--*    ______                                                                                      *
--*   |   __ \.-----.--.--.-----.-----.-----.-----.                                                *
--*   |      <|  -__|  |  |  -__|     |  _  |  -__|                                                *
--*   |___|__||_____|\___/|_____|__|__|___  |_____|                                                *
--*                                   |_____|                                                      *
--*                                                                                                *
--*                                                                                                *
--*       File:              GameMessageService.lua                                                *
--*       File Created:      Monday, 24th February 2020 02:40                                      *
--*       Author:            [TR] Pox                                                              *
--*       Last Modified:     Monday, 24th February 2020 03:16                                      *
--*       Modified By:       [TR] Pox                                                              *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("deepcore/std/class")

---@class GameMessageService
GameMessageService = class()

---@param production_finished_listener ProductionFinishedListener
function GameMessageService:new(production_finished_listener)
    self.production_finished_listener = production_finished_listener
end

-- We'll show a Game_Message for every produced object
function GameMessageService:update()
    local objects_produced = self.production_finished_listener.total_amount_of_objects

    for i = 1, objects_produced do
        Game_Message("TEXT_FACTION_EMPIRE")
    end

    crossplot:publish("MESSAGE", "Hi from weekly message service")
end
