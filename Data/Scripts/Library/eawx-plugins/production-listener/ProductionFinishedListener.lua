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
--*   @Filename:            ProductionFinishedListener.lua
--*   @License:             MIT
--*****************************************************************************

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
