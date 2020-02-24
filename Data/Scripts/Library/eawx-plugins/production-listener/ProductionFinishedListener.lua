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
--*       File:              ProductionFinishedListener.lua                                        *
--*       File Created:      Monday, 24th February 2020 02:19                                      *
--*       Author:            [TR] Pox                                                              *
--*       Last Modified:     Monday, 24th February 2020 02:34                                      *
--*       Modified By:       [TR] Pox                                                              *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("eawx-std/class")

---@class ProductionFinishedListener
ProductionFinishedListener = class()

---@param galactic_conquest GalacticConquest
function ProductionFinishedListener:new(galactic_conquest)
    self.human_player = galactic_conquest.HumanPlayer
    self.total_amount_of_objects = 0
    galactic_conquest.Events.GalacticProductionFinished:AttachListener(self.on_production_finished, self)
end

---We don't like to lose money, so we return it to the player on build completion
---@param planet Planet
---@param object_type_name string
function ProductionFinishedListener:on_production_finished(planet, object_type_name)
    if not planet:get_owner().Is_Human() then
        return
    end

    self.total_amount_of_objects = self.total_amount_of_objects + 1

    local object_type = Find_Object_Type(object_type_name)
    if object_type then
        local cost = object_type.Get_Build_Cost()
        self.human_player.Give_Money(cost)
    end
end
