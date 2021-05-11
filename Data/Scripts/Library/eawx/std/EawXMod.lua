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

require("eawx/std/class")
require("eawx/crossplot/crossplot")
require("eawx/galaxy/init")

require("eawx/std/PluginLoader")

---@class EawXMod
EawXMod = class()

function EawXMod:new(context, plugin_list)
    crossplot:galactic()
    self.galactic_conquest = GalacticConquest()

    if not context then
        context = {}
    end

    context.galactic_conquest = self.galactic_conquest

    local plugin_loader = PluginLoader(context, "eawx-plugins/galactic")
    plugin_loader:load(plugin_list)

    self.plugin_containers = plugin_loader:get_plugin_containers()
    self.planet_plugin_containers = plugin_loader:get_planet_dependent_plugin_containers()
end

function EawXMod:update()
    crossplot:update()

    for _, plugin_container in ipairs(self.plugin_containers) do
        if plugin_container.target() then
            plugin_container.plugin:update()
        end
    end

    local cache = {}
    for _, planet in pairs(self.galactic_conquest.Planets) do
        for _, plugin_container in ipairs(self.planet_plugin_containers) do
            if self:allowed_to_update(plugin_container, cache) then
                plugin_container.plugin:update(planet)
            end
        end
    end
end

---@private
function EawXMod:allowed_to_update(plugin_container, cache)
    if cache[plugin_container.target] == nil then
        cache[plugin_container.target] = plugin_container.target()
    end

    return cache[plugin_container.target]
end

return EawXMod
