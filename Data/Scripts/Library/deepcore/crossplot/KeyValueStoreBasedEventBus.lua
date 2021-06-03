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

require("deepcore/std/class")
require("deepcore/std/Observable")
require("deepcore/crossplot/MessageQueue")

---@class KeyValueStoreBasedEventBus
KeyValueStoreBasedEventBus = class()

---@param name string
---@param kv_store GlobalValueKeyValueStore
function KeyValueStoreBasedEventBus:new(name, kv_store)
    self.name = (name or tostring(Script))

    self.kv_store = kv_store

    ---@type MessageQueue
    self.message_queue = MessageQueue(kv_store)
    self.subscribers = {}
end

---@param event_name string
function KeyValueStoreBasedEventBus:subscribe(event_name, listener_function, optional_self)
    local subscription = {
        name = self.name,
        event = event_name
    }

    if not self.subscribers[event_name] then
        self.subscribers[event_name] = Observable()
    end

    self.subscribers[event_name]:attach_listener(listener_function, optional_self)

    self.message_queue:queue_value("busid:main:subscribe", subscription)
    DebugMessage("Registered listener for %s", event_name)
end

---@param event_name string
---@param listener_function function
---@param optional_self table
function KeyValueStoreBasedEventBus:unsubscribe(event_name, listener_function, optional_self)
    local subscribers = self.subscribers[event_name]

    if not subscribers then
        return
    end

    subscribers:detach_listener(listener_function, optional_self)

    local unsub = {
        name = self.name,
        event = event_name
    }

    self.message_queue:queue_value("busid:main:unsubscribe", unsub)
    DebugMessage("Sent unsubscribe message for %s to master", event_name)
end

---@param event_name string
function KeyValueStoreBasedEventBus:publish(event_name, ...)
    self.message_queue:queue_value(
        "busid:main:publish",
        {
            event_name = event_name,
            args = arg
        }
    )
end

---@private
function KeyValueStoreBasedEventBus:process_notifications()
    local notification = self.kv_store:get("busid:" .. self.name .. ":notify")

    if not notification or notification == "" then
        return
    end

    local event_name = notification.event_name
    local args = notification.args

    local subscribers = self.subscribers[event_name]
    if not self.subscribers[event_name] then
        return
    end

    subscribers:notify(unpack(args))

    self.kv_store:free("busid:" .. self.name .. ":notify")
end

function KeyValueStoreBasedEventBus:update()
    self:process_notifications()
    self.message_queue:process()
end

---@class MainKeyValueStoreBasedEventBus
MainKeyValueStoreBasedEventBus = class()

function MainKeyValueStoreBasedEventBus:new(kv_store)
    self.name = "busid:main"

    ---@type table<string, string[]>
    self.subscribers = {}

    ---@type table<string, table>
    self.local_subscribers = {}

    self.kv_store = kv_store
    self.message_queue = MessageQueue(kv_store)
end

---@private
function MainKeyValueStoreBasedEventBus:process_subscriptions()
    local subscriber = self.kv_store:get("busid:main:subscribe")

    if not subscriber or subscriber == "" then
        return
    end

    DebugMessage("Registering subscriber in MainKeyValueStoreBasedEventBus")

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
    self.kv_store:free("busid:main:subscribe")
end

---@private
function MainKeyValueStoreBasedEventBus:process_unsubscriptions()
    local unsubscriber = self.kv_store:get("busid:main:unsubscribe")

    if not unsubscriber or unsubscriber == "" then
        return
    end

    DebugMessage("Trying to unsubscribe in MainKeyValueStoreBasedEventBus")

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

    self.kv_store:free("busid:main:unsubscribe")
end

---@private
---@return integer?
function MainKeyValueStoreBasedEventBus:get_subscriber_index(unsubscriber)
    for index, subscriber_name in ipairs(self.subscribers[unsubscriber.event]) do
        if unsubscriber.name == subscriber_name then
            return index
        end
    end

    return nil
end

---@private
function MainKeyValueStoreBasedEventBus:process_publish_messages()
    local publish_data = self.kv_store:get("busid:main:publish")

    if not publish_data or publish_data == "" then
        return
    end

    self:publish(publish_data.event_name, unpack(publish_data.args))
    self.kv_store:free("busid:main:publish")
end

---@param event_name string
---@param listener_function function
---@param optional_self table
function MainKeyValueStoreBasedEventBus:subscribe(event_name, listener_function, optional_self)
    if not self.local_subscribers[event_name] then
        self.local_subscribers[event_name] = Observable()
    end

    self.local_subscribers[event_name]:attach_listener(listener_function, optional_self)

    DebugMessage("Registered local listener on master for %s", event_name)
end

---@param event_name string
---@param listener_function function
---@param optional_self table
function MainKeyValueStoreBasedEventBus:unsubscribe(event_name, listener_function, optional_self)
    self.local_subscribers[event_name]:detach_listener(listener_function, optional_self)
end


---@param event_name string
function MainKeyValueStoreBasedEventBus:publish(event_name, ...)
    self:publish_to_local_subscribers(event_name, arg)
    local subscribers = self.subscribers[event_name]

    if not subscribers then
        return
    end

    for _, subscriber_name in pairs(subscribers) do
        self.message_queue:queue_value(
            "busid:" .. subscriber_name .. ":notify",
            {
                event_name = event_name,
                args = arg
            }
        )
    end
end

---@private
function MainKeyValueStoreBasedEventBus:publish_to_local_subscribers(event_name, arg_table)
    local subscribers = self.local_subscribers[event_name]

    if not subscribers then
        return
    end

    DebugMessage("Publishing %s to local subscribers", tostring(event_name))
    subscribers:notify(unpack(arg_table))
end

function MainKeyValueStoreBasedEventBus:update()
    self:process_subscriptions()
    self:process_unsubscriptions()
    self:process_publish_messages()
    self.message_queue:process()
end
