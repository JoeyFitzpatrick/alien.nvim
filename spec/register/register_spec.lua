local register = require("alien.elements.register")

describe("register", function()
    before_each(function()
        register.elements = {
            { bufnr = 1, child_elements = { { bufnr = 2, child_elements = {} } } },
            { bufnr = 2, child_elements = {} },
        }
    end)
    it("should close an element, and its child elements", function()
        register.close_element(1)
        assert.are.same(register.elements, {})
    end)
    it("should deregister a child element", function()
        register.deregister_element(2)
        assert.are.same(register.elements, { { bufnr = 1, child_elements = {} } })
    end)
end)
