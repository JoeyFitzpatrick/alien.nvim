local register = require("alien.elements.register")

describe("register_elements", function()
    before_each(function()
        register.elements = {}
    end)
    it("should register an element", function()
        local element = { bufnr = -1, win = -1, object_type = "status", element_type = "buffer" }
        register.register_element(element)
        assert.are.same(register.elements, { element })
    end)
    it("should throw an error if an element doesn't have necessary properties", function()
        local element = { win = -1, object_type = "status", element_type = "buffer" }
        local ok, _ = pcall(register.register_element, element)
        assert.are.equal(false, ok)
        assert.are.same({}, register.elements)
    end)
    it("should throw an error if a terminal element doesn't have channel id", function()
        local element = { bufnr = -1, win = -1, object_type = "diff", element_type = "terminal" }
        local ok, _ = pcall(register.register_element, element)
        assert.are.equal(false, ok)
        assert.are.same({}, register.elements)
    end)
    it("should register terminal element if it has a channel id", function()
        local element = { bufnr = -1, win = -1, object_type = "diff", element_type = "terminal", channel_id = -1 }
        register.register_element(element)
        assert.are.same({ element }, register.elements)
    end)
end)
