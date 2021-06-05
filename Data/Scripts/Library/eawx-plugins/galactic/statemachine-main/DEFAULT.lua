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
    :when(policy:planet_owner_changes("Anaxes", "Empire", "Rebel"))
    :with_effects(
        effect:transfer_planets("Coruscant")
            :to_owner("Rebel")
            :if_(owned_by("Empire"))
    )
    :end_()
    return initialize
end
