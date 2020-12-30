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
--*   @Filename:            Observable.lua
--*   @License:             MIT
--*****************************************************************************

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
