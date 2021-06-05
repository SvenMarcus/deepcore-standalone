require("deepcore/std/class")

---@class DeepCorePlanetLostTransitionPolicy : DeepCoreTransitionPolicy
DeepCorePlanetLostTransitionPolicy = class()

---@param planet_owner_changed_event PlanetOwnerChanged
---@param planet_name string
---@param original_owner_name string
---@param new_owner_name string
---@param transition_function fun(state_context: table<string, any>)
function DeepCorePlanetLostTransitionPolicy:new(planet_owner_changed_event, planet_name, new_owner_name, original_owner_name, transition_function)
    ---@private
    self.planet_name = string.upper(planet_name)

    ---@private
    self.original_owner_name = string.upper(original_owner_name) or nil

    ---@private
    self.new_owner_name = string.upper(new_owner_name) or nil

    ---@private
    self.transition_function = transition_function or function()
        end

    self.planet_lost = false

    ---@private
    self.planet_owner_changed_event = planet_owner_changed_event
    self.planet_owner_changed_event:attach_listener(self.on_planet_owner_changed, self)
end

---@param state_context table<string, any>
function DeepCorePlanetLostTransitionPolicy:on_origin_entered(state_context)
end

---@param state_context table<string, any>
function DeepCorePlanetLostTransitionPolicy:should_transition(state_context)
    return self.planet_lost
end

---@param state_context table<string, any>
function DeepCorePlanetLostTransitionPolicy:on_transition(state_context)
    self.transition_function(state_context)
end

---@param planet Planet
function DeepCorePlanetLostTransitionPolicy:on_planet_owner_changed(planet, new_owner_name, old_owner_name)
    if (planet:get_name() ~= self.planet_name) then
        return
    end
    if (self.original_owner_name ~= nil) and (self.original_owner_name ~= old_owner_name) then
        return
    end
    if (self.new_owner_name ~= nil) and (self.new_owner_name ~= new_owner_name) then
        return
    end

    self.planet_lost = true
    self.planet_owner_changed_event:detach_listener(self.on_planet_owner_changed, self)
end