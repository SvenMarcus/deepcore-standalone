describe("crossplot", function()
    local require_utilities
    local eaw_env

    local busid

    before_each(function()
        require_utilities = require("spec/require_utilities")
        require_utilities.replace_require()

        eaw_env = require("spec/eaw_env")
        eaw_env.setup_environment()

        busid = "busid:".._G.Script

        require("crossplot/crossplot")
    end)

    after_each(function()
        require_utilities.reset_require()
        eaw_env.teardown_environment()
        _G.crossplot = nil
        package.loaded["crossplot/crossplot"] = nil
    end)

    describe("When subscribing to an event", function()
        it("should set the GlobalValue for the master event bus", function()
            crossplot:galactic()

            local function func() end
            crossplot:subscribe("MY_EVENT", func)

            crossplot:update()
            
            local subscriber = loadstring(GlobalValue.Get("busid:main:subscribe"))()
            assert.are.equal(subscriber.name, Script)
            assert.are.equal(subscriber.event, "MY_EVENT")
        end)
    end)

    describe("Given subscribed to an event", function()
        describe("when publishing event", function()
            it("should call the callback function", function()
                crossplot:galactic()
                
                local func = spy.new(function() end)
                crossplot:subscribe("MY_EVENT", func)        
                GlobalValue.Set(busid..":notify", "return { event_name = 'MY_EVENT', args = {4, 2} }")

                crossplot:update()

                assert.spy(func).was.called_with(4, 2)
            end)

            it("should reset the GlobalValue", function()
                crossplot:galactic()
                
                local func = spy.new(function() end)
                crossplot:subscribe("MY_EVENT", func)        
                GlobalValue.Set(busid..":notify", "return { event_name = 'MY_EVENT', args = {4, 2} }")

                crossplot:update()

                assert.are.equal("", GlobalValue.Get(busid..":notify"))
            end)
        end)

        describe("when unsubscribing", function()
            it("should set the GlobalValue for the master event bus", function()
                crossplot:galactic()

                local function func() end
                crossplot:subscribe("MY_EVENT", func)
                crossplot:update()

                crossplot:unsubscribe("MY_EVENT", func)
                crossplot:update()

                local unsubscriber = loadstring(GlobalValue.Get("busid:main:unsubscribe"))()
                assert.are.equal(unsubscriber.name, _G.Script)
                assert.are.equal(unsubscriber.event, "MY_EVENT")
            end)
        end)
    end)
end)