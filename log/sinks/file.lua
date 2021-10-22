return {
    __important = true,
    __target = "eaw-lua.log",
    __id = "file",
    __has_character_limit = false,
    __log = function(self, message)
        _CustomScriptMessage(self.__target, tostring(message))
    end,
    with_target_file = function(self, target)
        if nil == target then return end
        if type(target) ~= "string" then return end
        self.__target = target
        return self
    end
}
