require("eawx/crossplot/crossplot")
require("eawx/std/PluginLoader")
require("eawx/galaxy/GalacticConquest")
deepcore = {}

function deepcore:galactic(config)
    local plugin_loader = PluginLoader(config.context, config.plugin_folder)
    crossplot:galactic()
    config.context.galactic_conquest = GalacticConquest(config.planet_factory)
    plugin_loader:load(config.plugins)

    return {
        planets = config.context.galactic_conquest.Planets,
        plugin_containers = plugin_loader:get_plugin_containers(),
        planet_dependent_plugin_containers = plugin_loader:get_planet_dependent_plugin_containers(),
        update = require("eawx/std/plugin_updatecycle").galactic_plugin_update_cycle
    }
end

function deepcore:game_object(config)
    local plugin_loader = PluginLoader(config.context, config.plugin_folder)
    crossplot:game_object()
    plugin_loader:load(config.plugins)

    return {
        plugin_containers = plugin_loader:get_plugin_containers(),
        planet_dependent_plugin_containers = plugin_loader:get_planet_dependent_plugin_containers(),
        update = require("eawx/std/plugin_updatecycle").generic_plugin_update_cycle
    }
end

function deepcore:gamescoring(config)
    local plugin_loader = PluginLoader(config.context, config.plugin_folder)
    crossplot:main()
    plugin_loader:load(config.plugins)

    return {
        plugin_containers = plugin_loader:get_plugin_containers(),
        planet_dependent_plugin_containers = plugin_loader:get_planet_dependent_plugin_containers(),
        update = require("eawx/std/plugin_updatecycle").generic_plugin_update_cycle
    }
end