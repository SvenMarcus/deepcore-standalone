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
--*   @Date:                2020-12-30
--*   @Project:             Empire at War Expanded
--*   @Filename:            MicrojumpObject.lua
--*   @License:             MIT
--*****************************************************************************

require("PGCommands")
require("PGStateMachine")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    
    Define_State("State_Init", State_Init)
end

function State_Init(message)
    if message == OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end

        require("deepcore/std/deepcore")
        DeepCoreRunner = deepcore:game_object {
            context = {},
            plugin_folder = "eawx-plugins/gameobject/space",
            plugins = { "microjump" }
        }
    elseif message == OnUpdate then
        DeepCoreRunner:update()
    end
end