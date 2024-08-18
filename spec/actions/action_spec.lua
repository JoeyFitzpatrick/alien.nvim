local action = require("alien.actions.action").action
local register = require("alien.elements.register")

describe("action", function()
  local cmd_fn = function()
    return "echo hello"
  end
  it("returns a function", function()
    assert.same("function", type(action(cmd_fn)))
  end)
  it("returns an action that contains output", function()
    local action_fn = action(cmd_fn)
    assert.same("hello", action_fn().output[1])
  end)
  it("returns an action with the command's object type", function()
    local git_diff = function()
      return "git diff"
    end
    local action_fn = action(git_diff)
    assert.are.same("diff", action_fn().object_type)
  end)
end)
