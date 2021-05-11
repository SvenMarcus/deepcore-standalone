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
--*   @Date:                2020-12-29
--*   @Project:             Empire at War Expanded
--*   @Filename:            init.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx/std/plugintargets")

return {
    target = PluginTargets.interval(45),
    requires_planets = true,
    init = function(self, ctx)
        return {
            ---@param planet Planet
            update = function(self, planet)
                if planet:get_game_object() ~= FindPlanet("Kuat") then
                    return
                end

                local empire = Find_Player("Empire")
                local rebel = Find_Player("Rebel")
                local current_owner = planet:get_owner()
                if current_owner == empire then
                    planet:get_game_object().Change_Owner(rebel)
                else
                    planet:get_game_object().Change_Owner(empire)
                end
            end
        }
    end
}
