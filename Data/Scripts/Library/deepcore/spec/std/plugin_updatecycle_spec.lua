local function make_mock_plugin_container(allowed_to_update)
    return {
        target = function()
            return allowed_to_update
        end,
        plugin = mock {
            update = function()
            end
        }
    }
end

local function assert_plugin_updated(plugin_container)
    assert.spy(plugin_container.plugin.update).was.called_with(plugin_container.plugin)
end

local function assert_plugin_updated_with_planet(container, planet)
    assert.spy(container.plugin.update).was.called_with(container.plugin, planet)
end

describe("Plugin Update Cycle", function()
    local require_utilities = require("spec.require_utilities")

    before_each(function()
        require_utilities.replace_require()
    end)

    after_each(function()
        require_utilities.reset_require()
    end)

    describe("When calling generic update cycle", function()
        local generic_plugin_update_cycle

        before_each(function()
            generic_plugin_update_cycle = require("std.plugin_updatecycle").generic_plugin_update_cycle
        end)
        
        it("should update plugins", function()
            local first = make_mock_plugin_container(true)
            local second = make_mock_plugin_container(true)
            local context = {
                plugin_containers = {
                    first,
                    second
                }
            }

            generic_plugin_update_cycle(context)

            assert_plugin_updated(first)
            assert_plugin_updated(second)
        end)

        describe("but plugin target does not apply", function()
            it("should not update plugin", function()
                local first = make_mock_plugin_container(false)

                local context = {
                    plugin_containers = {first}
                }

                generic_plugin_update_cycle(context)

                assert.spy(first.plugin.update).was.not_called()
            end)
        end)

        describe("with two plugins with same non applying target", function()
            it("should cache the target result", function()
                local plugin_container = make_mock_plugin_container(false)
                spy.on(plugin_container, "target")
                
                local context = {
                    plugin_containers = {
                        plugin_container,
                        plugin_container
                    }
                }

                generic_plugin_update_cycle(context)

                assert.spy(plugin_container.target).was.called(1)
            end)
        end)
    end)

    describe("When calling galactic update cycle", function()
        local galactic_plugin_update_cycle = require("std.plugin_updatecycle").galactic_plugin_update_cycle

        before_each(function()
            galactic_plugin_update_cycle = require("std.plugin_updatecycle").galactic_plugin_update_cycle
        end)

        it("should update generic plugins", function()
            local first = make_mock_plugin_container(true)
            local second = make_mock_plugin_container(true)
            
            local context = {
                plugin_containers = {
                    first,
                    second
                },

                planet_dependent_plugin_containers = {},
                planets = {}
            }

            galactic_plugin_update_cycle(context)

            assert_plugin_updated(first)
            assert_plugin_updated(second)
        end)

        it("should update planet dependent plugins", function()
            local first_planet_plugin = make_mock_plugin_container(true)
            local second_planet_plugin = make_mock_plugin_container(true)
            
            local custom_planet = require("spec.fake_planetclass")
            local planet_a = custom_planet.new("PlanetA", "Owner")
            local planet_b = custom_planet.new("PlanetB", "Owner")

            local context = {
                plugin_containers = {},
                planet_dependent_plugin_containers = {
                    first_planet_plugin,
                    second_planet_plugin
                },

                planets = {
                    PlanetA = planet_a,
                    PlanetB = planet_b
                }
            }

            galactic_plugin_update_cycle(context)

            assert_plugin_updated_with_planet(first_planet_plugin, planet_a)
            assert_plugin_updated_with_planet(first_planet_plugin, planet_b)
            assert_plugin_updated_with_planet(second_planet_plugin, planet_a)
            assert_plugin_updated_with_planet(second_planet_plugin, planet_b)
        end)

        describe("with plugins with same target", function()
            it("should cache the target result", function()
                local plugin_container = make_mock_plugin_container(false)
                spy.on(plugin_container, "target")
                
                local custom_planet = require("spec.fake_planetclass")
                local planet_a = custom_planet.new("PlanetA", "Owner")

                local context = {
                    plugin_containers = {
                        plugin_container,
                        plugin_container
                    },

                    planet_dependent_plugin_containers = {
                        plugin_container,
                        plugin_container
                    },

                    planets = { planet_a }
                }

                galactic_plugin_update_cycle(context)

                assert.spy(plugin_container.target).was.called(1)
            end)
        end)
    end)
end)