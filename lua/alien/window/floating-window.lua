local M = {}

---@param lines string[]
---@param post_render_callback function | nil
---@param opts { delete_on_close: boolean | nil} | nil
---@return nil
M.create = function(lines, post_render_callback, opts)
	opts = opts or {}
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
	})
	vim.keymap.set("n", "q", ":q<CR>", { nowait = true, noremap = true, silent = true, buffer = bufnr })
	if post_render_callback then
		post_render_callback(bufnr)
	end
end

return M
