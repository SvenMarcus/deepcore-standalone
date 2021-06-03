--*****************************************************************************
--*    _______ __
--*   |_     _|  |--.----.---.-.--.--.--.-----.-----.
--*     |   | |     |   _|  _  |  |  |  |     |__ --|
--*     |___| |__|__|__| |___._|________|__|__|_____|
--*    ______
--*   |   __ \.-----.--.--.-----.-----.-----.-----.
--*   |      <|  -__|  |  |  -__|     |  _  |  -__|
--*   |___|__||_____|\___/|_____|__|__|___  |_____|
--*                                   |_____|
--*
--*   @Author:              [EaWX]Pox
--*   @Date:                2020-12-23
--*   @Project:             Empire at War Expanded
--*   @Filename:            GCMain.lua
--*   @License:             MIT
--*****************************************************************************

require("PGDebug")
require("PGStateMachine")
require("PGStoryMode")

require("eawx/std/deepcore")

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

        DeepCoreRunner = deepcore:galactic {
            context = context,
            plugin_folder = "eawx-plugins/galactic"
        }
    elseif message == OnUpdate then
        DeepCoreRunner:update()
    end
end
