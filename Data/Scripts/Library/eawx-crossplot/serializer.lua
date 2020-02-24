--******************************************************************************
--     _______ __
--    |_     _|  |--.----.---.-.--.--.--.-----.-----.
--      |   | |     |   _|  _  |  |  |  |     |__ --|
--      |___| |__|__|__| |___._|________|__|__|_____|
--     ______
--    |   __ \.-----.--.--.-----.-----.-----.-----.
--    |      <|  -__|  |  |  -__|     |  _  |  -__|
--    |___|__||_____|\___/|_____|__|__|___  |_____|
--                                    |_____|
--*   @Author:              [TR]Pox
--*   @Date:                2017-12-18T14:01:25+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            TableSerializer.lua
--*   @Last modified by:    [TR]Pox
--*   @Last modified time:  2017-12-21T12:31:35+01:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

serializer = {}

function serializer:deserialize(str)
    return loadstring(str)()
end

function serializer:serialize(tab, nested)
    local result = ""
    if nested then
        result = result .. "{"
    else
        result = result .. "return {"
    end

    local hasEntries = false
    for k, v in pairs(tab) do
        hasEntries = true
        result = result .. self:_serializeKey(k) .. self:_serializeValue(v) .. ","
    end

    if not hasEntries then
        result = result .. "}"
        return result
    end

    result = string.sub(result, 1, -2)
    result = result .. "}"
    return result
end

function serializer:_serializeKey(value)
    local result = ""
    if type(value) == "table" then
        result = self:serialize(value, true)
    elseif type(value) == "function" then
        result = string.format("loadstring(%q)", string.dump(value))
    elseif type(value) == "string" then
        result = value
    end

    if type(value) ~= "number" then
        result = result .. "="
    end
    return result
end

function serializer:_serializeValue(value)
    local result = ""
    if type(value) == "table" then
        result = self:serialize(value, true)
    elseif type(value) == "function" then
        result = string.format("loadstring(%q)", string.dump(value))
    elseif type(value) == "string" then
        result = '"' .. value .. '"'
    else
        result = tostring(value)
    end

    return result
end
