local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject }

--- Takes a command and returns an object type
---@param cmd string
---@return AlienObject
local function parse_object_type(cmd)
	local first_word = cmd:match("%w+")
	if first_word ~= "git" then
		return nil
	end
	local second_word = cmd:match("%S+%s+(%S+)")
	return require("alien.objects").get_object_type(second_word)
end

--- Takes a command and returns an Action function
---@param cmd string | fun(): string
---@param object_type string | nil
---@return Action
M.create_action = function(cmd, object_type)
	return function()
		if type(cmd) == "function" then
			local fn = function()
				return { output = { vim.fn.systemlist(cmd()) }, object_type = object_type or parse_object_type(cmd()) }
			end
			return fn()
		end
		local output = vim.fn.systemlist(cmd)
		return { output = output, object_type = object_type or parse_object_type(cmd) }
	end
end

return M
