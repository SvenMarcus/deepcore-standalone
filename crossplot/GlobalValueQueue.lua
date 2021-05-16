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
--*   @Filename:            GlobalValueQueue.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx/std/class")
require("eawx/std/Queue")

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
