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

require("eawx/std/class")

---@class Observable
Observable = class()

function Observable:new()
    ---@private
    self.Listeners = {}
end

---@param listener_function function
---@param optional_context any
function Observable:attach_listener(listener_function, optional_context)
    if not listener_function then
        return
    end

    table.insert(self.Listeners, {Listener = listener_function, Arg = optional_context})
end

---@param listener function
---@param optional_context any
function Observable:detach_listener(listener, optional_context)
    for index, tab in ipairs(self.Listeners) do
        if tab.Listener == listener and tab.Arg == optional_context then
            table.remove(self.Listeners, index)
            return
        end
    end
end

function Observable:notify(...)
    for _, tab in ipairs(self.Listeners) do
        local listener = tab.Listener
        if tab.Arg then
            listener(tab.Arg, unpack(arg))
        else
            listener(unpack(arg))
        end
    end
end
