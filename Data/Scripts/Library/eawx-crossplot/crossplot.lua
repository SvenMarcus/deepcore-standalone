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
--*   @Filename:            crossplot.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx-crossplot/GlobalValueEventBus")

crossplot = {
    __instance = nil,
    __important = true
}

function crossplot:master()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing MasterGlobalValueEventBus", tostring(Script))
    self.__instance = MasterGlobalValueEventBus()
end

function crossplot:galactic()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing GlobalValueEventBus", tostring(Script))
    self.__instance = GlobalValueEventBus()
end

function crossplot:tactical()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing GlobalValueEventBus", tostring(Script))
    self.__instance = GlobalValueEventBus("crossplot:tactical")
end

function crossplot:game_object()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing GlobalValueEventBus", tostring(Script))
    local name = tostring(Object)
    self.__instance = GlobalValueEventBus(name)
end

function crossplot:subscribe(event_name, listener_function, optional_self)
    self.__instance:subscribe(event_name, listener_function, optional_self)
end

function crossplot:publish(event_name, ...)
    self.__instance:publish(event_name, unpack(arg))
end

function crossplot:update()
    self.__instance:update()
end

return crossplot
