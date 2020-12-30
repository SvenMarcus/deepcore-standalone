-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/Library/PGBase.lua#2 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
--
--
--  *****           **                          *                   *
--  *   **          *                           *                   *
--  *    *          *                           *                   *
--  *    *          *     *                 *   *          *        *
--  *   *     *** ******  * **  ****      ***   * *      * *****    * ***
--  *  **    *  *   *     **   *   **   **  *   *  *    * **   **   **   *
--  ***     *****   *     *   *     *  *    *   *  *   **  *    *   *    *
--  *       *       *     *   *     *  *    *   *   *  *   *    *   *    *
--  *       *       *     *   *     *  *    *   *   * **   *   *    *    *
--  *       **       *    *   **   *   **   *   *    **    *  *     *   *
-- **        ****     **  *    ****     *****   *    **    ***      *   *
--                                          *        *     *
--                                          *        *     *
--                                          *       *      *
--                                      *  *        *      *
--                                      ****       *       *
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/Library/PGBase.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 45244 $
--
--          $DateTime: 2006/05/26 10:01:00 $
--
--          $Revision: #2 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGDebug")

YieldCount = 0

---Exits the script
function ScriptExit()
    _ScriptExit() -- set a flag in 'C' to terminate the whole script on next yield

    if GetThreadID() >= 0 then
        coroutine.yield(false) -- return false to exit this thread
    end
end

---Pauses the current thread for the given amount of time
---@param time int The sleep time
function Sleep(time)
    --DebugMessage("Sleeping...  SleepTime: %.3f, CurTime: %.3f\n", time, GetCurrentTime())
    ThreadValue.Set("StartTime", GetCurrentTime())
    while GetCurrentTime() - ThreadValue("StartTime") < time do
        PumpEvents()
    end
    --DebugMessage("Done with Sleep.  Continuing, CurTime: %.3f\n", GetCurrentTime())
end

---Service the block until optional max duration has expired or alternate break function returns true. Pass -1 max_duration to use optional alternate break function with no time limit
---@param block any The block to execute
---@param max_duration int Maximum duration the block gets executed in seconds
---@param alternate_break_func function An alternative break function that gets called if the max_duration is -1. Must return true when BlockOnCommand is supposed to stop
---@return any
function BlockOnCommand(block, max_duration, alternate_break_func)
    PumpEvents()

    if not block then
        return nil
    end

    break_block = false

    ThreadValue.Set("BlockStart", GetCurrentTime())

    repeat
        if break_block == true then
            break_block = false
            return nil
        end

        PumpEvents()

        if
            ((max_duration ~= nil) and (max_duration ~= -1) and
                (GetCurrentTime() - ThreadValue("BlockStart") > max_duration))
         then
            DebugMessage("%s -- Had a time limit and it expired", tostring(Script))
            return nil
        end

        if ((alternate_break_func ~= nil) and alternate_break_func()) then
            DebugMessage("%s-- had a break func and it returned true", tostring(Script))
            return nil
        end
    until (block.IsFinished() == true)

    PumpEvents()

    return block.Result()
end

function BreakBlock()
    break_block = true
end

function TestCommand(block)
    if not block then
        return nil
    end

    PumpEvents()

    return block.IsFinished()
end

function PumpEvents()
    if Object and type(Object) == "userdata" then
        Object.Service_Wrapper()
    end

    if Pump_Service and type(Pump_Service) == "function" then
        Pump_Service()
    end

    if ThreadValue("InPumpEvents") then
        ScriptError("%s -- Already in pump event!!", tostring(Script))
    end

    ThreadValue.Set("InPumpEvents", true)

    --DebugMessage("%s -- Entering yield.  Count: %d, Time: %.3f\n", tostring(Script), YieldCount, GetCurrentTime())
    YieldCount = YieldCount + 1
    coroutine.yield(true) -- yield here and return to 'C'
    --DebugMessage("%s -- Return from yield.  Count: %d, Time: %.3f\n", tostring(Script), YieldCount, GetCurrentTime())

    CurrentEvent = GetEvent()
    while CurrentEvent do
        ScriptMessage("%s -- Pumping Event: %s.", tostring(Script), tostring(CurrentEvent))
        EventParams = GetEvent.Params()
        if EventParams then
            CurrentEvent(unpack(EventParams))
        else
            CurrentEvent()
        end

        if Script.Debug_Should_Issue_Event_Alert() and DebugEventAlert then
            DebugEventAlert(CurrentEvent, EventParams)
        end

        CurrentEvent = GetEvent()
    end
    ThreadValue.Set("InPumpEvents", false)
end

---Returns true if the argument is a valid GameObject. Can be used to check if an object is alive
---@param wrapper any
---@return boolean
function TestValid(wrapper)
    if wrapper == nil then
        return false
    end

    if wrapper.Is_Valid == nil then
        return false
    end

    return wrapper.Is_Valid()
end

function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

-- Nasty hack of a floor function to be replaced if a math library floor funciton is exposed
function Dirty_Floor(val)
    return string.format("%d", val) -- works on implicit string to int conversion
end

-- Machine independent modulus function
function Simple_Mod(a, b)
    --return a-b*math.floor(a/b)
    return a - b * Dirty_Floor(a / b)
end

-- Returns if something happened, given a % chance
function Chance(seed, percent)
    roll = Simple_Mod((seed + 1), 100)
    is_allowed = roll < percent
    DebugMessage(
        "%s -- seed:%d percent:%d roll:%d is_allowed:%s",
        tostring(Script),
        seed,
        percent,
        roll,
        tostring(is_allowed)
    )
    return is_allowed
end

function GetCurrentMinute()
    --return math.floor(GetCurrentTime()/60)
    return Dirty_Floor(GetCurrentTime() / 60)
end

-- Every X seconds, the AI will have a new opportunity to see if it's allowed to use an ability
function GetAbilityChanceSeed()
    return GetCurrentTime()
end

function GetChanceAllowed(difficulty)
    --Possibly change these back, but randomness makes things hard to test
    chance = 100
    if difficulty == "Easy" then
        chance = 100
    elseif difficulty == "Hard" then
        chance = 100
    end
    return chance
end

function PlayerSpecificName(player_object, var_name)
    --	ret_value = tostring(player_object.Get_ID()) .. "_" .. var_name
    --	DebugMessage("%s -- creating player specific string %s.", tostring(Script), ret_value)
    --	return ret_value
    return (tostring("PLAYER" .. player_object.Get_ID()) .. "_" .. var_name)
end

function Flush_G()
    DebugMessage("PGBase -- Starting Flush_G")
    entries_for_deletion = {}

    --Define the set of tables that we had better keep around
    very_important_tables = {
        _LOADED,
        coroutine,
        string,
        LuaWrapperMetaTable,
        _G,
        security,
        table,
        entries_for_deletion
    }

    --Silly thing is nil (we think) if we try to add it earlier
    table.insert(very_important_tables, very_important_tables)

    --Iterate all globals
    for i, g_entry in pairs(_G) do
        if type(g_entry) == "table" then
            --Tables are inherently unsafe: who knows what might be in there?
            --If they're not in the list of things we must keep then they go.

            for j, important_entry in pairs(very_important_tables) do
                if important_entry == g_entry then
                    keep_table = true
                end
            end

            -- if g_entry.__important then
            --     DebugMessage("Keeping important table %s", tostring(i))
            --     keep_table = true
            -- end

            if not keep_table then
                DebugMessage("Removing table %s", tostring(i))
                table.insert(entries_for_deletion, i)
            end

            keep_table = nil
        elseif type(g_entry) == "userdata" then
            --Some User Data (e.g. our code functions) should be kept, but some is very, very dangerous.
            --Query the object to see whether it's safe to persist.

            if not g_entry.Is_Pool_Safe() then
                table.insert(entries_for_deletion, i)
            end
        end
    end

    for i, bad_entry in pairs(entries_for_deletion) do
        _G[bad_entry] = nil
    end

    _LOADED = {}

    entries_for_deletion = nil
    very_important_tables = nil
end
