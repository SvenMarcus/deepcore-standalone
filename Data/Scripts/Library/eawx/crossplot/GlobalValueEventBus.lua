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
--*   @Filename:            GlobalValueEventBus.lua
--*   @License:             MIT
--*****************************************************************************

require("eawx/std/class")
require("eawx/crossplot/serializer")
require("eawx/crossplot/GlobalValueQueue")

---@class GlobalValueEventBus
GlobalValueEventBus = class()

---@param name string
function GlobalValueEventBus:new(name)
    self.name = (name or tostring(Script))

    ---@type GlobalValueQueue
    self.message_queue = GlobalValueQueue()
    self.subscribers = {}
end

---@param event_name string
function GlobalValueEventBus:subscribe(event_name, listener_function, optional_self)
    local subscription =
        serializer:serialize {
        name = self.name,
        event = event_name
    }

    if not self.subscribers[event_name] then
        self.subscribers[event_name] = {}
    end

    table.insert(
        self.subscribers[event_name],
        {
            func = listener_function,
            optional_self = optional_self
        }
    )

    self.message_queue:queue_value("busid:master:subscribe", subscription)
    DebugMessage("Registered listener for %s", event_name)
end

---@param event_name string
---@param listener_function function
---@param optional_self table
function GlobalValueEventBus:unsubscribe(event_name, listener_function, optional_self)
    if not self.subscribers[event_name] then
        return
    end

    local del_index = self:get_subscriber_index(event_name, listener_function, optional_self)
    if del_index then
        table.remove(self.subscribers[event_name], del_index)
    end

    local unsub = serializer:serialize {
        name = self.name,
        event = event_name
    }

    self.message_queue:queue_value("busid:master:unsubscribe", unsub)
    DebugMessage("Sent unsubscribe message for %s to master", event_name)
end

---@private
---@return integer?
function GlobalValueEventBus:get_subscriber_index(event_name, listener_function, optional_self)
    for index, sub in ipairs(self.subscribers[event_name]) do
        if sub.func == listener_function and sub.optional_self == optional_self then
            return index
        end
    end

    return nil
end

---@param event_name string
function GlobalValueEventBus:publish(event_name, ...)
    self.message_queue:queue_value(
        "busid:master:publish",
        serializer:serialize {
            event_name = event_name,
            args = arg
        }
    )
end

---@private
function GlobalValueEventBus:process_notifications()
    local notification = GlobalValue.Get("busid:" .. self.name .. ":notify")

    if not notification or notification == "" then
        return
    end

    notification = serializer:deserialize(notification)

    local event_name = notification.event_name
    local args = notification.args

    if not self.subscribers[event_name] then
        return
    end

    for _, subscriber in pairs(self.subscribers[event_name]) do
        if subscriber.optional_self then
            subscriber.func(subscriber.optional_self, unpack(args))
        else
            subscriber.func(unpack(args))
        end
    end

    GlobalValue.Set("busid:" .. self.name .. ":notify", "")
end

function GlobalValueEventBus:update()
    self:process_notifications()
    self.message_queue:process_global_values()
end

---@class MasterGlobalValueEventBus
MasterGlobalValueEventBus = class()

function MasterGlobalValueEventBus:new()
    self.name = "busid:master"

    ---@type table<string, string[]>
    self.subscribers = {}

    ---@type table<string, table>
    self.local_subscribers = {}

    self.message_queue = GlobalValueQueue()
end

---@private
function MasterGlobalValueEventBus:process_subscriptions()
    local subscriber = GlobalValue.Get("busid:master:subscribe")

    if not subscriber or subscriber == "" then
        return
    end

    DebugMessage("Registering subscriber in MasterGlobalValueEventBus")

    subscriber = serializer:deserialize(subscriber)

    if type(subscriber) ~= "table" then
        return
    end

    if not (subscriber.name and subscriber.event) then
        return
    end

    if not (type(subscriber.name) == "string" and type(subscriber.event) == "string") then
        return
    end

    if not self.subscribers[subscriber.event] then
        self.subscribers[subscriber.event] = {}
    end

    table.insert(self.subscribers[subscriber.event], subscriber.name)
    GlobalValue.Set("busid:master:subscribe", "")
end

---@private
function MasterGlobalValueEventBus:process_unsubscriptions()
    local unsubscriber = GlobalValue.Get("busid:master:unsubscribe")

    if not unsubscriber or unsubscriber == "" then
        return
    end

    DebugMessage("Trying to unsubscribe in MasterGlobalValueEventBus")

    unsubscriber = serializer:deserialize(unsubscriber)

    if type(unsubscriber) ~= "table" then
        return
    end

    if not (unsubscriber.name and unsubscriber.event) then
        return
    end

    if not (type(unsubscriber.name) == "string" and type(unsubscriber.event) == "string") then
        return
    end

    if not self.subscribers[unsubscriber.event] then
        DebugMessage("Tried unsubscribing from %s, but no subscribers registered for this event", unsubscriber.event)
        return
    end

    local del_index = self:get_subscriber_index(unsubscriber)
    if del_index then
        table.remove(self.subscribers[unsubscriber.event], del_index)
    end

    GlobalValue.Set("busid:master:unsubscribe", "")
end

---@private
---@return integer?
function MasterGlobalValueEventBus:get_subscriber_index(unsubscriber)
    for index, subscriber_name in ipairs(self.subscribers[unsubscriber.event]) do
        if unsubscriber.name == subscriber_name then
            return index
        end
    end

    return nil
end

---@private
function MasterGlobalValueEventBus:process_publish_messages()
    local publish_data = GlobalValue.Get("busid:master:publish")

    if not publish_data or publish_data == "" then
        return
    end

    publish_data = serializer:deserialize(publish_data)

    self:publish(publish_data.event_name, unpack(publish_data.args))
    GlobalValue.Set("busid:master:publish", "")
end

---@param event_name string
function MasterGlobalValueEventBus:subscribe(event_name, listener_function, optional_self)
    if not self.local_subscribers[event_name] then
        self.local_subscribers[event_name] = {}
    end

    table.insert(
        self.local_subscribers[event_name],
        {
            func = listener_function,
            optional_self = optional_self
        }
    )

    DebugMessage("Registered local listener on master for %s", event_name)
end

---@param event_name string
---@param ... varargs
function MasterGlobalValueEventBus:publish(event_name, ...)
    self:publish_to_local_subscribers(event_name, arg)
    local subscribers = self.subscribers[event_name]

    if not subscribers then
        return
    end

    for _, subscriber_name in pairs(subscribers) do
        self.message_queue:queue_value(
            "busid:" .. subscriber_name .. ":notify",
            serializer:serialize {
                event_name = event_name,
                args = arg
            }
        )
    end
end

---@private
function MasterGlobalValueEventBus:publish_to_local_subscribers(event_name, arg_table)
    local subscribers = self.local_subscribers[event_name]

    if not subscribers then
        return
    end

    DebugMessage("Publishing %s to local subscribers", tostring(event_name))
    for _, subscriber in pairs(subscribers) do
        if subscriber.optional_self then
            subscriber.func(subscriber.optional_self, unpack(arg_table))
        else
            subscriber.func(unpack(arg_table))
        end
    end
end

function MasterGlobalValueEventBus:update()
    self:process_subscriptions()
    self:process_unsubscriptions()
    self:process_publish_messages()
    self.message_queue:process_global_values()
end
