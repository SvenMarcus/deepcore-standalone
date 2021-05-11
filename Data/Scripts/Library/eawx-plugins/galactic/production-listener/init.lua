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
--*   @Filename:            init.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx/std/plugintargets")
require("eawx-plugins/galactic/production-listener/ProductionFinishedListener")

return {
    -- The "passive" target means we don't expect to be updated
    target = PluginTargets.never(),
    init = function(self, ctx)
        ---@type GalacticConquest
        local galactic_conquest = ctx.galactic_conquest

        return ProductionFinishedListener(galactic_conquest)
    end
}
