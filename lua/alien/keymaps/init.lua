local keymaps = require("alien.config").config.keymaps.global

local M = {}

---@param keys string
---@param fn function
---@param opts? vim.keymap.set.Opts
M.map = function(keys, fn, opts)
    vim.keymap.set("n", keys, fn, opts)
end

--- Cleaner way to map an action to a keymap
---@param keys string
---@param cmd_fn function
---@param action_opts? AlienOpts
---@param opts? vim.keymap.set.Opts
M.map_action = function(keys, cmd_fn, action_opts, opts)
    M.map(keys, function()
        return require("alien.actions").action(cmd_fn, action_opts)
    end, opts)
end

---@param keys string
---@param cmd_fn function
---@param input_opts { prompt: string, items: any[] | nil }
---@param alien_opts AlienOpts
---@param opts vim.keymap.set.Opts
M.map_action_with_input = function(keys, cmd_fn, input_opts, alien_opts, opts)
    if input_opts.items then
        M.map(keys, function()
            vim.ui.select(input_opts.items, { prompt = input_opts.prompt }, function(input)
                if not input then
                    return
                end
                alien_opts.input = input
                require("alien.actions").action(cmd_fn, alien_opts)
            end)
        end, opts)
    else
        M.map(keys, function()
            vim.ui.input({ prompt = input_opts.prompt }, function(input)
                if not input then
                    return
                end
                alien_opts.input = input
                require("alien.actions").action(cmd_fn, alien_opts)
            end)
        end, opts)
    end
end

M.set_command_keymap = function(mapping, command, opts)
    local alien_command_name = require("alien.config").config.command_mode_commands[1]
    vim.keymap.set("n", mapping, "<cmd>" .. alien_command_name .. " " .. command .. "<CR>", opts)
end

--- Set keymaps by object type for the given buffer
---@param bufnr integer
---@param object_type AlienObject
M.set_object_keymaps = function(bufnr, object_type)
    local ok, result = pcall(require, "alien.keymaps." .. object_type:gsub("_", "-") .. "-keymaps")
    if not ok or not result then
        return
    end
    result.set_keymaps(bufnr)
end

--- Set keymaps by element type for the given buffer
---@param bufnr integer
---@param element_type ElementType
M.set_element_keymaps = function(bufnr, element_type)
    vim.keymap.set("n", "q", function()
        require("alien.elements.register").close_element(bufnr)
    end, { noremap = true, silent = true, buffer = bufnr })

    vim.keymap.set("n", keymaps.toggle_keymap_display, function()
        require("alien.keymaps.toggle-help-float").toggle_keymap_display()
    end, { noremap = true, silent = true, buffer = bufnr })

    if element_type == "terminal" then
        vim.keymap.set("n", "<CR>", function()
            require("alien.elements.register").close_element(bufnr)
        end, { noremap = true, silent = true, buffer = bufnr })
    end
end

M.set_global_keymaps = function()
    require("alien.keymaps.global-keymaps").set_global_keymaps()
end

return M
