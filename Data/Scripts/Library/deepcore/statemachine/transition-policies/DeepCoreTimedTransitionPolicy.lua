require("deepcore/std/class")

---@class DeepCoreTimedTransitionPolicy : DeepCoreTransitionPolicy
DeepCoreTimedTransitionPolicy = class()

---@param time_until_transition number
---@param transition_function fun(state_context: table<string, any>)
function DeepCoreTimedTransitionPolicy:new(time_until_transition, transition_function)
    ---@private
    self.time_until_transition = time_until_transition or 0

    ---@private
    ---@type number
    self.time_origin_entered = nil

    ---@public
    self.transition_function = transition_function or function()
        end
end

---@param state_context table<string, any>
function DeepCoreTimedTransitionPolicy:on_origin_entered(state_context)
    self.time_origin_entered = GetCurrentTime()
end

---@param state_context table<string, any>
function DeepCoreTimedTransitionPolicy:should_transition(state_context)
    return GetCurrentTime() >= self.time_origin_entered + self.time_until_transition
end

---@param state_context table<string, any>
function DeepCoreTimedTransitionPolicy:on_transition(state_context)
    self.transition_function(state_context)
end
