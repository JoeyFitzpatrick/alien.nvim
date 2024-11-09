local extract = require("alien.extractors.").extract

local TEST_STRING = "123abcd JF chore: some commit msg"
local EXPECTED = { hash = "123abcd", start = 0, ending = 7 }

describe("extract", function()
  before_each(function()
    vim.api.nvim_get_current_line = function()
      return TEST_STRING
    end
    require("alien.elements.register").get_current_element = function()
      return { object_type = "commit" }
    end
  end)
  it("should return git information when object type and str to search are passed in", function()
    assert.are.same(EXPECTED, extract("commit", TEST_STRING))
  end)
  it("should return git information when object type is not passed in", function()
    assert.are.same(EXPECTED, extract(nil, TEST_STRING))
  end)
  it("should return git information when str is not passed in", function()
    assert.are.same(EXPECTED, extract("commit"))
  end)
  it("should return git information when neither object_type and str are passed in", function()
    assert.are.same(EXPECTED, extract())
  end)
  it("should return nil when object type is incorrect", function()
    assert.are.equal(nil, extract("nope"))
  end)
  it(
    "should return nil when object_type could not be parsed (e.g. not passed in and not currently in alien element)",
    function()
      require("alien.elements.register").get_current_element = function()
        return nil
      end
      assert.are.equal(nil, extract(nil, TEST_STRING))
    end
  )
  it("should return nil when str could not be parsed", function()
    assert.are.equal(nil, extract("commit", "some random string"))
  end)
end)
