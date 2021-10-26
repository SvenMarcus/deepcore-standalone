describe("DeepCore", function()

    local function capture_plugin_stub_context()
        local context_capture = {}
        local preloaded_plugin = require("spec/test-plugins/plugin-stub/init")
        preloaded_plugin.init = function(self, ctx)
            context_capture.context = ctx
        end

        return context_capture
    end

    local require_utilities = require("spec.require_utilities")
    local eaw_env = require("spec.eaw_env")

    local make_fake_player = require("spec.fake_playerobject")
    local findplanet = require("spec.fake_findplanet")

    before_each(function()
        require_utilities.replace_require()
        eaw_env.setup_environment()

        require("std/deepcore")
    end)

    after_each(function()
        require_utilities.reset_require()
        eaw_env.teardown_environment()

        _G.deepcore = nil
        _G.crossplot = nil
        package.loaded["std/deepcore"] = nil
        package.loaded["crossplot/crossplot"] = nil
        package.loaded["spec/test-plugins/plugin-stub/init"] = nil

        collectgarbage("collect")
    end)

    describe("When initializing deepcore:galactic", function()

        before_each(function()
            _G.Find_Player = function() return make_fake_player("Owner") end

            local make_fake_planet = require("spec.fake_planetobject")
            local fake_planet = make_fake_planet("PlanetA", "Owner")
            findplanet.setup_findplanet { PlanetA = fake_planet }
        end)

        after_each(function()
            findplanet.teardown_findplanet()
            _G.Find_Player = nil
        end)

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
            require("deepcore/crossplot/crossplot")
            spy.on(_G.crossplot, "galactic")

            deepcore:galactic {
                plugins = {},
                plugin_folder = "spec/test-plugins",
                context = {}
            }

            assert.spy(_G.crossplot.galactic).was.called()
        end)

        it("should add galactic conquest instance to context", function()
            _G.GalacticConquest = require("deepcore/galaxy/GalacticConquest")

            local context = {}
            deepcore:galactic {
                plugins = {"plugin-stub"},
                plugin_folder = "spec/test-plugins",
                context = context
            }

            local meta_index = getmetatable(context.galactic_conquest).__index
            assert.are.equal(meta_index, _G.GalacticConquest)
        end)

        describe("without context table", function()
            it("should add galactic conquest instance to context", function()
                _G.GalacticConquest = require("deepcore/galaxy/GalacticConquest")

                local context_capture = capture_plugin_stub_context()

                deepcore:galactic {
                    plugins = {"plugin-stub"},
                    plugin_folder = "spec/test-plugins",
                    context = nil
                }

                local context = context_capture.context
                local meta_index = getmetatable(context.galactic_conquest).__index
                assert.are.equal(meta_index, _G.GalacticConquest)
            end)
        end)
    end)

    describe("Given deepcore:galactic initialized", function()
        before_each(function()
            _G.Find_Player = function() return make_fake_player("Owner") end

            local make_fake_planet = require("spec.fake_planetobject")
            local fake_planet = make_fake_planet("PlanetA", "Owner")
            findplanet.setup_findplanet { PlanetA = fake_planet }
        end)

        after_each(function()
            findplanet.teardown_findplanet()
            _G.Find_Player = nil
        end)

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

            it("should update crossplot", function()
                require("deepcore/crossplot/crossplot")

                spy.on(crossplot, "update")

                local deepcore_runner = deepcore:galactic {
                    context = {},
                    plugins = {},
                    plugin_folder = "spec/test-plugins"
                }

                deepcore_runner:update()

                assert.spy(crossplot.update).was.called()
            end)
        end)
    end)

    describe("When initializing deepcore:game_object", function()
        it("should load plugins from given folder", function()
            local preloaded_plugin = require("spec/test-plugins/plugin-stub/init")
            local init_spy = spy.on(preloaded_plugin, "init")

            local context = {}
            deepcore:game_object {
                plugins = {"plugin-stub"},
                plugin_folder = "spec/test-plugins",
                context = context
            }

            assert.spy(init_spy).was.called_with(preloaded_plugin, context)
        end)

        it("should initialize crossplot:game_object", function()
            require("deepcore/crossplot/crossplot")
            spy.on(_G.crossplot, "game_object")

            deepcore:game_object {
                plugins = {},
                plugin_folder = "spec/test-plugins",
                context = {}
            }

            assert.spy(_G.crossplot.game_object).was.called()
        end)

        it("should update crossplot", function()
            require("crossplot.crossplot")

            spy.on(crossplot, "update")

            local deepcore_runner = deepcore:game_object {
                context = {},
                plugins = {},
                plugin_folder = "spec/test-plugins"
            }

            deepcore_runner:update()

            assert.spy(crossplot.update).was.called()
        end)

        describe("without context table", function()
            it("should provide empty context table", function()
                local context_capture = capture_plugin_stub_context()

                deepcore:game_object {
                    plugins = {"plugin-stub"},
                    plugin_folder = "spec/test-plugins",
                    context = nil
                }

                local context = context_capture.context
                assert.are.same({}, context)
            end)
        end)
    end)

    describe("Given deepcore:game_object initialized", function()
        describe("When updating", function()
            it("should update all plugins", function()
                local context = { updated_plugins = {} }
                local deepcore_runner = deepcore:game_object {
                    plugins = {"plugin-stub"},
                    plugin_folder = "spec/test-plugins",
                    context = context
                }

                deepcore_runner:update()

                assert.are.same({"plugin-stub"}, context.updated_plugins)
            end)
        end)
    end)

    describe("When initializing deepcore:gamescoring", function()
        it("should load plugins from given folder", function()
            local preloaded_plugin = require("spec/test-plugins/plugin-stub/init")
            local init_spy = spy.on(preloaded_plugin, "init")

            local context = {}
            deepcore:gamescoring {
                plugins = {"plugin-stub"},
                plugin_folder = "spec/test-plugins",
                context = context
            }

            assert.spy(init_spy).was.called_with(preloaded_plugin, context)
        end)

        it("should initialize crossplot:main", function()
            require("deepcore/crossplot/crossplot")
            spy.on(_G.crossplot, "main")

            deepcore:gamescoring {
                plugins = {},
                plugin_folder = "spec/test-plugins",
                context = {}
            }

            assert.spy(_G.crossplot.main).was.called()
        end)

        describe("without context table", function()
            it("should provide empty context table", function()
                local context_capture = capture_plugin_stub_context()

                deepcore:gamescoring {
                    plugins = {"plugin-stub"},
                    plugin_folder = "spec/test-plugins",
                    context = nil
                }

                local context = context_capture.context
                assert.are.same({}, context)
            end)
        end)
    end)

    describe("Given deepcore:gamescoring initialized", function()
        describe("When updating", function()
            it("should update all plugins", function()
                local context = { updated_plugins = {} }
                local deepcore_runner = deepcore:gamescoring {
                    plugins = {"plugin-stub"},
                    plugin_folder = "spec/test-plugins",
                    context = context
                }

                deepcore_runner:update()

                assert.are.same({"plugin-stub"}, context.updated_plugins)
            end)

            it("should update crossplot", function()
                require("crossplot.crossplot")

                spy.on(crossplot, "update")

                local deepcore_runner = deepcore:gamescoring {
                    context = {},
                    plugins = {},
                    plugin_folder = "spec/test-plugins"
                }

                deepcore_runner:update()

                assert.spy(crossplot.update).was.called()
            end)
        end)
    end)

    describe("When initializing any deepcore module without plugin folder", function()
        local function assert_raises_missing_plugin_folder_error(func)
            assert.has_error(func, "Missing mandatory setting plugin_folder")
        end

        it("should raise an error", function()
            assert_raises_missing_plugin_folder_error(function()
                deepcore:galactic {}
            end)

            assert_raises_missing_plugin_folder_error(function()
                deepcore:game_object {}
            end)

            assert_raises_missing_plugin_folder_error(function()
                deepcore:gamescoring {}
            end)
        end)
    end)
end)