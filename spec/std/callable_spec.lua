describe("callable", function()
    describe("When calling callable table", function()
        it("should call the call function", function()
            require("std.callable")
            local table_data = {
                call = spy.new(function() return "value" end)
            }

            local callable_table = callable(table_data)
            local return_value = callable_table("args")

            assert.spy(table_data.call).was.called_with(table_data, "args")
            assert.are.equal("value", return_value)
        end)
    end)
end)