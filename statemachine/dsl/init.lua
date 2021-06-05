require("deepcore/statemachine/dsl/StateTransitionBuilder")
require("deepcore/statemachine/dsl/TransitionEffectBuilderFactory")
require("deepcore/statemachine/dsl/TransitionPolicyFactory")

return function(plugin_ctx)
    return {
        transition = StateTransitionBuilder,
        conditions = require("deepcore/statemachine/dsl/conditions"),
        effect = TransitionEffectBuilderFactory(plugin_ctx),
        policy = TransitionPolicyFactory(plugin_ctx)
    }
end