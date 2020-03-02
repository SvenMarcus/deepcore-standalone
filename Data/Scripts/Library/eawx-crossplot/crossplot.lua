--**************************************************************************************************
--*    _______ __                                                                                  *
--*   |_     _|  |--.----.---.-.--.--.--.-----.-----.                                              *
--*     |   | |     |   _|  _  |  |  |  |     |__ --|                                              *
--*     |___| |__|__|__| |___._|________|__|__|_____|                                              *
--*    ______                                                                                      *
--*   |   __ \.-----.--.--.-----.-----.-----.-----.                                                *
--*   |      <|  -__|  |  |  -__|     |  _  |  -__|                                                *
--*   |___|__||_____|\___/|_____|__|__|___  |_____|                                                *
--*                                   |_____|                                                      *
--*                                                                                                *
--*                                                                                                *
--*       File:              crossplot.lua                                                         *
--*       File Created:      Friday, 21st February 2020 10:11                                      *
--*       Author:            [TR] Pox                                                              *
--*       Last Modified:     Saturday, 22nd February 2020 04:07                                    *
--*       Modified By:       [TR] Pox                                                              *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("eawx-crossplot/GlobalValueEventBus")

crossplot = {
    __instance = nil
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
