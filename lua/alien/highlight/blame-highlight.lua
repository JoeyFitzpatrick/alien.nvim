local DATE_FORMAT = "--date=format-local:'%A, %Y/%m/%d, %I:%M %p'" -- current user's timezone

local M = {}

--- convert a commit hash to a hex color to color the hash
---@param hash string
local function commit_hash_to_hex(hash)
	local stripped_hash = hash:gsub("%d", "")
	if #hash < 6 then
		return { hex = "", stripped_hash = stripped_hash }
	end
	return { hex = "#" .. hash:sub(1, 6), stripped_hash = stripped_hash }
end

M.highlight = function(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i, line in ipairs(lines) do
		local first_word = line:match("%S+")
		if not first_word then
			goto continue
		end
		local hex_obj = commit_hash_to_hex(first_word)
		vim.print(hex_obj.stripped_hash)
		vim.cmd(string.format("highlight %s guifg=%s", "AlienBlameHash" .. hex_obj.stripped_hash, hex_obj.hex))
		vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienBlameHash" .. hex_obj.stripped_hash, i - 1, 0, #first_word)

		local timestamp_pattern = "%d%d%d%d/%d%d/%d%d %d%d:%d%d %a%a"
		local start_index, end_index = line:find(timestamp_pattern)
		if start_index and end_index then
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienBlameDate", i - 1, start_index - 1, end_index)
		end
	end
	::continue::
end

return M
