local M = {}
M.load_plugin = function(plugin_name)
	local status, plugin = pcall(require, plugin_name)
	if not status then
		error("Error loading plugin: " .. plugin_name)
		return
	end
	return plugin
end
M.reload_named_buffers = function()
	local buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd([[e!]])
			end)
		end
	end
end
M.buf_set_temporary = function(bufnr, opts)
	opts = opts or {}
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
	if opts.filetype then
		vim.api.nvim_set_option_value("filetype", opts.filetype, { buf = bufnr })
	end
	if opts.keymaps then
		for _, keymap in ipairs(opts.keymaps) do
			vim.keymap.set(keymap[1], keymap[2], keymap[3], { buffer = bufnr })
		end
	end
end
--- Get the width of the current tab
---@return number
M.get_tab_width = function()
	local width = 0
	for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		width = width + vim.api.nvim_win_get_width(win_id)
	end
	return width
end
M.copy = function(obj, seen)
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do
		res[M.copy(k, s)] = M.copy(v, s)
	end
	return res
end

M.dump = function(output)
	if type(output) == "table" then
		local s = "{ "
		for k, v in pairs(output) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(output)
	end
end
M.table_to_string = function(tbl)
	local s = { "return {" }
	for i = 1, #tbl do
		s[#s + 1] = "{"
		for j = 1, #tbl[i] do
			s[#s + 1] = tbl[i][j]
			s[#s + 1] = ","
		end
		s[#s + 1] = "},"
	end
	s[#s + 1] = "}"
	return s
end
M.next_index = function(t, value)
	local index = nil
	for i, v in ipairs(t) do
		if v == value then
			index = i
			break
		end
	end
	if index then
		return (index % #t) + 1
	end
end
M.prev_index = function(t, value)
	local index = nil
	for i, v in ipairs(t) do
		if v == value then
			index = i
			break
		end
	end
	if index then
		return (index - 2) % #t + 1
	end
end
return M
