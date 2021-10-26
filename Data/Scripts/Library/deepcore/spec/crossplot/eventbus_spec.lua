describe("Eventbus", function()
    local require_utilities
    local eaw_env

    local busid
    local eventbus

    local fake_kvstore

    before_each(function()
        local make_fake_kvstore = require("spec.crossplot.fake_kvstore")

        require_utilities = require("spec.require_utilities")
        require_utilities.replace_require()
        
        eaw_env = require("spec.eaw_env")
        eaw_env.setup_environment()
        
        busid = "busid:".._G.Script
        
        require("deepcore/crossplot/KeyValueStoreBasedEventBus")
        fake_kvstore = make_fake_kvstore()
        eventbus = KeyValueStoreBasedEventBus(_G.Script, fake_kvstore)
    end)

    after_each(function()
        require_utilities.reset_require()
        eaw_env.teardown_environment()
        fake_kvstore:clear()
    end)

    describe("When subscribing to an event", function()
        it("should set the GlobalValue for the master event bus", function()
            local function func() end
            eventbus:subscribe("MY_EVENT", func)
            
            eventbus:update()

            local subscriber = fake_kvstore:get("busid:main:subscribe")
            assert.are.equal(subscriber.name, Script)
            assert.are.equal(subscriber.event, "MY_EVENT")
        end)
    end)

    describe("Given subscribed to an event", function()
        describe("when publishing event", function()
            it("should call the callback function", function()
                local func = spy.new(function() end)
                eventbus:subscribe("MY_EVENT", func)
                fake_kvstore:store(busid..":notify", { event_name = 'MY_EVENT', args = {4, 2} })

                eventbus:update()

                assert.spy(func).was.called_with(4, 2)
            end)

            it("should reset the GlobalValue", function()
                local func = function() end
                eventbus:subscribe("MY_EVENT", func)
                fake_kvstore:store(busid..":notify", { event_name = 'MY_EVENT', args = {4, 2} })

                eventbus:update()

                assert.is_nil(fake_kvstore:get(busid..":notify"))
            end)
        end)

        describe("when unsubscribing", function()
            it("should set the GlobalValue for the master event bus", function()
                local function func() end
                eventbus:subscribe("MY_EVENT", func)
                eventbus:update()

                eventbus:unsubscribe("MY_EVENT", func)
                eventbus:update()

                local unsubscriber = fake_kvstore:get("busid:main:unsubscribe")
                assert.are.equal(unsubscriber.name, _G.Script)
                assert.are.equal(unsubscriber.event, "MY_EVENT")
            end)
        end)
    end)
end)