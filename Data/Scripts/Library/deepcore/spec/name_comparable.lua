local function name_comparable(name)
    return setmetatable({__name = name}, {
            __eq = function (t, other)
                if type(other) ~= "table" then
                    return false
                end

                return t.__name == other.__name
            end
        }
    )
end

return name_comparable