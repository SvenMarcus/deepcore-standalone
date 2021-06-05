local make_fake_planet = require("spec.fake_planetobject")

local planet_mt = {}

function planet_mt:get_name()
    return self.name
end


function planet_mt:get_owner()
    return self.owner
end

function planet_mt:get_game_object()
    return self.game_object
end

---@class CustomPlanet : Planet
local custom_planet = {}

function custom_planet.new(name, owner)
    local self = setmetatable({}, {__index = planet_mt})
    self.name = name
    self.owner = owner
    self.game_object = make_fake_planet(name, owner)
    return self
end

return custom_planet