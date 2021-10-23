require("deepcore/std/class")
require("deepcore/crossplot/serializer")

---@class GlobalValueKeyValueStore
GlobalValueKeyValueStore = class()

---@param key string
---@param value any
function GlobalValueKeyValueStore:store(key, value)
    GlobalValue.Set(key, serializer:serialize(value))
end

---@param key string
function GlobalValueKeyValueStore:get(key)
    local value = GlobalValue.Get(key)
    if not value then
        return nil
    end

    return serializer:deserialize(value)
end

---@param key string
function GlobalValueKeyValueStore:free(key)
    GlobalValue.Set(key, "")
end

return GlobalValueKeyValueStore