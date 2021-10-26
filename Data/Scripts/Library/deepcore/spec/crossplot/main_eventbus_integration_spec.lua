describe("crossplot MainKeyValueStoreBasedEventBus", function()
    local eaw_env = require("spec.eaw_env")
    local require_utilities = require("spec.require_utilities")

    before_each(function()
        eaw_env.setup_environment()
        require_utilities.replace_require()
        require("deepcore/crossplot/KeyValueStoreBasedEventBus")
        require("deepcore/crossplot/GlobalValueKeyValueStore")
    end)

    after_each(function()
        eaw_env.teardown_environment()
        require_utilities.reset_require()
    end)

    local main
    local eventbus
    local subscriber_func

    describe("Given subscribed function", function()
        before_each(function()
            main = MainKeyValueStoreBasedEventBus(GlobalValueKeyValueStore())
            eventbus = KeyValueStoreBasedEventBus("eventbus", GlobalValueKeyValueStore())

            subscriber_func = spy.new(function() end)
            eventbus:subscribe("MY_EVENT", subscriber_func)

            eventbus:update()
            main:update()
        end)

        describe("when publishing", function()
            it("should call callback function", function()
                main:publish("MY_EVENT", "args")

                main:update()
                eventbus:update()

                assert.spy(subscriber_func).was.called_with("args")
            end)
        end)

        describe("when unsubscribing", function()
            describe("then publishing", function()
                it("should not call callback function", function()
                    eventbus:unsubscribe("MY_EVENT", subscriber_func)

                    eventbus:update()
                    main:update()

                    main:publish("MY_EVENT", "args")

                    main:update()
                    eventbus:update()

                    assert.spy(subscriber_func).was.not_called()
                end)
            end)
        end)
    end)

    describe("Given subscribed function with context", function()
        local context

        before_each(function()
            main = MainKeyValueStoreBasedEventBus(GlobalValueKeyValueStore())
            eventbus = KeyValueStoreBasedEventBus("eventbus", GlobalValueKeyValueStore())

            context = {}
            subscriber_func = spy.new(function() end)
            eventbus:subscribe("MY_EVENT", subscriber_func, context)

            eventbus:update()
            main:update()
        end)

        describe("when publishing", function()
            it("should call callback function with context", function()
                main:publish("MY_EVENT", "args")

                main:update()
                eventbus:update()

                assert.spy(subscriber_func).was.called_with(context, "args")
            end)
        end)

        describe("when unsubscribing", function()
            describe("then publishing", function()
                it("should not call callback function", function()
                    eventbus:unsubscribe("MY_EVENT", subscriber_func, context)

                    eventbus:update()
                    main:update()

                    main:publish("MY_EVENT", "args")

                    main:update()
                    eventbus:update()

                    assert.spy(subscriber_func).was.not_called()
                end)
            end)
        end)
    end)

    describe("Given subscribed function on main", function()
        before_each(function()
            main = MainKeyValueStoreBasedEventBus(GlobalValueKeyValueStore())

            subscriber_func = spy.new(function() end)
            main:subscribe("MY_EVENT", subscriber_func)
        end)

        describe("when publishing", function()
            it("should call callback function", function()
                main:publish("MY_EVENT", "args")

                assert.spy(subscriber_func).was.called_with("args")
            end)
        end)

        describe("when unsubscribing", function()
            describe("then publishing", function()
                it("should not call callback function", function()
                    main:unsubscribe("MY_EVENT", subscriber_func)

                    main:publish("MY_EVENT")

                    assert.spy(subscriber_func).was.not_called()
                end)
            end)
        end)
    end)

    describe("Given subscribed function with context on main", function()
        local context

        before_each(function()
            main = MainKeyValueStoreBasedEventBus()

            context = {}
            subscriber_func = spy.new(function() end)
            main:subscribe("MY_EVENT", subscriber_func, context)
        end)

        describe("when publishing", function()
            it("should call callback function", function()
                main:publish("MY_EVENT", "args")

                assert.spy(subscriber_func).was.called_with(context, "args")
            end)
        end)

        describe("when unsubscribing", function()
            describe("then publishing", function()
                it("should not call callback function", function()
                    main:unsubscribe("MY_EVENT", subscriber_func, context)

                    main:publish("MY_EVENT")

                    assert.spy(subscriber_func).was.not_called()
                end)
            end)
        end)
    end)
end)