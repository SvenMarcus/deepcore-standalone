return {
    target = function()
        return false
    end,
    requires_planets = true,
    init = function(self, ctx)
        return {
            plugin_info = "PLANET_PLUGIN"
        }
    end
}