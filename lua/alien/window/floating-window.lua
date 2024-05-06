local M = {}

---@param lines string[]
---@param post_render_callback function | nil
---@param opts { delete_on_close: boolean | nil} | nil
---@return nil
M.create = function(lines, post_render_callback, opts)
	opts = opts or {}
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(bufnr, true, {
		relative = "win",
		width = 70,
		height = 20,
		row = 0,
		col = 0,
		style = "minimal",
		border = "none",
	})
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.keymap.set("n", "q", ":q<CR>", { nowait = true, noremap = true, silent = true, buffer = bufnr })
	if post_render_callback then
		post_render_callback(bufnr)
	end
end

return M
