describe("PluginLoader", function()
    local eaw_env = require("spec.eaw_env")
    local require_utilities = require("spec.require_utilities")

    local context
    local plugin_loader

    before_each(function()
        require_utilities.replace_require()
        eaw_env.setup_environment()
        require("std/PluginLoader")

        context = {name = "the_context"}
        plugin_loader = PluginLoader(context, "spec/test-plugins")
    end)

    after_each(function()
        eaw_env.teardown_environment()
        require_utilities.reset_require()
    end)

    local function assert_loaded_plugin_stub(plugin)
        assert.are.equal("PLUGIN_STUB", plugin.plugin_info)
        assert.are.equal(context, plugin.context)
    end

    describe("When loading single installed plugin", function()
        it("should load list with configured plugin", function()
            plugin_loader:load {"plugin-stub"}

            local plugin_containers = plugin_loader:get_plugin_containers()
            local container = plugin_containers[1]

            assert.are.equal("THE_TARGET", container.target())
            assert_loaded_plugin_stub(container.plugin)
        end)

        describe("without providing plugin list", function()
            it("should load plugins from InstalledPlugins", function()
                plugin_loader:load()

                local plugin_containers = plugin_loader:get_plugin_containers()
                local container = plugin_containers[1]

                assert.are.equal("THE_TARGET", container.target())
                assert_loaded_plugin_stub(container.plugin)
            end)
        end)
    end)

    describe("When loading plugin with dependency", function()
        it("should pass dependency to dependent plugin", function()
            plugin_loader:load {"plugin-with-dependency"}

            local plugin_containers = plugin_loader:get_plugin_containers()
            local container = plugin_containers[2]
            
            local received = container.plugin.received_dependency
            assert_loaded_plugin_stub(received)
        end)
    end)

    describe("When loading planet dependent plugin", function()
        it("should load list with planet dependent plugins", function()
            plugin_loader:load {"planet-plugin"}

            local plugin_containers = plugin_loader:get_planet_dependent_plugin_containers()
            local container = plugin_containers[1]
            local plugin = container.plugin

            assert.are.equal("PLANET_PLUGIN", plugin.plugin_info)
        end)
    end)

    describe("When loading plugins with cyclic dependencies", function()
        it("should throw an error", function()
            local cyclic_load = function()
                plugin_loader:load {"cyclic-a", "cyclic-b"}
            end

            assert.has_error(cyclic_load)
        end)
    end)
end)