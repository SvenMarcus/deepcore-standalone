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
--*   @Filename:            PluginLoader.lua
--*   @License:             MIT
--*****************************************************************************

require("deepcore/std/class")

---@class PluginLoader
PluginLoader = class()

function PluginLoader:new(ctx, plugin_folder)
    self.plugin_folder = plugin_folder
    self.loaded_plugins = {}
    self.plugin_containers = {}
    self.planet_dependent_plugin_containers = {}
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

    DebugMessage("Loaded %s plugins", tostring(table.getn(self.plugin_containers)))
end

function PluginLoader:get_plugin_containers()
    return self.plugin_containers
end

function PluginLoader:get_planet_dependent_plugin_containers()
    return self.planet_dependent_plugin_containers
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
    local plugin_def = require(self.plugin_folder .. "/" .. plugin_name .. "/init")

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
    local container = {
        target = plugin_def.target,
        plugin = self.loaded_plugins[plugin_name]
    }

    if plugin_def.requires_planets then
        table.insert(self.planet_dependent_plugin_containers, container)
    else
        table.insert(self.plugin_containers, container)
    end

    unresolved_plugins[plugin_name] = nil
end
