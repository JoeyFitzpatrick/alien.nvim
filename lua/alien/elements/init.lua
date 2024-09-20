local keymaps = require("alien.keymaps")
local get_object_type = require("alien.objects").get_object_type
local register = require("alien.elements.register")
local autocmds = require("alien.elements.element-autocmds")

local M = {}

M.register = register

local set_buf_options = function(bufnr)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
end

---@param action Action
---@param element_params Element
---@return integer, AlienObject
local setup_element = function(action, element_params)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local result = action()
  local highlight = require("alien.highlight").get_highlight_by_object(result.object_type)
  element_params.bufnr = bufnr
  element_params.action = action
  element_params.highlight = highlight
  element_params.action_args = result.action_args
  if not element_params.object_type then
    element_params.object_type = result.object_type
  end
  register.register_element(element_params)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result.output)
  if highlight then
    highlight(bufnr)
  end
  set_buf_options(bufnr)
  autocmds.set_element_autocmds(bufnr)
  return bufnr, result.object_type
end

--- Create a new Element with the given action.
--- Also do some side effects, like setting keymaps, highlighting, and buffer local vars.
---@param action Action
---@param element_params Element
---@return integer
local function create(action, element_params)
  local new_bufnr, object_type = setup_element(action, element_params)
  keymaps.set_object_keymaps(new_bufnr, object_type)
  keymaps.set_element_keymaps(new_bufnr, element_params.element_type)
  if element_params.post_render then
    element_params.post_render(new_bufnr)
  end
  return new_bufnr
end

--- Create a new buffer with the given action, and open it in a floating window
---@param action Action
---@param opts vim.api.keyset.win_config | nil
---@return integer
M.float = function(action, opts)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  ---@type vim.api.keyset.win_config
  local default_float_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
  }
  local float_opts = vim.tbl_extend("force", default_float_opts, opts or {})
  local bufnr = create(action, { element_type = "float" })
  vim.api.nvim_open_win(bufnr, true, float_opts)
  return bufnr
end

--- Create a new buffer with the given action, and open it in a new split
---@param action Action
---@param opts vim.api.keyset.win_config | nil
---@param post_render fun(win: integer, bufnr?: integer) | nil
---@return integer
M.split = function(action, opts, post_render)
  ---@type vim.api.keyset.win_config
  local default_split_opts = {
    split = "right",
  }
  local float_opts = vim.tbl_extend("force", default_split_opts, opts or {})
  local bufnr = create(action, { element_type = "split" })
  local win = vim.api.nvim_open_win(bufnr, true, float_opts)
  if post_render then
    post_render(win, bufnr)
  end
  return bufnr
end

--- Create a new buffer with the given action, and open it in a target window
---@param action Action
---@param opts { winnr: integer | nil} | nil
---@return integer
M.buffer = function(action, opts)
  local default_buffer_opts = { winnr = vim.api.nvim_get_current_win() }
  local buffer_opts = vim.tbl_extend("force", default_buffer_opts, opts or {})
  local bufnr = create(action, { element_type = "buffer" })
  vim.api.nvim_win_set_buf(buffer_opts.winnr, bufnr)
  return bufnr
end

--- Run a command in a new terminal
---@param cmd string | nil
---@param opts {window: vim.api.keyset.win_config | nil, enter: boolean | nil, dynamic_resize: boolean | nil, skip_redraw: boolean | nil } | nil
---@return integer | nil
M.terminal = function(cmd, opts)
  if not cmd then
    return
  end
  opts = opts or {}
  ---@type vim.api.keyset.win_config | { enter: boolean | nil }
  local default_terminal_opts = { split = "right" }
  local terminal_opts = vim.tbl_extend("force", default_terminal_opts, opts.window or {})
  local bufnr = vim.api.nvim_create_buf(false, true)
  local window = vim.api.nvim_open_win(bufnr, opts.enter, terminal_opts)
  local channel_id = nil
  vim.api.nvim_buf_call(bufnr, function()
    if not opts.dynamic_resize then
      channel_id = vim.fn.termopen(cmd, {
        on_exit = function()
          if not opts.skip_redraw then
            register.redraw_elements()
          end
        end,
      })
    else
      local height = 2
      vim.api.nvim_win_set_height(window, height)
      channel_id = vim.fn.termopen(cmd, {
        on_stdout = function()
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local empty_lines = vim.tbl_filter(function(line)
            return line == ""
          end, lines)
          if #lines - #empty_lines + 1 > height then
            height = #lines - #empty_lines + 1
          end
          vim.api.nvim_win_set_height(window, height)
        end,
        on_exit = function()
          vim.schedule(function()
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local lines_to_delete = vim.tbl_filter(function(line)
              return line == ""
            end, lines)
            vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
            vim.api.nvim_buf_set_lines(bufnr, #lines - #lines_to_delete, -1, false, {})
            vim.api.nvim_win_set_height(window, #lines - #lines_to_delete + 1)
            vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
          end)
          if not opts.skip_redraw then
            register.redraw_elements()
          end
        end,
      })
    end
  end)
  local object_type = get_object_type(cmd)
  if not channel_id then
    error("Failed to open terminal")
  end
  register.register_element({
    element_type = "terminal",
    bufnr = bufnr,
    channel_id = channel_id,
    object_type = object_type,
  })
  autocmds.set_element_autocmds(bufnr)
  keymaps.set_element_keymaps(bufnr, "terminal")
  return bufnr
end

return M
