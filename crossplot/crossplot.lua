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
require("deepcore/crossplot/KeyValueStoreBasedEventBus")
require("deepcore/crossplot/GlobalValueKeyValueStore")

---A module that allows publish-subscribe communication between different Lua script environments
crossplot = {__instance = nil, __important = true, __batch_processors = {}}

---Initialize the main crossplot instance. Use only in GameScoring.
function crossplot:main()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing MainKeyValueStoreBasedEventBus",
                 tostring(Script))
    self.__instance = MainKeyValueStoreBasedEventBus(GlobalValueKeyValueStore())
end

---Initialize crossplot for the galactic plot
function crossplot:galactic()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing KeyValueStoreBasedEventBus", tostring(Script))
    self.__instance = KeyValueStoreBasedEventBus(tostring(Script), GlobalValueKeyValueStore())
end

---Initialize crossplot on a tactical plot
function crossplot:tactical()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing KeyValueStoreBasedEventBus", tostring(Script))
    self.__instance = KeyValueStoreBasedEventBus("crossplot:tactical", GlobalValueKeyValueStore())
end

---Initialize crossplot for on a script attached to a game object
function crossplot:game_object()
    if self.__instance then
        DebugMessage("crossplot has already been initialized in this plot")
        return
    end

    DebugMessage("%s -- initializing KeyValueStoreBasedEventBus", tostring(Script))
    local name = tostring(Object)
    self.__instance = KeyValueStoreBasedEventBus(name, GlobalValueKeyValueStore())
end

---Subscribe to a crossplot event
---@param event_name string
---@param listener_function function
---@param optional_self table
function crossplot:subscribe(event_name, listener_function, optional_self)
    if not self.__instance then
        DebugMessage("crossplot has not been initialized in this plot")
        return
    end

    self.__instance:subscribe(event_name, listener_function, optional_self)
end

---Unsubscribe from a crossplot event
---@param event_name string
---@param listener_function function
---@param optional_self table
function crossplot:unsubscribe(event_name, listener_function, optional_self)
    if not self.__instance then
        DebugMessage("crossplot has not been initialized in this plot")
        return
    end

    self.__instance:unsubscribe(event_name, listener_function, optional_self)
end

function crossplot:publish(event_name, ...)
    if not self.__instance then
        DebugMessage("crossplot has not been initialized in this plot")
        return
    end

    if self:try_publish_batch(event_name, arg) then
        return
    end

    self.__instance:publish(event_name, unpack(arg))
end

function crossplot:update()
    if not self.__instance then
        DebugMessage("crossplot has not been initialized in this plot")
        return
    end

    self:publish_stored_batch_events()
    self.__instance:update()
end

---@param event_name string
function crossplot:set_batch_processing(event_name)
    if self.__batch_processors[event_name] then
        return
    end

    self.__batch_processors[event_name] = {
        arg_store = {}
    }
end

---@private
---@param event_name string
---@param arg_table table<number, any>
function crossplot:try_publish_batch(event_name, arg_table)
    local batch_processor = self.__batch_processors[event_name]
    if not batch_processor then
        return false
    end

    for _, value in ipairs(arg_table) do
        table.insert(batch_processor.arg_store, value)
    end
    
    return true
end

---@private
function crossplot:publish_stored_batch_events()
    for event_name, batch_processor in pairs(self.__batch_processors) do
        if table.getn(batch_processor.arg_store) > 0 then
            self.__instance:publish(event_name, batch_processor.arg_store)
            batch_processor.arg_store = {}
        end
    end
end

return crossplot
