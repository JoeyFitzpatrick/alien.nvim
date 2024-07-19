local add_flags = require("alien.actions.commands").add_flags

describe("add_flags", function()
	local cmd = "some command"
	it("adds flags to a command", function()
		local flags = "--flag1 --flag2"
		local expected = cmd .. " " .. flags
		assert.equals(expected, add_flags(cmd, flags))
	end)
	it("returns the command if flags string is empty", function()
		local flags = ""
		local expected = cmd
		assert.equals(expected, add_flags(cmd, flags))
	end)
	it("returns the command if flags is nil", function()
		local flags = nil
		local expected = cmd
		assert.equals(expected, add_flags(cmd, flags))
	end)
end)
