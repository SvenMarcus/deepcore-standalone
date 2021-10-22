return {
    __important = true,
    __log_level = 2,
    __trace = 3,
    __info = 2,
    __warn = 1,
    __sink = require("eaw-log/sinks/file"),
    log_level = function(self) return self.__log_level end,
    with_sink = function(self, sink)
        if type(sink) == "table" then
            self.__sink = sink
            return self
        end
        local use_default_sink = false
        if type(sink) ~= "string" then use_default_sink = true end
        if nil == require("eaw-log/sinks/" .. sink) then
            use_default_sink = true
        end
        if use_default_sink then
            self.__sink = require("eaw-log/sinks/file")
            return self
        end
        self.__sink = require("eaw-log/sinks/" .. sink)
        return self
    end,
    with_log_level = function(self, level)
        if type(level) ~= "number" then level = 0 end
        if level > self.__trace then level = self.__trace end
        if level < 0 then level = 0 end
        self.__log_level = level
        return self
    end,
    trace = function(self, ...)
        if arg == nil or table.getn(arg) < 1 then return end
        if self:log_level() < self.__trace then return end
        if table.getn(arg) == 1 then
            self.__sink:__log(string.format("%s -- [TRACE] -- %s",
                                            tostring(Script), tostring(arg[1])))
        else
            self.__sink:__log(string.format("%s -- [TRACE] -- %s",
                                            tostring(Script),
                                            string.format(unpack(arg))))
        end
    end,
    info = function(self, ...)
        if arg == nil or table.getn(arg) < 1 then return end
        if self:log_level() < self.__info then return end
        if table.getn(arg) == 1 then
            self.__sink:__log(string.format("%s -- [INFO] -- %s",
                                            tostring(Script), tostring(arg[1])))
        else
            self.__sink:__log(string.format("%s -- [INFO] -- %s",
                                            tostring(Script),
                                            string.format(unpack(arg))))
        end
    end,
    warn = function(self, ...)
        if arg == nil or table.getn(arg) < 1 then return end
        if self:log_level() < self.__warn then return end
        if table.getn(arg) == 1 then
            self.__sink:__log(string.format("%s -- [WARN] -- %s",
                                            tostring(Script), tostring(arg[1])))
            _OuputDebug(string.format("%s -- [WARN] -- %s\n", tostring(Script),
                                      tostring(arg[1])))
        else
            self.__sink:__log(string.format("%s -- [WARN] -- %s",
                                            tostring(Script),
                                            string.format(unpack(arg))))
            _OuputDebug(string.format("%s -- [WARN] -- %s\n", tostring(Script),
                                      string.format(unpack(arg))))
        end
    end,
    error = function(self, ...)
        if arg == nil or table.getn(arg) < 1 then return end
        if table.getn(arg) == 1 then
            self.__sink:__log(string.format("%s -- [ERROR] -- %s",
                                            tostring(Script), tostring(arg[1])))
            if not self.__sink.__has_character_limit then
                self.__sink:__log(string.format("%s -- [ERROR] -- %s",
                                                tostring(Script),
                                                DumpCallStack()))
            end
            _OuputDebug(string.format("%s -- [ERROR] -- %s\n", tostring(Script),
                                      tostring(arg[1])))
            _OuputDebug(string.format("%s -- [ERROR] -- %s\n", tostring(Script),
                                      DumpCallStack()))
        else
            self.__sink:__log(string.format("%s -- [ERROR] -- %s",
                                            tostring(Script),
                                            string.format(unpack(arg))))
            if not self.__sink.__has_character_limit then
                self.__sink:__log(string.format("%s -- [ERROR] -- %s",
                                                tostring(Script),
                                                DumpCallStack()))
            end
            _OuputDebug(string.format("%s -- [ERROR] -- %s\n", tostring(Script),
                                      string.format(unpack(arg))))
            _OuputDebug(string.format("%s -- [ERROR] -- %s\n", tostring(Script),
                                      DumpCallStack()))
        end
    end
}
