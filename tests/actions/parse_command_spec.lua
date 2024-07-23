local parse_command = require("alien.actions.action").parse_command

describe("parse_command", function()
	local cmd = "some command"
	local cmd_fn = function()
		return cmd
	end
	it("returns the command if it's a string", function()
		assert.equal(cmd, parse_command(cmd))
	end)
	it("returns the command if it's a function", function()
		assert.equal(cmd, parse_command(cmd_fn))
	end)
end)
