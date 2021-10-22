return {
    __important = true,
    __id = "droid-log",
    __has_character_limit = true,
    __log = function(self, message)
        local msg = tostring(message)
        Game_Message(msg)
    end
}
