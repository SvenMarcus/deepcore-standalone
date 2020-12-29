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
--*       File:              init.lua                                                              *
--*       File Created:      Monday, 24th February 2020 02:35                                      *
--*       Author:            [TR] Pox                                                              *
--*       Last Modified:     Monday, 24th February 2020 04:28                                      *
--*       Modified By:       [TR] Pox                                                              *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("eawx-std/plugintargets")
require("eawx-plugins/weekly-game-message-service/GameMessageService")

return {
    -- weekly-update gets updated every week. This also means we have to implement an "update()" function!
    target = PluginTargets.interval(45),
    -- We can specify plugin dependencies in this table
    dependencies = {"production-listener"},
    -- The plugins we specified in the dependencies table will be passed to the init function in order
    init = function(self, ctx, production_finished_listener)
        return GameMessageService(production_finished_listener)
    end
}
