---@class dsl
---@field transition fun(origin: string): StateTransitionBuilder
---@field policy TransitionPolicyFactory
---@field effect TransitionEffectBuilderFactory
local dsl = {}