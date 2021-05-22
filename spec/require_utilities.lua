local require_utilities = {
    original_require = require
}

function require_utilities.replace_require()
    _G.require = function(path)
        if string.sub(path, 1, string.len("eawx/")) == "eawx/" then
            return require_utilities.original_require(string.sub(path, string.len("eawx/") + 1))
        end

        return require_utilities.original_require(path)
    end
end

function require_utilities.reset_require()
    _G.require = require_utilities.original_require
end

return require_utilities