return {
    target = function()
        return true
    end,
    requires_planets = true,
    init = function(self, ctx)
        return {
            context = ctx,
            plugin_info = "ACTIVE_PLANET_PLUGIN",
            update = function(self)
                table.insert(self.context.updated_plugins, "active-planet-plugin")
            end
        }
    end
}