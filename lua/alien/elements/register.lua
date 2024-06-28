--!strict
local M = {}

---@alias ElementType "tab" | "split" | "float" | "buffer" | "terminal"
---@alias BaseElement {element_type: "split" | "float" | "buffer", bufnr: integer, object_type: AlienObject, child_elements: BaseElement[]}
---@alias TabElement {element_type: "tab", tabnr: integer, bufnr: integer, object_type: AlienObject, child_elements: BaseElement[]}
---@alias TerminalElement {element_type: "terminal", channel_id: integer, bufnr: integer, object_type: AlienObject}
---@alias Element BaseElement | TabElement | TerminalElement

---@type Element[]
M.elements = {}

---@return Element | nil
M.get_current_element = function()
	local bufnr = vim.api.nvim_get_current_buf()
	return vim.tbl_filter(function(element)
		return element.bufnr == bufnr
	end, M.elements)[1]
end

---@param opts {bufnr: integer | nil, object_type: AlienObject | nil, element_type: ElementType | nil }
M.get_elements = function(opts)
	if opts.bufnr then
		return vim.tbl_filter(function(element)
			return element.bufnr == opts.bufnr
		end, M.elements)
	end
	return vim.tbl_filter(function(element)
		return (not opts.object_type or element.object_type == opts.object_type)
			and (not opts.element_type or element.element_type == opts.element_type)
	end, M.elements)
end

---@param opts { object_type: AlienObject | nil, element_type: ElementType | nil } | nil
M.get_child_elements = function(opts)
	opts = opts or {}
	local current_element = M.get_current_element()
	if not current_element then
		return {}
	end
	return vim.tbl_filter(function(element)
		return (opts.object_type == nil or opts.object_type == element.object_type)
			and (opts.element_type == nil or opts.element_type == element.element_type)
	end, current_element.child_elements)
end

--- Register a new element
---@param params Element
M.register_element = function(params)
	params.child_elements = {}
	local current_element = M.get_current_element()
	if params.element_type == "tab" then
		local tabnr = vim.api.nvim_get_current_tabpage()
		params.tabnr = tabnr
		table.insert(M.elements, params)
	elseif params.element_type == "terminal" then
		if not params.channel_id then
			error("channel_id is required for terminal elements")
		end
		table.insert(M.elements, params)
		if current_element then
			table.insert(current_element.child_elements, params)
		end
	else
		table.insert(M.elements, params)
		if current_element then
			table.insert(current_element.child_elements, params)
		end
	end
end

--- Deregsiter an element.
--- Note that child elements are only deregistered one level deep.
--- TODO: make this recursive
---@param bufnr integer
---@return nil
M.deregister_element = function(bufnr)
	local filter = function(element)
		return element.bufnr ~= bufnr
	end
	for _, element in ipairs(M.elements) do
		element.child_elements = vim.tbl_filter(filter, element.child_elements)
	end
	M.elements = vim.tbl_filter(filter, M.elements)
end

---@param bufnr integer
M.close_element = function(bufnr)
	local element = vim.tbl_filter(function(element)
		return element.bufnr == bufnr
	end, M.elements)[1]
	if not element then
		return nil
	end
	for _, buffer in ipairs(element.child_elements) do
		M.deregister_element(buffer.bufnr)
		vim.api.nvim_buf_delete(buffer.bufnr, { force = true })
	end
	M.deregister_element(bufnr)
	vim.api.nvim_buf_delete(bufnr, { force = true })
end

---@param opts { object_type: AlienObject | nil, element_type: ElementType | nil }
M.close_child_elements = function(opts)
	local current_element = M.get_current_element()
	if not current_element then
		return {}
	end
	local elements = M.get_child_elements(opts)
	vim.print(vim.inspect(elements))
	for _, buffer in ipairs(elements) do
		M.deregister_element(buffer.bufnr)
		vim.api.nvim_buf_delete(buffer.bufnr, { force = true })
	end
end

return M