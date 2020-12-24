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
--*   @Filename:            EawXMod.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx-std/class")
require("eawx-crossplot/crossplot")
require("eawx-galaxy/init")

require("eawx-std/PluginLoader")

---@class EawXMod
EawXMod = class()

function EawXMod:new(context, plugin_list)
    crossplot:galactic()
    self.galactic_conquest = GalacticConquest()

    if not context then
        context = {}
    end

    context.galactic_conquest = self.galactic_conquest

    local plugin_loader = PluginLoader(context, "eawx-plugins")
    plugin_loader:load(plugin_list)

    self.frame_update_plugins = plugin_loader:get_plugins_for_target("frame-update") or {}
    self.frame_planet_update_plugins = plugin_loader:get_plugins_for_target("frame-planet-update") or {}

    self.weekly_update_plugins = plugin_loader:get_plugins_for_target("weekly-update") or {}
    self.weekly_planet_update_plugins = plugin_loader:get_plugins_for_target("weekly-planet-update") or {}

    self.passive_plugins = plugin_loader:get_plugins_for_target("passive") or {}

    self.last_week_update = 0
    self.week_duration = 45
end

function EawXMod:update()
    crossplot:update()
    local week_passed = self:week_passed()
    for _, plugin in pairs(self.frame_update_plugins) do
        plugin:update()
    end

    if week_passed then
        for _, plugin in pairs(self.weekly_update_plugins) do
            plugin:update()
        end
    end

    for _, planet in pairs(self.galactic_conquest.Planets) do
        for _, plugin in pairs(self.frame_planet_update_plugins) do
            plugin:update(planet)
        end

        if week_passed then
            for _, plugin in pairs(self.weekly_planet_update_plugins) do
                plugin:update(planet)
            end
        end
    end
end

---@private
function EawXMod:week_passed()
    local week_passed = false
    if self.last_week_update == 0 or GetCurrentTime() - self.last_week_update >= self.week_duration then
        week_passed = true
        self.last_week_update = GetCurrentTime()
    end

    return week_passed
end

return EawXMod
