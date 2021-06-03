return {
    target = function()
        return false
    end,
    dependencies = {"plugin-stub"},
    init = function(self, ctx, plugin_stub)
        return {
            received_dependency = plugin_stub
        }
    end
}