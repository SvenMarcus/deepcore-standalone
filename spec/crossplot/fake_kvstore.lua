local function make_fake_kvstore()
    return {
        __store = {},
        store = function(self, key, value)
            self.__store[key] = value
        end,

        get = function(self, key)
            return self.__store[key]
        end,

        free = function(self, key)
            self.__store[key] = nil
        end,

        clear = function(self)
            self.__store = {}
        end
    }
end


return make_fake_kvstore