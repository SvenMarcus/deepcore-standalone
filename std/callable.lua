function callable(tab)
    return setmetatable(tab, {
        __call = function(t, ...)
            return t.call(t, unpack(arg))
        end
    })
end