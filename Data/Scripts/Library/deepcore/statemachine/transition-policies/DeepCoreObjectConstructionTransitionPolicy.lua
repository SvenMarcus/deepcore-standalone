require("deepcore/std/class")

---@class DeepCoreObjectConstructionTransitionPolicy : DeepCoreTransitionPolicy
DeepCoreObjectConstructionTransitionPolicy = class()

---@param production_finished_event ProductionFinishedEvent
---@param object_type_name string
---@param transition_function fun(state_context: table<string, any>)
function DeepCoreObjectConstructionTransitionPolicy:new(production_finished_event, object_type_name, transition_function)
    ---@private
    self.object_type_name = string.upper(object_type_name)

    ---@private
    self.transition_function = transition_function or function()
        end

    ---@private
    self.object_constructed = false

    ---@private
    self.production_finished_event = production_finished_event
    self.production_finished_event:attach_listener(self.on_production_finished, self)
end

---@param state_context table<string, any>
function DeepCoreObjectConstructionTransitionPolicy:on_origin_entered(state_context)
end

---@param state_context table<string, any>
function DeepCoreObjectConstructionTransitionPolicy:should_transition(state_context)
    return self.object_constructed
end

---@param state_context table<string, any>
function DeepCoreObjectConstructionTransitionPolicy:on_transition(state_context)
    self.transition_function(state_context)
end

---@param planet Planet
---@param object_type_name string
function DeepCoreObjectConstructionTransitionPolicy:on_production_finished(planet, object_type_name)
    if object_type_name ~= self.object_type_name then
        return
    end
    self.object_constructed = true
    self.production_finished_event:detach_listener(self.on_production_finished)
end
