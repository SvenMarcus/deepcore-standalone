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

require("deepcore/std/plugintargets")

return {
    target = PluginTargets.story_flag("SELECT_CREDIT_FILTER"),

    init = function(self, ctx)
        local plot = Get_Story_Plot("STORY_SANDBOX_27_UNDERWORLD.XML")
        local event = plot.Get_Event("Click_Filter")
        event.Set_Reward_Parameter(1, Find_Player("local").Get_Faction_Name())

        return {
            update = function(self)
                Game_Message("TEXT_TOOLTIP_CREDIT_FILTER")
            end
        }
    end
}
