local function allowed_to_update(target_cache, container)
    local can_update = target_cache[container.target]
    if target_cache[container.target] == nil then
        can_update = container.target()
        target_cache[container.target] = can_update
    end

    return can_update
end

local generic_plugin_update_cycle = setmetatable({
    allowed_to_update = allowed_to_update
}, {
    __call = function (t, ...)
        return t.call(t, unpack(arg))
    end
})

function generic_plugin_update_cycle.call(self, context, target_cache)
    target_cache = target_cache or {}
    for _, container in ipairs(context.plugin_containers) do
        local can_update = self.allowed_to_update(target_cache, container)

        if can_update then
            container.plugin:update()
        end
    end
end

local galactic_plugin_update_cycle = setmetatable({
    generic_plugin_update_cycle = generic_plugin_update_cycle,
    allowed_to_update = allowed_to_update
}, {
    __call = function (t, ...)
        return t.call(t, unpack(arg))
    end
})

function galactic_plugin_update_cycle.call(self, context)
    local target_cache = {}
    self.generic_plugin_update_cycle(context, target_cache)

    for _, planet in pairs(context.planets) do
        for _, container in ipairs(context.planet_dependent_plugin_containers) do
            local can_update = allowed_to_update(target_cache, container)

            if can_update then
                container.plugin:update(planet)
            end
        end
    end
end

return {
    generic_plugin_update_cycle = generic_plugin_update_cycle,
    galactic_plugin_update_cycle = galactic_plugin_update_cycle
}