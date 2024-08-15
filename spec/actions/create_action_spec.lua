local create_action = require("alien.actions.action").create_action

local function output(str1, str2)
	return { output = { str1, str2 } }
end

describe("create_action", function()
	local cmd = "echo hello"
	it("runs a command string", function()
		assert.same(output("hello"), create_action(cmd)())
	end)
	it("runs a command function", function()
		assert.same(
			output("hello"),
			create_action(function()
				return cmd
			end)()
		)
	end)
	it("uses output handler", function()
		assert.same(
			output("hello", "world"),
			create_action(cmd, {
				output_handler = function(lines)
					return { unpack(lines), "world" }
				end,
			})()
		)
	end)
end)
