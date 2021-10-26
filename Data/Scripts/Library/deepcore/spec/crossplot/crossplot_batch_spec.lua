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
        ---@type MainKeyValueStoreBasedEventBus
        local main_event_bus


        describe("when publishing multiple messages", function()

            before_each(function()
                require("deepcore/crossplot/KeyValueStoreBasedEventBus")
                require("deepcore/crossplot/GlobalValueKeyValueStore")
                require("deepcore/crossplot/crossplot")

                main_event_bus = MainKeyValueStoreBasedEventBus(GlobalValueKeyValueStore())
                crossplot:galactic()
                crossplot:set_batch_processing("my-event")
            end)


            local function run_crossplot_update_cycle()
                crossplot:update()
                main_event_bus:update()
                crossplot:update()
            end

            it("should pass all arguments to the listener", function()
                local received_args = nil
                local function listener(arg)
                    received_args = arg
                end
                crossplot:subscribe("my-event", listener)

                crossplot:publish("my-event", "first-arg")
                crossplot:publish("my-event", { arg = "second-arg" }, "third-arg")

                run_crossplot_update_cycle()
                assert.are.same({"first-arg", { arg = "second-arg" }, "third-arg"}, received_args)
            end)

            it("should only notify once", function()
                local listener = spy.new(function() end)
                
                crossplot:subscribe("my-event", listener)
                crossplot:publish("my-event", "first-arg")

                run_crossplot_update_cycle()
                run_crossplot_update_cycle()

                assert.spy(listener).was.called(1)
            end)
        end)
    end)
end)