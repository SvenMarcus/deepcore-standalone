--******************************************************************************
--     _______ __
--    |_     _|  |--.----.---.-.--.--.--.-----.-----.
--      |   | |     |   _|  _  |  |  |  |     |__ --|
--      |___| |__|__|__| |___._|________|__|__|_____|
--     ______
--    |   __ \.-----.--.--.-----.-----.-----.-----.
--    |      <|  -__|  |  |  -__|     |  _  |  -__|
--    |___|__||_____|\___/|_____|__|__|___  |_____|
--                                    |_____|
--*   @Author:              [TR]Pox <Pox>
--*   @Date:                2018-01-13T12:58:03+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            Observable.lua
-- @Last modified by:
-- @Last modified time: 2018-01-24T00:54:23+01:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

require("eawx-std/class")

---@class Observable
Observable = class()

function Observable:new()
    self.Listeners = {}
end

---@param listenerFunction function
---@param optionalArg any
function Observable:AttachListener(listenerFunction, optionalArg)
    if not listenerFunction then
        return
    end
    self.Listeners[listenerFunction] = {Arg = optionalArg}
end

---@param listener function
function Observable:DetachListener(listener)
    self.Listeners[listener] = nil
end

function Observable:Notify(...)
    for listener, tab in pairs(self.Listeners) do
        if type(listener) == "function" then
            if tab.Arg then
                listener(tab.Arg, unpack(arg))
            else
                listener(unpack(arg))
            end
        end
    end
end
