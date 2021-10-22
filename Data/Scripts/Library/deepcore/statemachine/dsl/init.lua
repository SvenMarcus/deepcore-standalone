require("deepcore/statemachine/dsl/StateTransitionBuilder")
require("deepcore/statemachine/dsl/TransitionEffectBuilderFactory")
require("deepcore/statemachine/dsl/TransitionPolicyFactory")

return function(plugin_ctx)
    local dsl = {
        transition = StateTransitionBuilder,
        conditions = require("deepcore/statemachine/dsl/conditions"),
        effect = TransitionEffectBuilderFactory(plugin_ctx),
        policy = TransitionPolicyFactory(plugin_ctx)
    }

    if not plugin_ctx.statemachine_dsl_config then
        return dsl
    end

    local dsl_config = plugin_ctx.statemachine_dsl_config

    if dsl_config.transition_effect_builder_factory then
        dsl.effect = dsl_config.transition_effect_builder_factory(plugin_ctx)
    end

    if dsl_config.transition_policy_factory then
        dsl.policy = dsl_config.transition_policy_factory(plugin_ctx)
    end

    return dsl
end