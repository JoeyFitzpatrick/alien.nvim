local action = require("alien.actions").action

describe("action", function()
  local cmd_fn = function()
    return "echo hello"
  end
  it("returns an table that contains output", function()
    local action_result = action(cmd_fn)
    assert.same("hello", action_result.output[1])
  end)
  it("returns an result with the command's object type", function()
    local git_diff = function()
      return "git diff"
    end
    local action_result = action(git_diff)
    assert.are.same("diff", action_result.object_type)
  end)
end)
