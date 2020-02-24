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
--*       File:              GlobalValueQueue.lua                                                  *
--*       File Created:      Friday, 21st February 2020 10:56                                      *
--*       Author:            [TR] Pox                                                              *
--*       Last Modified:     Friday, 21st February 2020 10:56                                      *
--*       Modified By:       [TR] Pox                                                              *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("eawx-std/class")
require("eawx-std/Queue")

---@class GlobalValueQueue
GlobalValueQueue = class()

---@private
function GlobalValueQueue:new()
    ---@private
    ---@type table<string, Queue>
    self.global_values = {}
end

---@param key string
---@param value string
function GlobalValueQueue:queue_value(key, value)
    if not self.global_values[key] then
        self.global_values[key] = Queue()
    end

    self.global_values[key]:add(value)
end

function GlobalValueQueue:process_global_values()
    DebugMessage("In GlobalValueQueue:process_global_values()")
    for key, queue in pairs(self.global_values) do
        if self:can_send(key) and queue.size > 0 then
            local value = queue:remove()
            DebugMessage("Sending GlobalValue with key %s and value %s", tostring(key), tostring(value))
            GlobalValue.Set(key, value)
        end
    end
end

---@private
function GlobalValueQueue:can_send(key)
    local value = GlobalValue.Get(key)
    return not value or value == ""
end

return GlobalValueQueue
