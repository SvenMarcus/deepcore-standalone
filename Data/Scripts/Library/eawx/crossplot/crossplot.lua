-- *****************************************************************************
-- *    _______ __
-- *   |_     _|  |--.----.---.-.--.--.--.-----.-----.
-- *     |   | |     |   _|  _  |  |  |  |     |__ --|
-- *     |___| |__|__|__| |___._|________|__|__|_____|
-- *    ______
-- *   |   __ \.-----.--.--.-----.-----.-----.-----.
-- *   |      <|  -__|  |  |  -__|     |  _  |  -__|
-- *   |___|__||_____|\___/|_____|__|__|___  |_____|
-- *                                   |_____|
-- *
-- *   @Author:              [EaWX]Pox
-- *   @Date:                2020-12-23
-- *   @Project:             Empire at War Expanded
-- *   @Filename:            crossplot.lua
-- *   @License:             MIT
-- *****************************************************************************
require("eawx/crossplot/GlobalValueEventBus")

---A module that allows publish-subscribe communication between different Lua script environments
crossplot = {__instance = nil, __important = true}

---Initialize the main crossplot instance. Use only in GameScoring.
function crossplot:master()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing MasterGlobalValueEventBus",
                 tostring(Script))
    self.__instance = MasterGlobalValueEventBus()
end

---Initialize crossplot for the galactic plot
function crossplot:galactic()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing GlobalValueEventBus", tostring(Script))
    self.__instance = GlobalValueEventBus()
end

---Initialize crossplot on a tactical plot
function crossplot:tactical()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing GlobalValueEventBus", tostring(Script))
    self.__instance = GlobalValueEventBus("crossplot:tactical")
end

---Initialize crossplot for on a script attached to a game object
function crossplot:game_object()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing GlobalValueEventBus", tostring(Script))
    local name = tostring(Object)
    self.__instance = GlobalValueEventBus(name)
end

---Subscribe to a crossplot event
---@param event_name string
---@param listener_function function
---@param optional_self table
function crossplot:subscribe(event_name, listener_function, optional_self)
    self.__instance:subscribe(event_name, listener_function, optional_self)
end

---Unsubscribe from a crossplot event
---@param event_name string
---@param listener_function function
---@param optional_self table
function crossplot:unsubscribe(event_name, listener_function, optional_self)
    self.__instance:unsubscribe(event_name, listener_function, optional_self)
end

function crossplot:publish(event_name, ...)
    self.__instance:publish(event_name, unpack(arg))
end

function crossplot:update() self.__instance:update() end

return crossplot
