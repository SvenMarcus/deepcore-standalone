describe("GlobalValueKeyValueStore", function()
    local eaw_env
    local require_utilities

    before_each(function()
        eaw_env = require("spec.eaw_env")
        eaw_env.setup_environment()

        require_utilities = require("spec.require_utilities")
        require_utilities.replace_require()
        require("deepcore/crossplot/GlobalValueKeyValueStore")
    end)

    after_each(function()
        eaw_env.teardown_environment()
        require_utilities.reset_require()
    end)

    describe("When storing simple value", function()
        it("should store value in GlobalValue", function()
            local kv_store = GlobalValueKeyValueStore()
            local global_value_spy = spy.on(GlobalValue, "Set")

            kv_store:store("key", "value")
            assert.spy(global_value_spy).was.called()
        end)

        it("should serialize value before storing it", function()
            local kv_store = GlobalValueKeyValueStore()

            kv_store:store("key", "value")

            local actual = loadstring(GlobalValue.Get("key"))()
            assert.are.equal("value", actual)
        end)

        describe("then retrieving it", function()
            it("should return stored value", function()
                local kv_store = GlobalValueKeyValueStore()
                kv_store:store("key", "value")

                assert.are.equal("value", kv_store:get("key"))
            end)
        end)
    end)

    describe("When storing table value", function()
        it("should serialize and store value in GlobalValue", function()
            local kv_store = GlobalValueKeyValueStore()

            local value = {value = 5, sub_table = {1, 2}}
            kv_store:store("key", value)

            local actual = loadstring(GlobalValue.Get("key"))()
            assert.are.same(value, actual)
        end)

        describe("then retrieving it", function()
            it("should return stored value", function()
                local kv_store = GlobalValueKeyValueStore()
                
                local value = {value = 5, sub_table = {1, 2}}
                kv_store:store("key", value)

                assert.are.same(value, kv_store:get("key"))
            end)
        end)
    end)

    describe("When freeing value", function()
        it("should set value to empty string", function()
            GlobalValue.Set("key", "value")
            local kv_store = GlobalValueKeyValueStore()

            kv_store:free("key")

            assert.are.equal("", GlobalValue.Get("key"))
        end)
    end)

    describe("When getting non-existing key", function()
        it("should return nil", function()
            local kv_store = GlobalValueKeyValueStore()

            local actual = kv_store:get("NON_EXISTING")
        
            assert.is_nil(actual)
        end)
    end)
end)