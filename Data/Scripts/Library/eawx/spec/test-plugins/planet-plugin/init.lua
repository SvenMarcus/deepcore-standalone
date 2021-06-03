return {
    target = function()
        return false
    end,
    requires_planets = true,
    init = function(self, ctx)
        return {
            plugin_info = "PLANET_PLUGIN",
            update = function(self)
                table.insert(self.context.updated_plugins, "planet-plugin")
            end
        }
    end
}