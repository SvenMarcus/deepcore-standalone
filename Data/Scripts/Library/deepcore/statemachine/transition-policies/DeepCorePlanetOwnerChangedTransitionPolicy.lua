require("deepcore/std/class")

---@class DeepCorePlanetOwnerChangedTransitionPolicy : DeepCoreTransitionPolicy
DeepCorePlanetOwnerChangedTransitionPolicy = class()

---@param planet_owner_changed_event PlanetOwnerChangedEvent
---@param planet_name string
---@param original_owner_name string
---@param new_owner_name string
---@param transition_function fun(state_context: table<string, any>)
function DeepCorePlanetOwnerChangedTransitionPolicy:new(planet_owner_changed_event, planet_name, new_owner_name, original_owner_name, transition_function)
    ---@private
    self.planet_name = string.upper(planet_name)

    ---@private
    self.original_owner_name = self:upper_or_nil(original_owner_name)

    ---@private
    self.new_owner_name = self:upper_or_nil(new_owner_name)

    ---@private
    self.transition_function = transition_function or function()
        end

    self.owner_changed = false

    ---@private
    self.planet_owner_changed_event = planet_owner_changed_event
    self.planet_owner_changed_event:attach_listener(self.on_planet_owner_changed, self)
end

---@private
---@param str string
---@return string?
function DeepCorePlanetOwnerChangedTransitionPolicy:upper_or_nil(str)
    if not str then
        return nil
    end

    return string.upper(str)
end

---@param state_context table<string, any>
function DeepCorePlanetOwnerChangedTransitionPolicy:on_origin_entered(state_context)
end

---@param state_context table<string, any>
function DeepCorePlanetOwnerChangedTransitionPolicy:should_transition(state_context)
    return self.owner_changed
end

---@param state_context table<string, any>
function DeepCorePlanetOwnerChangedTransitionPolicy:on_transition(state_context)
    self.transition_function(state_context)
end

---@param planet Planet
function DeepCorePlanetOwnerChangedTransitionPolicy:on_planet_owner_changed(planet, new_owner_name, old_owner_name)
    if planet:get_name() ~= self.planet_name then
        return
    end

    if (self.original_owner_name ~= nil) and (self.original_owner_name ~= old_owner_name) then
        return
    end

    if (self.new_owner_name ~= nil) and (self.new_owner_name ~= new_owner_name) then
        return
    end

    self.owner_changed = true
    self.planet_owner_changed_event:detach_listener(self.on_planet_owner_changed, self)
end