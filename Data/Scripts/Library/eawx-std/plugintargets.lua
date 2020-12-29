PluginTargets = {}

function PluginTargets.always()
    return function()
        return true
    end
end

function PluginTargets.never()
    return function()
        return false
    end
end

function PluginTargets.interval(seconds)
    return setmetatable(
        {seconds = seconds, last_update = -1},
        {
            __call = function(t)
                local current_time = GetCurrentTime()
                if t.last_update == -1 or t.last_update + t.seconds < current_time then
                    t.last_update = current_time
                    return true
                end

                return false
            end
        }
    )
end
