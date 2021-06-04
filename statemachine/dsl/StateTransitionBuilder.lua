require("deepcore/std/class")
require("deepcore/std/callable")
require("deepcore/statemachine/DeepCoreStateTransition")

---@class StateTransitionBuilder
StateTransitionBuilder = class()

---@param origin_state DeepCoreState
function StateTransitionBuilder:new(origin_state)
    self.origin = origin_state

    ---@private
    ---@type DeepCoreState
    self.next = nil

    ---@type DeepCoreTransitionPolicy
    self.transition_policy = nil

    ---@type table<number, fun(): nil>
    self.effects = {}
end

---@param next_state DeepCoreState
function StateTransitionBuilder:to(next_state)
    self.next = next_state
    return self
end

---@param transition_policy DeepCoreTransitionPolicy
function StateTransitionBuilder:when(transition_policy)
    self.transition_policy = transition_policy
    return self
end

function StateTransitionBuilder:with_effects(...)
    for _, effect in ipairs(arg) do
        table.insert(self.effects, effect:build())
    end

    return self
end

function StateTransitionBuilder:end_()
    local composed_effects =
        callable {
        effects = self.effects,
        call = function(self)
            for _, effect in ipairs(self.effects) do
                effect()
            end
        end
    }

    self.transition_policy.transition_function = composed_effects
    return DeepCoreStateTransition(self.origin, self.next, self.transition_policy)
end


return StateTransitionBuilder