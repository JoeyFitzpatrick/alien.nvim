local register = require("alien.elements.register")

describe("get_child_elements", function()
    local mock_child_elements = {
        { bufnr = -1, object_type = "status", element_type = "buffer", child_elements = {} },
        { bufnr = -1, object_type = "diff", element_type = "buffer", child_elements = {} },
        { bufnr = -1, object_type = "status", element_type = "split", child_elements = {} },
        { bufnr = -1, object_type = "diff", element_type = "split", child_elements = {} },
    }
    before_each(function()
        require("alien.elements.register").get_current_element = function()
            return { child_elements = mock_child_elements }
        end
    end)
    it("should return the child elements of the current element", function()
        assert.are.same(mock_child_elements, register.get_child_elements())
    end)
    it("should return the child elements that match the given object type", function()
        local expected = { mock_child_elements[2], mock_child_elements[4] }
        assert.are.same(expected, register.get_child_elements({ object_type = "diff" }))
    end)
    it("should return the child elements that match the given element type", function()
        local expected = { mock_child_elements[3], mock_child_elements[4] }
        assert.are.same(expected, register.get_child_elements({ element_type = "split" }))
    end)
    it("should return the child elements that match the given element type and object type", function()
        local expected = { mock_child_elements[4] }
        assert.are.same(expected, register.get_child_elements({ object_type = "diff", element_type = "split" }))
    end)
    it("should return empty table when no child elements match", function()
        assert.are.same({}, register.get_child_elements({ object_type = "blame" }))
    end)
    it("should return empty table when no current element is found", function()
        require("alien.elements.register").get_current_element = function()
            return nil
        end
        assert.are.same({}, register.get_child_elements())
    end)
end)
