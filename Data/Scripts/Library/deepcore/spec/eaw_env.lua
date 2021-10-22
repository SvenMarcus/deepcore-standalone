local function setup_environment()
    _G.GlobalValue = {
        store = {}
    }
    function _G.GlobalValue.Set(key, value)
        GlobalValue.store[key] = value
    end

    function _G.GlobalValue.Get(key)
        return GlobalValue.store[key]
    end

    function _G.DebugMessage(msg, ...)
        -- print(string.format(msg, ...))
    end

    _G.Script = "MyScript"
end

local function teardown_environment()
    _G.GlobalValue = nil
    _G.DebugMessage = nil
    _G.Script = nil
end

return {
    setup_environment = setup_environment,
    teardown_environment = teardown_environment
}