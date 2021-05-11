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
--*   @Date:                2021-05-11
--*   @Project:             Empire at War Expanded
--*   @Filename:            EawXGameScoring.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx/std/class")
require("eawx/std/PluginLoader")
require("eawx/crossplot/crossplot")

---@class EawXGameScoring
EawXGameScoring = class()

function EawXGameScoring:new(context, plugin_list)
    crossplot:master()
    self.context = context or {}
    local plugin_loader = PluginLoader(self.context, "eawx-plugins/gamescoring")

    plugin_loader:load(plugin_list)
    DebugMessage("EawXGameScoring -- plugins loaded successfully")

    self.plugin_containers = plugin_loader:get_plugin_containers()
end

function EawXGameScoring:update()
    crossplot:update()

    for _, plugin_container in ipairs(self.plugin_containers) do
        if plugin_container.target() then
            plugin_container.plugin:update()
        end
    end
end

return EawXGameScoring
