local make_fake_planet = require("spec.fake_planetobject")
local make_fake_player = require("spec.fake_playerobject")
local findplanet = require("spec.fake_findplanet")
local custom_planet = require("spec.fake_planetclass")


describe("GalacticConquest", function()
    local eaw_env = require("spec.eaw_env")
    local require_utilities = require("spec.require_utilities")
    local planet_map
    local galactic_conquest

    before_each(function()
        require_utilities.replace_require()
        eaw_env.setup_environment()

        require("deepcore/galaxy/GalacticConquest")
        require("deepcore/crossplot/crossplot")
        crossplot:galactic()

        planet_map = {
            PlanetA = make_fake_planet("PlanetA", "Owner"),
            PlanetB = make_fake_planet("PlanetB", "Owner"),
            PlanetC = make_fake_planet("PlanetC", "Owner")
        }

        _G.Find_Player = function(_) end
        findplanet.setup_findplanet(planet_map)

        local owner = make_fake_player("Owner")
        local planet_factory = function(name)
            return custom_planet.new(name, owner)
        end

        ---@type GalacticConquest
        galactic_conquest = GalacticConquest(planet_factory)
    end)

    after_each(function()
        require_utilities.reset_require()
        eaw_env.teardown_environment()
        findplanet.teardown_findplanet()
        _G.Find_Player = nil
    end)

    describe("Given new instance", function()
        it("should contain all planets", function()
            local all_planets = galactic_conquest.Planets

            assert.are.equal("PlanetA", all_planets["PlanetA"].name)
            assert.are.equal("PlanetB", all_planets["PlanetB"].name)
            assert.are.equal("PlanetC", all_planets["PlanetC"].name)
        end)

        it("should have list of planets by owner", function()
            local planets_by_owner = galactic_conquest.Planets_By_Faction["Owner"]

            assert.are.same(
                {"PlanetA", "PlanetB", "PlanetC"},
                {
                    planets_by_owner["PlanetA"].name,
                    planets_by_owner["PlanetB"].name,
                    planets_by_owner["PlanetC"].name,
            })
        end)

        describe("When planet owner changes", function()
            before_each(function()
                local planet_a = galactic_conquest.Planets["PlanetA"]
                planet_a.owner = make_fake_player("NewOwner")

                local old_owner_name = "Owner"
                local new_owner_name = "NewOwner"

                ---@type PlanetOwnerChangedEvent
                galactic_conquest.Events.PlanetOwnerChanged:notify(planet_a, new_owner_name, old_owner_name)
            end)

            it("should move planet to planet table of new owner", function()
                local planet_a = galactic_conquest.Planets["PlanetA"]
                planet_a.owner = make_fake_player("NewOwner")
            
                local old_owner_planets = galactic_conquest.Planets_By_Faction["Owner"]
                local new_owner_planets = galactic_conquest.Planets_By_Faction["NewOwner"]

                assert.is_nil(old_owner_planets["PlanetA"])
                assert.are.equal(planet_a, new_owner_planets["PlanetA"])
            end)

            it("should update the number of owned planets by player", function()
                local number_old_owner_planets = 
                    galactic_conquest:get_number_of_planets_owned_by_faction(make_fake_player("Owner"))
                
                local number_new_owner_planets = 
                    galactic_conquest:get_number_of_planets_owned_by_faction(make_fake_player("NewOwner"))

                assert.are.equal(2, number_old_owner_planets)
                assert.are.equal(1, number_new_owner_planets)
            end)
        end)
    end)
end)