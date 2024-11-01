local keymaps = require("alien.keymaps")
local get_object_type = require("alien.objects").get_object_type
local register = require("alien.elements.register")
local autocmds = require("alien.elements.element-autocmds")

---@alias ElementType "tab" | "split" | "float" | "buffer" | "terminal"

---@class Element
---@field win? integer
---@field bufnr integer
---@field output_handler? fun(lines: string[]): string[]
---@field post_render? fun(bufnr: integer): nil
---@field element_type? ElementType
---@field object_type? AlienObject
---@field child_elements? Element[]
---@field action Action
---@field highlight fun(bufnr: integer): nil
---@field cmd string
---@field channel_id? string

local M = {}

M.register = register

local set_buf_options = function(bufnr)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
end

---@param cmd string
---@param opts Element
---@return integer, AlienObject
local setup_element = function(cmd, opts)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local result = require("alien.actions").action(cmd, opts)
  if not result then
    error("action returned nil")
  end
  local highlight = require("alien.highlight").get_highlight_by_object(result.object_type)
  opts.bufnr = bufnr
  opts.win = vim.api.nvim_get_current_win()
  opts.action = function()
    return require("alien.actions").action(cmd, opts)
  end
  opts.highlight = highlight
  if not opts.object_type then
    opts.object_type = result.object_type
  end
  register.register_element(opts)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result.output)
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  if highlight then
    highlight(bufnr)
  end
  set_buf_options(bufnr)
  autocmds.set_element_autocmds(bufnr)
  return bufnr, result.object_type
end

--- Create a new Element with the given action.
--- Also do some side effects, like setting keymaps, highlighting, and buffer local vars.
---@param cmd string
---@param opts Element
---@return integer
local function create(cmd, opts)
  local new_bufnr, object_type = setup_element(cmd, opts)
  keymaps.set_object_keymaps(new_bufnr, object_type)
  keymaps.set_element_keymaps(new_bufnr, opts.element_type)
  if opts.post_render then
    opts.post_render(new_bufnr)
  end
  return new_bufnr
end

local function post_create_co()
  -- Utilize a coroutine to run the function asynchronously
  local co = coroutine.create(function()
    local handle = io.popen("git fetch --dry-run 2>&1") -- Including stderr in the output stream
    local result = handle:read("*a") -- 'read('*a')' reads the full output of the command
    handle:close()

    if not result or result:match("^%s*$") then
      return
    end

    local fetch_handle = io.popen("git fetch")
    fetch_handle:close()
    register.redraw_elements()
  end)

  -- Wrap coroutine execution in a vim timer to ensure non-blocking behavior
  -- This runs the coroutine asynchronously in such a way that it doesn't block UI
  vim.loop.new_timer():start(
    0,
    0,
    vim.schedule_wrap(function()
      local status, error = coroutine.resume(co)
      if not status then
        print("Error during async git fetch: " .. tostring(error))
      end
    end)
  )
end

--- Create a new buffer with the given action, and open it in a floating window
---@param cmd string
---@param opts vim.api.keyset.win_config | nil
---@return integer | nil
M.float = function(cmd, opts)
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
  local ok, bufnr = pcall(create, cmd, { element_type = "float" })
  if not ok then
    return nil
  end
  vim.api.nvim_open_win(bufnr, true, float_opts)
  -- post_create()
  return bufnr
end

--- Create a new buffer with the given action, and open it in a new split
---@param cmd string
---@param opts vim.api.keyset.win_config | nil
---@param post_render fun(win: integer, bufnr?: integer) | nil
---@return integer | nil
M.split = function(cmd, opts, post_render)
  ---@type vim.api.keyset.win_config
  local default_split_opts = {
    split = "right",
  }
  local split_opts = vim.tbl_extend("force", default_split_opts, opts or {})
  local ok, bufnr = pcall(create, cmd, { element_type = "split" })
  if not ok then
    return nil
  end
  local win = vim.api.nvim_open_win(bufnr, true, split_opts)
  if post_render then
    post_render(win, bufnr)
  end
  -- post_create()
  return bufnr
end

--- Create a new buffer with the given action, and open it in a target window
---@param cmd string
---@param opts Element | nil
---@param post_render fun(win: integer, bufnr?: integer) | nil
---@return integer | nil
M.buffer = function(cmd, opts, post_render)
  opts = opts or {}
  local bufnr = create(cmd, vim.tbl_extend("error", { element_type = "buffer" }, opts))
  -- local ok, bufnr = pcall(create, cmd, { element_type = "buffer" })
  -- if not ok then
  --   return nil
  -- end
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.cmd("silent only")
  if post_render then
    post_render(0, bufnr)
  end
  post_create_co()
  return bufnr
end

--- Create a new buffer with the given action, and open it in a new tab
---@param cmd string
---@return integer | nil
M.tab = function(cmd)
  local ok, bufnr = pcall(create, cmd, { element_type = "tab" })
  if not ok then
    return nil
  end
  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, bufnr)
  post_create_co()
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
    win = vim.api.nvim_get_current_win(),
    channel_id = channel_id,
    object_type = object_type,
  })
  autocmds.set_element_autocmds(bufnr)
  keymaps.set_element_keymaps(bufnr, "terminal")
  return bufnr
end

return M
