local require_utilities = {
    original_require = require,
    loaded_modules = {}
}

function require_utilities.replace_require()
    _G.require = function(path)
        if string.sub(path, 1, string.len("deepcore/")) == "deepcore/" then
            local stripped_path = string.sub(path, string.len("deepcore/") + 1)
            table.insert(require_utilities.loaded_modules, stripped_path)
            return require_utilities.original_require(stripped_path)
        end

        return require_utilities.original_require(path)
    end
end

function require_utilities.reset_require()
    for _, path in ipairs(require_utilities.loaded_modules) do
        package.loaded[path] = nil
        _G.package.loaded[path] = nil
    end
    _G.require = require_utilities.original_require
end

return require_utilities