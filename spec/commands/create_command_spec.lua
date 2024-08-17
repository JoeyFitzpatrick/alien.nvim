local create_command = require("alien.actions.commands").create_command

describe("create command", function()
  it("creates command from a string by returning the string", function()
    assert.are.equal("test command", create_command("test command"))
  end)
  it("creates command function from a function by passing arg to the function", function()
    local cmd_fn = function(arg)
      return "command with " .. arg
    end
    local result = create_command(cmd_fn, function()
      return "arg"
    end)()
    assert.are.equal("command with arg", result)
  end)
  it("passes multiple arguments to command function", function()
    local cmd_fn = function(arg1, arg2)
      return "command with " .. arg1 .. " " .. arg2
    end
    local result = create_command(cmd_fn, function()
      return "arg1", "arg2"
    end)()
    assert.are.equal("command with arg1 arg2", result)
  end)
  it("optionally accepts an input arg after the get_args fn", function()
    local cmd_fn = function(arg1, arg2)
      return "command with " .. arg1 .. " " .. arg2
    end
    local result = create_command(cmd_fn, function()
      return "arg1"
    end, "some input")()
    assert.are.equal("command with arg1 some input", result)
  end)
  it("throws an error if get_args returns nil", function()
    local cmd_fn = function(arg)
      return "command with " .. arg
    end
    local get_args = function()
      return nil
    end
    local command_fn = create_command(cmd_fn, get_args)
    local ok = pcall(command_fn)
    assert.are.equal(false, ok)
  end)
  it("throws an error if get_args is not passed for function command", function()
    local cmd_fn = function(arg)
      return "command with " .. arg
    end
    local ok = pcall(create_command, cmd_fn)
    assert.are.equal(false, ok)
  end)
end)
