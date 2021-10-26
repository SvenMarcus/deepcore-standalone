describe("MessageQueue", function()
    local require_utilities
    local eaw_env

    local fake_kvstore
    local mq

    before_each(function()
        eaw_env = require("spec.eaw_env")
        eaw_env.setup_environment()

        require_utilities = require("spec.require_utilities")
        require_utilities.replace_require()

        require("deepcore/crossplot/MessageQueue")
        local make_fake_kvstore = require("spec.crossplot.fake_kvstore")
        fake_kvstore = make_fake_kvstore()

        ---@type MessageQueue
        mq = MessageQueue(fake_kvstore)
    end)

    after_each(function()
        eaw_env.teardown_environment()
        require_utilities.reset_require()
        fake_kvstore:clear()
    end)

    describe("When queueing message", function()
        it("should save message in Key Value Store", function()
            mq:queue_value("key", "value")
            mq:process()

            assert.are.equal("value", fake_kvstore:get("key"))
        end)

        describe("but key is already set", function()
            before_each(function()
                fake_kvstore:store("key", "value")
            end)
            
            it("should not store key again", function()
                local store_spy = spy.on(fake_kvstore, "store")
                
                mq:queue_value("key", "value")
                mq:process()

                assert.spy(store_spy).was.not_called()
            end)
        end)

        describe("after message processed", function()
            it("should not be processed again", function()
                local store_spy = spy.on(fake_kvstore, "store")
                mq:queue_value("key", "value")
                
                mq:process()
                fake_kvstore:clear()

                mq:process()

                assert.spy(store_spy).was.called(1)
            end)
        end)
    end)
end)