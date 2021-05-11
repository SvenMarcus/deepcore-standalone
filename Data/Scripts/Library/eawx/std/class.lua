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
--*   @Filename:            class.lua
--*   @License:             MIT
--*****************************************************************************

---@alias Class table<string, any>

---Creates a new class
---@return Class
function class(extends)
    local mt = {
        __call = function(class, ...)
            local obj = setmetatable({}, {__index = class})

            if class.__extends and class.__extends.new then
                class.__extends.new(obj, unpack(arg))
            end

            if class.new then
                obj:new(unpack(arg))
            end

            return obj
        end
    }

    if extends then
        mt.__index = extends
    end

    return setmetatable(
        {
            __extends = extends
        },
        mt
    )
end
