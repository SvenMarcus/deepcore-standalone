return {
    __important = true,
    __id = "screen-text",
    __has_character_limit = true,
    __event = nil,
    __trigger_name = nil,
    __display_time = 5,
    with_event = function(self, event, trigger_name)
        self.__event = event
        self.__trigger_name = trigger_name
        return self
    end,
    with_display_time = function(self, time)
        self.__display_time = time
        return self
    end,
    with_character_limit_enabled = function (self, enable)
        self.__has_character_limit = enable
        return self
    end,
    __log = function(self, message)
        if not self.__event or not self.__trigger_name then
            return
        end
        local msg = tostring(message)
        self.__event.Set_Reward_Parameter(0, msg)
        self.__event.Set_Reward_Parameter(1, tostring(self.__display_time))
        Story_Event(self.__trigger_name)
    end
}