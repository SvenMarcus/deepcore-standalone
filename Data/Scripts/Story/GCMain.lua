require("PGDebug")
require("PGStateMachine")
require("PGStoryMode")

require("eawx-std/EawXMod")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.1

    StoryModeEvents = {Universal_Story_Start = Begin_GC}
end

function Begin_GC(message)
    if message == OnEnter then
        -- The context table allows you to pass variables to
        -- the init() function of your plugins
        local context = {}

        ActiveMod = EawXMod(context)
    elseif message == OnUpdate then
        ActiveMod:update()
    end
end
