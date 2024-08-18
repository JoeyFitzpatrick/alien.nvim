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

describe("get_current_element", function()
  it("should return the element with the bufnr of the current buffer", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    local mock_element = { bufnr = buf, child_elements = {}, object_type = "diff" }
    register.elements = { mock_element }
    assert.are.same(mock_element, register.get_current_element())
  end)
end)
