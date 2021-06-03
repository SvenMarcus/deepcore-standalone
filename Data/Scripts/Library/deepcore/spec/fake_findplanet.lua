local function setup_findplanet(planet_map)
    planet_map = planet_map or {}

    _G.FindPlanet = setmetatable({}, {
        __call = function(t, name)
            return planet_map[name]
        end
    })

    _G.FindPlanet.Get_All_Planets = function()
        local all_planets = {}
        for key, planet in pairs(planet_map) do
            table.insert(all_planets, planet)
        end
        return all_planets
    end
end

local function teardown_findplanet()
    _G.FindPlanet = nil
end

return {
    setup_findplanet = setup_findplanet,
    teardown_findplanet = teardown_findplanet
}