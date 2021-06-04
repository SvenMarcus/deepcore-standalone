require("deepcore/std/class")
require("deepcore/statemachine/transition-policies/DeepCoreTimedTransitionPolicy")
require("deepcore/statemachine/transition-policies/DeepCoreEraCheckTransitionPolicy")
require("deepcore/statemachine/transition-policies/DeepCoreGlobalEraCheckTransitionPolicy")
require("deepcore/statemachine/transition-policies/DeepCoreHeroDeathTransitionPolicy")
require("deepcore/statemachine/transition-policies/DeepCorePlanetLostTransitionPolicy")
require("deepcore/statemachine/transition-policies/DeepCoreObjectConstructionTransitionPolicy")

---@class TransitionPolicyFactory
TransitionPolicyFactory = class()

function TransitionPolicyFactory:new(plugin_ctx)
    self.ctx = plugin_ctx
end

---@param time number
function TransitionPolicyFactory:timed(time)
    return DeepCoreTimedTransitionPolicy(time)
end

---@param current_tech number
function TransitionPolicyFactory:tech_level(current_tech)
    return DeepCoreEraCheckTransitionPolicy(current_tech)
end
---@param current_tech number
function TransitionPolicyFactory:global_era(current_tech)
    return DeepCoreGlobalEraCheckTransitionPolicy(current_tech)
end

---@param hero_type_name string
function TransitionPolicyFactory:hero_dies(hero_type_name)
    ---@type GalacticConquest
    local gc = self.ctx.galactic_conquest
    return DeepCoreHeroDeathTransitionPolicy(gc.Events.GalacticHeroKilled, hero_type_name)
end

---@param planet_name string
function TransitionPolicyFactory:planet_lost(planet_name)
    ---@type GalacticConquest
    local gc = self.ctx.galactic_conquest
    return DeepCorePlanetLostTransitionPolicy(gc.Events.PlanetOwnerChanged, planet_name)
end


---@param object_type_name string
function TransitionPolicyFactory:object_constructed(object_type_name)
    ---@type GalacticConquest
    local gc = self.ctx.galactic_conquest
    return DeepCoreObjectConstructionTransitionPolicy(gc.Events.GalacticProductionFinished, object_type_name)
end


return TransitionPolicyFactory
