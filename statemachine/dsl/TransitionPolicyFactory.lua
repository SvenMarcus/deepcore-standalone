require("deepcore/std/class")
require("deepcore/statemachine/transition-policies/DeepCoreTimedTransitionPolicy")
require("deepcore/statemachine/transition-policies/DeepCoreTechLevelTransitionPolicy")
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

---@param target_tech_level number
---@param faction string
function TransitionPolicyFactory:tech_level(target_tech_level, faction)
    return DeepCoreTechLevelTransitionPolicy(target_tech_level, Find_Player(faction))
end

---@param hero_type_name string
function TransitionPolicyFactory:hero_dies(hero_type_name)
    ---@type GalacticConquest
    local gc = self.ctx.galactic_conquest
    return DeepCoreHeroDeathTransitionPolicy(gc.Events.GalacticHeroKilled, hero_type_name)
end

---@param planet_name string
function TransitionPolicyFactory:planet_owner_changes(planet_name, new_owner_name, original_owner_name)
    ---@type GalacticConquest
    local gc = self.ctx.galactic_conquest
    return DeepCorePlanetOwnerChangedTransitionPolicy(gc.Events.PlanetOwnerChanged, planet_name, new_owner_name, original_owner_name)
end

---@param object_type_name string
function TransitionPolicyFactory:object_constructed(object_type_name)
    ---@type GalacticConquest
    local gc = self.ctx.galactic_conquest
    return DeepCoreObjectConstructionTransitionPolicy(gc.Events.GalacticProductionFinished, object_type_name)
end


return TransitionPolicyFactory
