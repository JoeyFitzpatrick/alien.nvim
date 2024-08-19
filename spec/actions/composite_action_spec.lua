local composite_action = require("alien.actions.action").composite_action

describe("composite_action", function()
  it("returns the output of multiple commands", function()
    local cmd_fn_1 = function()
      return "echo hello"
    end
    local cmd_fn_2 = function()
      return "echo goodbye"
    end
    assert.same({ "hello", "goodbye" }, composite_action({ cmd_fn_1, cmd_fn_2 })().output)
  end)
  it("returns the object type of the final command", function()
    local cmd_fn_1 = function()
      return "git log -n 1"
    end
    local cmd_fn_2 = function()
      return "git diff"
    end
    assert.same("diff", composite_action({ cmd_fn_1, cmd_fn_2 })().object_type)
  end)
end)
