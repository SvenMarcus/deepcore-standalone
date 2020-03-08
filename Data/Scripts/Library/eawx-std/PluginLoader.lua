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
--*       File:              PluginLoader.lua                                                      *
--*       File Created:      Saturday, 22nd February 2020 05:33                                    *
--*       Author:            [TR] Pox                                                              *
--*       Last Modified:     Sunday, 23rd February 2020 10:39                                      *
--*       Modified By:       [TR] Pox                                                              *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("eawx-std/class")

---@class PluginLoader
PluginLoader = class()

function PluginLoader:new(ctx, plugin_folder)
    self.plugin_folder = plugin_folder
    self.loaded_plugins = {}
    self.plugins_by_target = {}
    self.context = ctx or {}
end

---@param plugin_list string[] @(Optional) A table with plugin folder names
function PluginLoader:load(plugin_list)
    if not plugin_list then
        plugin_list = require(self.plugin_folder .. "/InstalledPlugins")
    end
    local unresolved_plugins = {}

    for _, plugin_name in pairs(plugin_list) do
        self:load_plugin(plugin_name, unresolved_plugins)
    end
end

function PluginLoader:get_plugins_for_target(target_name)
    return self.plugins_by_target[target_name] or {}
end

---@private
function PluginLoader:load_plugin(plugin_name, unresolved_plugins)
    if unresolved_plugins[plugin_name] then
        error("Cyclic Dependency!")
        return
    end

    if self.loaded_plugins[plugin_name] then
        return
    end

    unresolved_plugins[plugin_name] = true
    local plugin_def = require(self.plugin_folder.. "/" .. plugin_name .. "/init")

    local loaded_dependencies = {}
    if plugin_def.dependencies and table.getn(plugin_def.dependencies) > 0 then
        for _, dependency in pairs(plugin_def.dependencies) do
            if not self.loaded_plugins[dependency] then
                self:load_plugin(dependency, unresolved_plugins)
            end

            table.insert(loaded_dependencies, self.loaded_plugins[dependency])
        end
    end

    self.loaded_plugins[plugin_name] = plugin_def:init(self.context, unpack(loaded_dependencies))
    local target = plugin_def.target
    if not self.plugins_by_target[target] then
        self.plugins_by_target[target] = {}
    end
    table.insert(self.plugins_by_target[target], self.loaded_plugins[plugin_name])
    unresolved_plugins[plugin_name] = nil
end
