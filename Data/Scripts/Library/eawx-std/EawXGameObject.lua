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
--*   @Filename:            EawXGameObject.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx-std/class")
require("eawx-std/PluginLoader")
require("eawx-crossplot/crossplot")

---@class EawXGameObject
EawXGameObject = class()

function EawXGameObject:new(context, plugin_list)
    crossplot:game_object()
    context = context or {}
    local game_mode_name = string.lower(tostring(Get_Game_Mode()))
    DebugMessage("EawXGameObject -- before loading plugins. game mode: %s", tostring(Get_Game_Mode()))
    local plugin_loader = PluginLoader(self.context, "eawx-plugins-" .. game_mode_name)

    plugin_loader:load(plugin_list)
    DebugMessage("EawXGameObject -- plugins loaded successfully")

    self.frame_update_plugins = plugin_loader:get_plugins_for_target("frame-update")
    self.passive_plugins = plugin_loader:get_plugins_for_target("passive")
end

function EawXGameObject:update()
    crossplot:update()
    for _, plugin in pairs(self.frame_update_plugins) do
        plugin:update()
    end
end

return EawXGameObject
