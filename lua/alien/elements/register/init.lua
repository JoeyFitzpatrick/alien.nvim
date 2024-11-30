--!strict
local M = {}

---@type Element[]
M.elements = {}

---@param bufnr integer
---@return Element | nil
M.get_element = function(bufnr)
    return vim.tbl_filter(function(element)
        return element.bufnr == bufnr
    end, M.elements)[1]
end

---@return Element | nil
M.get_current_element = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local result = nil
    result = M.get_element(bufnr)
    if not result then
        result = vim.tbl_filter(function(element)
            return element.win == win
        end, M.elements)[1]
    end
    return result
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

local element_schema = {
    bufnr = "number",
    win = "number",
    element_type = "string",
}

--- Register a new element
---@param params Element | TerminalElement
M.register_element = function(params)
    require("alien.utils").validate(params, element_schema)
    params.child_elements = {}
    local current_element = M.get_current_element()
    if params.element_type == "terminal" and not params.channel_id then
        error("channel_id is required for terminal elements")
    end
    table.insert(M.elements, params)
    if current_element then
        table.insert(current_element.child_elements, params)
    end
end

---@param elements Element[]
---@param target_bufnr integer
local function remove_bufnr(elements, target_bufnr)
    for i = #elements, 1, -1 do
        if elements[i].bufnr == target_bufnr then
            table.remove(elements, i)
        else
            if elements[i].child_elements then
                remove_bufnr(elements[i].child_elements, target_bufnr)
            end
        end
    end
end

--- Deregsiter an element.
---@param bufnr integer
---@return nil
M.deregister_element = function(bufnr)
    remove_bufnr(M.elements, bufnr)
end

---@param element Element
local function close_element_and_children(element)
    if #element.child_elements > 0 then
        for _, child_element in ipairs(element.child_elements) do
            close_element_and_children(child_element)
        end
    end
    M.deregister_element(element.bufnr)
    if vim.api.nvim_buf_is_valid(element.bufnr) then
        vim.api.nvim_buf_delete(element.bufnr, { force = true })
    end
end

---@param bufnr integer
M.close_element = function(bufnr)
    local element = vim.tbl_filter(function(element)
        return element.bufnr == bufnr
    end, M.elements)[1]
    if not element then
        return nil
    end
    close_element_and_children(element)
end

---@param opts { object_type: AlienObject | nil, element_type: ElementType | nil }
M.close_child_elements = function(opts)
    local current_element = M.get_current_element()
    if not current_element then
        return {}
    end
    local elements = M.get_child_elements(opts)
    for _, buffer in ipairs(elements) do
        M.deregister_element(buffer.bufnr)
        vim.api.nvim_buf_delete(buffer.bufnr, { force = true })
    end
end

M.redraw_elements_logic = function()
    for _, element in ipairs(M.elements) do
        -- some elements (like terminals) don't have actions
        local ok, result = pcall(element.action)
        if not ok or not result then
            goto continue
        end
        vim.api.nvim_set_option_value("modifiable", true, { buf = element.bufnr })
        vim.api.nvim_buf_set_lines(element.bufnr, 0, -1, false, result.output)
        vim.api.nvim_set_option_value("modifiable", false, { buf = element.bufnr })
        element.state = result.state
        if element.highlight then
            element.highlight(element.bufnr)
        end
        ::continue::
    end
end

--TODO: Make this function redraw current element immediately, then redraw the rest async
M.redraw_elements = function()
    vim.schedule(M.redraw_elements_logic)
end

return M
