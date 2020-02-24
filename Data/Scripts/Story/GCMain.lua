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
        -- We need a list of playable factions for the GalacticConquest
        -- object instantiated in EawXMod
        local playable_factions = {
            "EMPIRE",
            "REBEL",
            "UNDERWORLD"
        }

        -- The context table allows you to pass variables to
        -- the init() function of your plugins
        local context = {}

        ActiveMod = EawXMod(playable_factions, context)
    elseif message == OnUpdate then
        ActiveMod:update()
    end
end
