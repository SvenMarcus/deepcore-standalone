require("deepcore/std/class")
require("deepcore/statemachine/dsl/transition-effect-builders/PlanetTransferBuilder")
require("deepcore/statemachine/dsl/transition-effect-builders/SetTechLevelBuilder")
require("deepcore/statemachine/dsl/transition-effect-builders/SpawnHeroBuilder")

---@class TransitionEffectBuilderFactory
TransitionEffectBuilderFactory = class()

function TransitionEffectBuilderFactory:new(plugin_ctx)
    self.ctx = plugin_ctx
end

---@vararg string
function TransitionEffectBuilderFactory:transfer_planets(...)
    return PlanetTransferBuilder(unpack(arg))
end

function TransitionEffectBuilderFactory:set_tech_level(level)
    return SetTechLevelBuilder(level)
end

function TransitionEffectBuilderFactory:spawn_hero(hero)
    return SpawnHeroBuilder(hero)
end

return TransitionEffectBuilderFactory