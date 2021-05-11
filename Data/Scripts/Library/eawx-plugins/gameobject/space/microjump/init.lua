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
--*   @Date:                2020-12-30
--*   @Project:             Empire at War Expanded
--*   @Filename:            init.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx/std/plugintargets")
require("eawx-plugins/gameobject/space/microjump/Microjump")

return {
    target = PluginTargets.always(),
    init = function(self, ctx)
        return Microjump()
    end
}
