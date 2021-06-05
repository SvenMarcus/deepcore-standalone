require("deepcore/std/class")

---@class DeepCoreStateMachine
DeepCoreStateMachine = class()

---@param script_name string
---@param ctx table
---@return DeepCoreStateMachine
function DeepCoreStateMachine.from_script(script_name, dsl, ctx)
    local state_factory = require(script_name)
    local initial_state = state_factory(dsl, ctx)
    return DeepCoreStateMachine(initial_state)
end

---@param initial_state DeepCoreState
---@param initial_context table<string, any> | nil
function DeepCoreStateMachine:new(initial_state, initial_context)
    ---@private
    ---@type DeepCoreState
    self.active_state = initial_state
    self.active_state.on_exit:attach_listener(self.on_state_exit, self)
    self.active_state:initialise(initial_context or {})
end

function DeepCoreStateMachine:update()
    if not self.active_state then
        return
    end

    self.active_state:update()
end

---@private
---@param new_state DeepCoreState
function DeepCoreStateMachine:on_state_exit(new_state, state_context)
    self.active_state.on_exit:detach_listener(self.on_state_exit, self)
    self.active_state = new_state

    if not new_state then
        return
    end

    self.active_state.on_exit:attach_listener(self.on_state_exit, self)
    self.active_state:initialise(state_context)
end
