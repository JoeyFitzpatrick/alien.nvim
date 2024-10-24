--!strict
local M = {}

---@alias ElementType "tab" | "split" | "float" | "buffer" | "terminal"
---@alias BaseElement {element_type: "split" | "float" | "buffer", bufnr: integer, object_type: AlienObject, child_elements: BaseElement[], action_args: table, action: Action, post_render: fun(bufnr: integer) | nil, highlight: fun(bufnr: integer): nil}
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
  if params.element_type == "terminal" then
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

M.redraw_elements = function()
  for _, element in ipairs(M.elements) do
    -- some elements (like terminals) don't have actions
    local ok, result = pcall(element.action)
    if not ok then
      goto continue
    end
    vim.api.nvim_set_option_value("modifiable", true, { buf = element.bufnr })
    vim.api.nvim_buf_set_lines(element.bufnr, 0, -1, false, result.output)
    vim.api.nvim_set_option_value("modifiable", false, { buf = element.bufnr })
    if element.highlight then
      element.highlight(element.bufnr)
    end
    ::continue::
  end
end

return M
