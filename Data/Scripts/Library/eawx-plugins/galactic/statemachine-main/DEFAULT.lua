require("deepcore/statemachine/DeepCoreState")

---@param dsl dsl
return function(dsl)
    local policy = dsl.policy
    local effect = dsl.effect
    local owned_by = dsl.conditions.owned_by

    local initialize = DeepCoreState.with_empty_policy()
    local setup = DeepCoreState.with_empty_policy()

    dsl.transition(initialize)
    :to(setup)
    :when(policy:planet_lost("Anaxes", "Empire", "Rebel"))
    :end_()
    return initialize
end
