local get_command_strategy = require("alien.command-mode").get_command_strategy

describe("get_command_strategy", function()
  it("returns the command strategy for a given command", function()
    assert.are.equal("print", get_command_strategy("git add"))
  end)
end)
