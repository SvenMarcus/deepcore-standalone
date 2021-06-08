require("deepcore/crossplot/crossplot")
require("deepcore/std/PluginLoader")
require("deepcore/std/callable")
require("deepcore/galaxy/GalacticConquest")

deepcore = {}

function deepcore:galactic(config)
    if not config.plugin_folder then
        error("Missing mandatory setting plugin_folder")
    end

    local context = config.context or {}
    local plugin_loader = PluginLoader(context, config.plugin_folder)
    crossplot:galactic()
    context.galactic_conquest = GalacticConquest(config.planet_factory)
    plugin_loader:load(config.plugins)

    return {
        planets = context.galactic_conquest.Planets,
        plugin_containers = plugin_loader:get_plugin_containers(),
        planet_dependent_plugin_containers = plugin_loader:get_planet_dependent_plugin_containers(),
        plugin_updatecycle = require("deepcore/std/plugin_updatecycle").galactic_plugin_update_cycle,
        update = function(self)
            crossplot:update()
            self:plugin_updatecycle()
        end
    }
end

function deepcore:game_object(config)
    if not config.plugin_folder then
        error("Missing mandatory setting plugin_folder")
    end

    local plugin_loader = PluginLoader(config.context, config.plugin_folder)
    crossplot:game_object()
    plugin_loader:load(config.plugins)

    return {
        plugin_containers = plugin_loader:get_plugin_containers(),
        plugin_updatecycle = require("deepcore/std/plugin_updatecycle").generic_plugin_update_cycle,
        update = function(self)
            crossplot:update()
            self:plugin_updatecycle()
        end
    }
end

function deepcore:gamescoring(config)
    if not config.plugin_folder then
        error("Missing mandatory setting plugin_folder")
    end

    local plugin_loader = PluginLoader(config.context, config.plugin_folder)
    crossplot:main()
    plugin_loader:load(config.plugins)

    return {
        plugin_containers = plugin_loader:get_plugin_containers(),
        plugin_updatecycle = require("deepcore/std/plugin_updatecycle").generic_plugin_update_cycle,
        update = function(self)
            crossplot:update()
            self:plugin_updatecycle()
        end
    }
end

return deepcore