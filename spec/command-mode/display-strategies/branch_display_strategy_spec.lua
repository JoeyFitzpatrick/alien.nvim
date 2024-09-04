local get_branch_strategy = require("alien.command-mode.display-strategies.branch").get_strategy
local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

describe("get_branch_strategy", function()
  it("returns 'print' for commands that should print output", function()
    local result = get_branch_strategy("git branch --delete mockbranch")
    assert.are.equal(result, DISPLAY_STRATEGIES.PRINT)
  end)
  it("returns 'ui' for commands that have no options", function()
    local result = get_branch_strategy("git branch")
    assert.are.equal(result, DISPLAY_STRATEGIES.UI)
  end)
  it("returns 'ui' for commands that should use ui output", function()
    local result = get_branch_strategy("git branch --list")
    assert.are.equal(result, DISPLAY_STRATEGIES.UI)
  end)
end)
