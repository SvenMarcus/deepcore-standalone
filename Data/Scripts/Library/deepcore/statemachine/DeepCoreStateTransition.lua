require("deepcore/std/class")

---@class DeepCoreStateTransition
DeepCoreStateTransition = class()

---@param origin DeepCoreState
---@param next DeepCoreState
---@param transition_policy DeepCoreTransitionPolicy
function DeepCoreStateTransition:new(origin, next, transition_policy)
    ---@private
    self.origin = origin
    self.origin.on_enter:attach_listener(self.on_origin_entered, self)
    table.insert(self.origin.transitions, self)

    ---@private
    self.next = next

    ---@private
    self.transition_policy = transition_policy

end

---@private
---@param state_context table<string, any>
function DeepCoreStateTransition:on_origin_entered(state_context)
    self.transition_policy:on_origin_entered(state_context)
end

---@param state_context table<string, any>
---@return boolean
function DeepCoreStateTransition:should_transition(state_context)
    return self.transition_policy:should_transition(state_context)
end

---@param state_context table<string, any>
function DeepCoreStateTransition:transition(state_context)
    self.transition_policy:on_transition(state_context)
end

---@return DeepCoreState
function DeepCoreStateTransition:get_next_state()
    return self.next
end
