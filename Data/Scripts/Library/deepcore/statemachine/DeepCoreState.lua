require("deepcore/std/class")
require("deepcore/std/Observable")

---@class DeepCoreState
DeepCoreState = class()

function DeepCoreState.with_empty_policy()
    return DeepCoreState {
        on_enter = function(self, state_context)
        end,
        on_update = function(self, state_context)
        end,
        on_exit = function(self, state_context)
        end
    }
end

---@param state_policy DeepCoreStatePolicy
function DeepCoreState:new(state_policy)
    ---@private
    ---@type table<string, any>
    self.state_context = {}

    ---@private
    ---@type DeepCoreStatePolicy
    self.state_policy = state_policy or {}

    self:add_missing_methods(self.state_policy)

    ---@public
    ---@type table<number, DeepCoreStateTransition>
    self.transitions = {}

    ---@public
    self.on_enter = Observable()

    ---@public
    self.on_exit = Observable()
end

---@private
function DeepCoreState:add_missing_methods(state_policy)
    if not state_policy.on_enter then
        state_policy.on_enter = function()
        end
    end

    if not state_policy.on_update then
        state_policy.on_update = function()
        end
    end

    if not state_policy.on_exit then
        state_policy.on_exit = function()
        end
    end
end

---@param previous_state_context table<string, any>
function DeepCoreState:initialise(previous_state_context)
    self.state_context = self.state_policy:on_enter(previous_state_context) or {}
    self.on_enter:notify(self.state_context)
end

function DeepCoreState:update()
    self.state_policy:on_update(self.state_context)
    self:try_transition_to_next_state()
end

function DeepCoreState:try_transition_to_next_state()
    ---@param transition DeepCoreStateTransition
    for i, transition in ipairs(self.transitions) do
        if transition:should_transition(self.state_context) then
            transition:transition(self.state_context)
            self.state_policy.on_exit(self.state_context)
            self.on_exit:notify(transition:get_next_state(), self.state_context)
            return
        end
    end
end
