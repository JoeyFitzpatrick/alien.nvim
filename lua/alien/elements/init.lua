local get_object_type = require("alien.objects").get_object_type
local register = require("alien.elements.register")
local autocmds = require("alien.autocmds")

---@alias ElementType "tab" | "split" | "float" | "buffer" | "terminal"

---@class BaseOpts
---@field object_type? AlienObject

---@class ElementParams: BaseOpts
---@field output_handler? fun(lines: string[]): string[]
---@field post_render? fun(bufnr: integer): nil
---@field highlight? fun(bufnr: integer): nil
---@field buffer_name? string
---@field state? table<string, any>

---@class Element: ElementParams
---@field win? integer
---@field bufnr integer
---@field element_type? ElementType
---@field child_elements? Element[]
---@field action AlienAction
---@field highlight fun(bufnr: integer): nil
---@field channel_id? string
---@field state? table<string, any>

---@class TerminalElement
---@field win? integer
---@field bufnr integer
---@field element_type? ElementType
---@field child_elements? Element[]
---@field channel_id? string

local M = {}

M.register = register

local set_buf_options = function(bufnr)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
end

local function highlight_element(bufnr, highlight)
    if highlight then
        highlight(bufnr)
    end
end

--- Turn ElementParams into Element
---@param cmd string
---@param opts ElementParams
---@param bufnr integer
---@param result ActionResult
---@return Element
M._set_element_opts = function(cmd, opts, bufnr, result, highlight)
    ---@cast opts Element
    opts.action = function()
        return require("alien.actions").action(cmd, opts)
    end
    opts.bufnr = bufnr
    opts.win = vim.api.nvim_get_current_win()
    opts.highlight = highlight

    if not opts.object_type then
        opts.object_type = result.object_type
    end
    opts.state = result.state
    return opts
end

--- Set buffer name
---@param bufnr integer
---@param object_type AlienObject
---@param buffer_name? string
local function set_buffer_name(bufnr, object_type, buffer_name)
    if buffer_name ~= nil then
        vim.api.nvim_buf_set_name(bufnr, "alien://" .. os.tmpname() .. "/" .. buffer_name)
    else
        vim.api.nvim_buf_set_name(bufnr, "alien://" .. os.tmpname() .. "/" .. object_type)
    end
end

---@param cmd string
---@param opts ElementParams
---@return integer?, Element?
local setup_element = function(cmd, opts)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local result = require("alien.actions").action(cmd, opts)
    if not result then
        return
    end
    local highlight = opts.highlight and opts.highlight
        or require("alien.highlight").get_highlight_by_object(result.object_type)
    opts = M._set_element_opts(cmd, opts, bufnr, result, highlight)

    register.register_element(opts)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result.output)
    vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    highlight_element(bufnr, highlight)
    set_buf_options(bufnr)
    return bufnr, opts
end

--- Create a new Element with the given action.
--- Also do some side effects, like setting keymaps, highlighting, and buffer local vars.
---@param cmd string
---@param opts ElementParams
---@return integer | nil
local function create(cmd, opts)
    local new_bufnr, element = setup_element(cmd, opts)
    if new_bufnr == nil or element == nil then
        return
    end
    require("alien.keymaps").set_object_keymaps(new_bufnr, element.object_type)
    require("alien.keymaps").set_element_keymaps(new_bufnr, element.element_type)
    autocmds.set_element_autocmds(new_bufnr)
    if opts.post_render then
        opts.post_render(new_bufnr)
    end
    set_buffer_name(new_bufnr, element.object_type, opts.buffer_name)
    return new_bufnr
end

---@param bufnr integer
local function post_create_co(bufnr)
    local should_run_fetch = false
    local co = coroutine.create(function()
        if not should_run_fetch then
            return
        end
        require("alien.ui").start_spinner(bufnr, 0)
        vim.system({ "git", "fetch" }, { text = true }, function()
            register.redraw_elements()
            require("alien.ui").stop_spinner(bufnr)
        end)
    end)

    vim.system({ "git", "fetch", "--dry-run" }, { text = true }, function(result)
        if result.stderr:len() > 0 and result.code == 0 then
            should_run_fetch = true
            coroutine.resume(co)
        end
    end)
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
    local ok, result = xpcall(create, debug.traceback, cmd, { element_type = "float" })
    if not ok then
        vim.notify(result, vim.log.levels.ERROR)
        return nil
    end
    local bufnr = result
    if not bufnr then
        return
    end
    vim.api.nvim_open_win(bufnr, true, float_opts)
    -- post_create()
    return bufnr
end

--- Create a new buffer with the given action, and open it in a new split
---@param cmd string
---@param opts { split_opts: vim.api.keyset.win_config | nil } | nil
---@param post_render fun(win: integer, bufnr?: integer) | nil
---@return integer | nil
M.split = function(cmd, opts, post_render)
    ---@type vim.api.keyset.win_config
    local default_split_opts = {
        split = "right",
    }
    local split_opts = vim.tbl_extend("force", default_split_opts, opts and opts.split_opts or {})
    local ok, result = pcall(create, cmd, vim.tbl_extend("error", { element_type = "split" }, opts))
    -- local ok, result = xpcall(create, debug.traceback, cmd, vim.tbl_extend("error", { element_type = "split" }, opts))
    if not ok then
        vim.notify(result, vim.log.levels.ERROR)
        return nil
    end
    local bufnr = result
    if not bufnr then
        return
    end
    local win = vim.api.nvim_open_win(bufnr, true, split_opts)
    if post_render then
        post_render(win, bufnr)
    end
    return bufnr
end

--- Create a new window with the given action
---@param cmd string
---@param opts ElementParams | nil
---@param post_render fun(win: integer, bufnr?: integer) | nil
---@return integer | nil
M.window = function(cmd, opts, post_render)
    opts = opts or {}
    local ok, result = xpcall(create, debug.traceback, cmd, vim.tbl_extend("error", { element_type = "buffer" }, opts))
    if not ok then
        vim.notify(result, vim.log.levels.ERROR)
        return nil
    end
    local bufnr = result
    if not bufnr then
        return
    end
    vim.api.nvim_win_set_buf(0, bufnr)
    if post_render then
        post_render(0, bufnr)
    end
    post_create_co(bufnr)
    return bufnr
end

--- Create a new buffer with the given action, and open it in a new tab
---@param cmd string
---@return integer | nil
M.tab = function(cmd)
    local ok, result = xpcall(create, debug.traceback, cmd, { element_type = "tab" })
    if not ok then
        vim.notify(result, vim.log.levels.ERROR)
        return nil
    end
    local bufnr = result
    if not bufnr then
        return
    end
    vim.cmd("tabnew")
    vim.api.nvim_win_set_buf(0, bufnr)
    post_create_co(bufnr)
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
            local max_height = math.floor(vim.o.lines * 0.5)
            vim.api.nvim_win_set_height(window, height)
            channel_id = vim.fn.termopen(cmd, {
                on_stdout = function()
                    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                    local empty_lines = vim.tbl_filter(function(line)
                        return line == ""
                    end, lines)
                    if #lines - #empty_lines + 1 > height and not (height > max_height) then
                        height = #lines - #empty_lines + 1
                    end
                    vim.api.nvim_win_set_height(window, height)
                end,
                on_exit = function()
                    local trim_terminal_output = function()
                        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                        local lines_to_delete = vim.tbl_filter(function(line)
                            return line == "" or line == "[Process exited 0]"
                        end, lines)
                        vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
                        vim.api.nvim_buf_set_lines(bufnr, #lines - #lines - 2, -1, false, {})
                        vim.api.nvim_win_set_height(window, math.min(#lines - #lines_to_delete + 2, max_height))
                        vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
                        if not opts.skip_redraw then
                            register.redraw_elements()
                        end
                    end
                    -- Sometimes this function runs before "[Process exited 0]" is in the buffer, and it doesn't get removed.
                    -- A small pause here ensures that it gets cleaned up consistently. We might need to adjust the time though.
                    vim.defer_fn(function()
                        pcall(trim_terminal_output)
                    end, 100)
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
    require("alien.keymaps").set_element_keymaps(bufnr, "terminal")
    return bufnr
end

return M
