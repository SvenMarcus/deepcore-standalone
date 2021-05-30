return {
    target = function() 
        return "THE_TARGET"
    end,
    init = function(self, ctx)
        return {
            plugin_info = "PLUGIN_STUB",
            context = ctx,
            update = function(self)
                table.insert(self.context.updated_plugins, "plugin-stub")
            end
        }
    end
}