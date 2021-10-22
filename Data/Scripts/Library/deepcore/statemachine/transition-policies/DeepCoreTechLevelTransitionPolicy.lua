require("deepcore/std/class")

---@class DeepCoreTechLevelTransitionPolicy : DeepCoreTransitionPolicy
DeepCoreTechLevelTransitionPolicy = class()

---@param target_level number
---@param faction PlayerObject
---@param transition_function fun(state_context: table<string, any>)
function DeepCoreTechLevelTransitionPolicy:new(target_level, faction, transition_function)
    ---@private
    self.target_level = target_level

    ---@private
    ---@type number
    self.level_on_enter = nil

    ---@private
    ---@type PlayerObject
    self.faction = faction

    ---@private
    self.transition_function = transition_function or function()
        end
end

---@param state_context table<string, any>
function DeepCoreTechLevelTransitionPolicy:on_origin_entered(state_context)
    self.level_on_enter = self.faction.Get_Tech_Level()
end

---@param state_context table<string, any>
function DeepCoreTechLevelTransitionPolicy:should_transition(state_context)
    return self.faction.Get_Tech_Level() == self.target_level
end

---@param state_context table<string, any>
function DeepCoreTechLevelTransitionPolicy:on_transition(state_context)
    self.transition_function(state_context)
end