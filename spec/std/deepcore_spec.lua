describe("DeepCore", function()
    local require_utilities = require("spec.require_utilities")
    local eaw_env = require("spec.eaw_env")
    
    local make_fake_player = require("spec.fake_playerobject")
    local findplanet = require("spec.fake_findplanet")

    before_each(function()
        require_utilities.replace_require()
        eaw_env.setup_environment()
        _G.Find_Player = function() return make_fake_player("Owner") end

        local make_fake_planet = require("spec.fake_planetobject")
        local fake_planet = make_fake_planet("PlanetA", "Owner")
        findplanet.setup_findplanet { PlanetA = fake_planet }

        require("std/deepcore")
    end)

    after_each(function()
        require_utilities.reset_require()
        eaw_env.teardown_environment()
        findplanet.teardown_findplanet()
        _G.deepcore = nil
        _G.Find_Player = nil
        _G.crossplot = nil
        package.loaded["std/deepcore"] = nil
        package.loaded["crossplot/crossplot"] = nil
        collectgarbage("collect")
    end)
    
    describe("When initializing deepcore:galactic", function()
        it("should load plugins from given folder", function()
            local preloaded_plugin = require("spec/test-plugins/plugin-stub/init")
            local init_spy = spy.on(preloaded_plugin, "init")

            local context = {}
            deepcore:galactic {
                plugins = {"plugin-stub"},
                plugin_folder = "spec/test-plugins",
                context = context
            }

            assert.spy(init_spy).was.called_with(preloaded_plugin, context)
        end)

        it("should initialize crossplot:galactic", function()
            require("crossplot.crossplot")
            spy.on(_G.crossplot, "galactic")

            deepcore:galactic {
                plugins = {},
                plugin_folder = "spec/test-plugins",
                context = {}
            }

            assert.spy(_G.crossplot.galactic).was.called()
        end)

        it("should add galactic conquest instance to context", function()
            _G.GalacticConquest = require("galaxy.GalacticConquest")

            local context = {}
            deepcore:galactic {
                plugins = {"plugin-stub"},
                plugin_folder = "spec/test-plugins",
                context = context
            }

            local meta_index = getmetatable(context.galactic_conquest).__index
            assert.are.equal(meta_index, _G.GalacticConquest)
        end)
    end)

    describe("Given deepcore:galactic initialized", function()
        describe("When updating", function()
            it("should update all plugins", function()
                local context = { updated_plugins = {} }
                local deepcore_runner = deepcore:galactic {
                    plugins = {"plugin-stub", "active-planet-plugin"},
                    plugin_folder = "spec/test-plugins",
                    context = context
                }

                deepcore_runner:update()

                assert.are.same({"plugin-stub", "active-planet-plugin"}, context.updated_plugins)
            end)
        end)
    end)
end)