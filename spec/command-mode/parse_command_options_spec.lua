local parse_command_options = require("alien.command-mode.utils").parse_command_options

describe("parse_command_options", function()
    it("returns the options for a given git command", function()
        local result = parse_command_options("git log -n 1")
        assert.are.same(result, { "-n", "1" })
    end)
end)
