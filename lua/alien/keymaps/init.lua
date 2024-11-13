local keymaps = require("alien.config").config.keymaps.global

local M = {}

---@param keys string
---@param fn function
---@param opts? vim.keymap.set.Opts
M.map = function(keys, fn, opts)
    vim.keymap.set("n", keys, function()
        fn()
    end, opts)
end

--- Cleaner way to map an action to a keymap
---@param keys string
---@param cmd_fn function
---@param alien_opts? AlienOpts
---@param opts? vim.keymap.set.Opts
M.map_action = function(keys, cmd_fn, alien_opts, opts)
    M.map(keys, function()
        return require("alien.actions").action(cmd_fn, alien_opts)
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

--- Apply config mappings using a mapping table
---@param config table<string, string|function>
---@param mappings table<string, function>
---@param opts table<string, any>
M.apply_mappings = function(config, mappings, opts)
    for keys, mapping in pairs(config) do
        local local_opts = opts
        local_opts["desc"] = mapping.desc
        if type(mapping.fn) == "function" then
            vim.keymap.set("n", keys, mapping.fn, local_opts)
        end

        assert(type(mapping.fn) == "string")
        local builtin_mapping = mappings[mapping.fn]
        if not builtin_mapping then
            vim.keymap.set("n", keys, mapping.fn, local_opts)
        else
            if type(builtin_mapping) == "table" then
                for mode, fn in pairs(builtin_mapping) do
                    vim.keymap.set(mode, keys, fn, local_opts)
                end
            else
                vim.keymap.set("n", keys, builtin_mapping, local_opts)
            end
        end
    end
end

return M
