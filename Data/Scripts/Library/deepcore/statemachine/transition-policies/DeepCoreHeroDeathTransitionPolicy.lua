require("deepcore/std/class")

---@class DeepCoreHeroDeathTransitionPolicy : DeepCoreTransitionPolicy
DeepCoreHeroDeathTransitionPolicy = class()

---@param galactic_hero_killed_event GalacticHeroKilledEvent
---@param hero_type_name string
---@param transition_function fun(state_context: table<string, any>)
function DeepCoreHeroDeathTransitionPolicy:new(galactic_hero_killed_event, hero_type_name, transition_function)
    ---@private
    self.hero_type_name = string.upper(hero_type_name)

    ---@private
    self.transition_function = transition_function or function()
        end

    self.hero_killed = false

    ---@private
    self.galactic_hero_killed_event = galactic_hero_killed_event
    self.galactic_hero_killed_event:attach_listener(self.on_galactic_hero_killed, self)
end

---@param state_context table<string, any>
function DeepCoreHeroDeathTransitionPolicy:on_origin_entered(state_context)
end

---@param state_context table<string, any>
function DeepCoreHeroDeathTransitionPolicy:should_transition(state_context)
    return self.hero_killed
end

---@param state_context table<string, any>
function DeepCoreHeroDeathTransitionPolicy:on_transition(state_context)
    self.transition_function(state_context)
end

---@param hero_type_name string
---@param owner PlayerObject
function DeepCoreHeroDeathTransitionPolicy:on_galactic_hero_killed(hero_type_name, owner)
    if hero_type_name ~= self.hero_type_name then
        return
    end
    self.hero_killed = true
    self.galactic_hero_killed_event:detach_listener(self.on_galactic_hero_killed, self)
end