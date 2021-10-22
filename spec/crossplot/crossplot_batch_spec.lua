describe("crossplot", function()

    local eaw_env
    local require_utilities

    before_each(function()
        eaw_env = require("spec.eaw_env")
        eaw_env.setup_environment()

        require_utilities = require("spec.require_utilities")
        require_utilities.replace_require()
    end)

    after_each(function()
        eaw_env.teardown_environment()
        require_utilities.reset_require()
    end)

    describe("Given event set as batch processing", function()
        describe("when publishing multiple messages", function()
            ---@type MainKeyValueStoreBasedEventBus
            local main_event_bus

            before_each(function()
                require("crossplot.crossplot")
                require("crossplot.GlobalValueKeyValueStore")
                require("crossplot.KeyValueStoreBasedEventBus")
                main_event_bus = MainKeyValueStoreBasedEventBus(GlobalValueKeyValueStore())
            end)

            after_each(function()
                _G.crossplot = nil
                _G.MainKeyValueStoreBasedEventBus = nil
                _G.GlobalValueKeyValueStore = nil
            end)

            it("should pass all arguments to the listener", function()
                local received_args = nil
                local function listener(arg)
                    received_args = arg
                end

                crossplot:galactic()
                crossplot:subscribe("my-event", listener)
                
                crossplot:set_batch_processing("my-event")

                crossplot:publish("my-event", "first-arg")
                crossplot:publish("my-event", { arg = "second-arg" }, "third-arg")

                crossplot:update()
                main_event_bus:update()
                crossplot:update()

                assert.are.same({"first-arg", { arg = "second-arg" }, "third-arg"}, received_args)
            end)
        end)
    end)
end)