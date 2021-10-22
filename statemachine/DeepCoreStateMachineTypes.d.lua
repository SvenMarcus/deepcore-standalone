---@class DeepCoreStatePolicy
local DeepCoreStatePolicy = {}

---@param previous_state_context table<string, any>
---@return table<string, any>
function DeepCoreStatePolicy:on_enter(previous_state_context)
end

---@param state_context table<string, any>
function DeepCoreStatePolicy:on_update(state_context)
end

---@param state_context table<string, any>
function DeepCoreStatePolicy:on_exit(state_context)
end

---@class DeepCoreTransitionPolicy
local DeepCoreTransitionPolicy = {}

---@type fun() : nil
DeepCoreTransitionPolicy.transition_function = nil

---@param state_context table<string, any>
function DeepCoreTransitionPolicy:on_origin_entered(state_context)
end

---@param state_context table<string, any>
---@return boolean
function DeepCoreTransitionPolicy:should_transition(state_context)
end

---@param state_context table<string, any>
function DeepCoreTransitionPolicy:on_transition(state_context)
end