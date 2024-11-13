local M = {}

M.set_keymaps = function(bufnr)
    local run_action = require("alien.actions").run_action
    local action = require("alien.actions").action
    local is_staged = require("alien.status").is_staged
    local elements = require("alien.elements")
    local config = require("alien.config").config.local_file
    local commands = require("alien.actions.commands")
    local create_command = commands.create_command
    local extract = require("alien.extractors.local-file-extractor").extract
    local get_args = commands.get_args(extract)
    local utils = require("alien.utils")
    local STATUSES = require("alien.status").STATUSES
    local local_file_builtins = require("alien.config.builtins").local_file_builtins

    local mappings = {}

    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
    local action_opts = { trigger_redraw = true }

    local diff_native = commands.create_command(function(local_file)
        local status = local_file.file_status
        local filename = local_file.filename
        if status == STATUSES.UNTRACKED then
            return "git diff --no-index /dev/null " .. filename
        end
        if is_staged(status) then
            return "git diff --staged " .. filename
        end
        return "git diff " .. filename
    end, get_args)

    local open_diff = function()
        local width = math.floor(vim.o.columns * 0.67)
        if vim.api.nvim_get_current_buf() == bufnr then
            ---@diagnostic disable-next-line: param-type-mismatch
            local ok, cmd = pcall(diff_native)
            if ok then
                elements.terminal(cmd, { skip_redraw = true, window = { width = width } })
            end
        end
    end

    local AUTO_DISPLAY_DIFF = config.auto_display_diff
    local set_auto_diff = function(should_display)
        AUTO_DISPLAY_DIFF = should_display
        if not AUTO_DISPLAY_DIFF then
            elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
        else
            open_diff()
        end
    end

    mappings[local_file_builtins.TOGGLE_AUTO_DIFF] = function()
        set_auto_diff(not AUTO_DISPLAY_DIFF)
    end

    mappings[local_file_builtins.SCROLL_DIFF_DOWN] = function()
        local buffers = elements.register.get_child_elements({ object_type = "diff" })
        local buffer = buffers[1]
        if #buffers == 1 and buffer.channel_id then
            pcall(vim.api.nvim_chan_send, buffer.channel_id, "jj")
        end
    end

    mappings[local_file_builtins.SCROLL_DIFF_DOWN] = function()
        local buffers = elements.register.get_child_elements({ object_type = "diff" })
        local buffer = buffers[1]
        if #buffers == 1 and buffer.channel_id then
            pcall(vim.api.nvim_chan_send, buffer.channel_id, "kk")
        end
    end

    mappings[local_file_builtins.VIMDIFF] = function()
        local current_file = extract(vim.api.nvim_get_current_line())
        if not current_file then
            return
        end
        set_auto_diff(false)
        local head_file_bufnr =
            elements.window("git show HEAD:" .. current_file.filename, { object_type = "local_file" })
        vim.cmd("diffthis")
        vim.cmd("rightbelow vsplit " .. current_file.raw_filename)
        vim.cmd("diffthis")
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
        vim.api.nvim_set_option_value("filetype", filetype, { buf = head_file_bufnr })
    end

    local stage_or_unstage_inner = function(local_file)
        local filename = local_file.filename
        local status = local_file.file_status
        if not is_staged(status) then
            return "git add -- " .. filename
        else
            return "git reset HEAD -- " .. filename
        end
    end

    local stage_or_unstage = function()
        action(stage_or_unstage_inner, action_opts)
    end

    local visual_stage_or_unstage_inner_fn = function(local_files)
        local should_stage = false
        local filenames = ""
        for _, local_file in ipairs(local_files) do
            local status = local_file.file_status
            if not is_staged(status) then
                should_stage = true
            end
            filenames = filenames .. " " .. local_file.filename
        end
        if should_stage then
            return "git add " .. filenames
        end
        return "git reset " .. filenames
    end

    local stage_or_unstage_v = function()
        run_action(
            create_command(visual_stage_or_unstage_inner_fn, function()
                local start_line, end_line = utils.get_visual_line_nums()
                local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
                local local_files = {}
                for _, line in ipairs(lines) do
                    local local_file = extract(line)
                    table.insert(local_files, local_file)
                end
                return local_files
            end),
            { trigger_redraw = true }
        )
    end

    mappings[local_file_builtins.STAGE_OR_UNSTAGE] = { n = stage_or_unstage, v = stage_or_unstage_v }

    local stage_or_unstage_all_fn = function(local_files)
        for _, local_file in ipairs(local_files) do
            local status = local_file.file_status
            if not is_staged(status) then
                return "git add -A"
            end
        end
        return "git reset"
    end

    mappings[local_file_builtins.STAGE_OR_UNSTAGE_ALL] = function()
        run_action(
            create_command(stage_or_unstage_all_fn, function()
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local local_files = {}
                for _, line in ipairs(lines) do
                    local local_file = extract(line)
                    table.insert(local_files, local_file)
                end
                return local_files
            end),
            { trigger_redraw = true }
        )
    end

    local restore = function(local_file, restore_type)
        local filename = local_file.filename
        local status = local_file.file_status
        if restore_type == "just this file" then
            if status == STATUSES.UNTRACKED then
                return "git clean -f -- " .. filename
            end
            return "git restore -- " .. filename
        elseif restore_type == "nuke working tree" then
            return "git reset --hard HEAD && git clean -fd"
        elseif restore_type == "hard reset" then
            return "git reset --hard HEAD"
        elseif restore_type == "mixed reset" then
            return "git reset --mixed HEAD"
        elseif restore_type == "soft reset" then
            return "git reset --soft HEAD"
        end
    end

    mappings[local_file_builtins.RESTORE] = function()
        vim.ui.select(
            { "just this file", "nuke working tree", "hard reset", "mixed reset", "soft reset" },
            { prompt = "restore type: " },
            function(input)
                if not input then
                    return
                end
                local local_action_opts = action_opts
                local_action_opts.input = input
                action(restore, local_action_opts)
            end
        )
    end

    mappings[local_file_builtins.PULL] = require("alien.keymaps.utils").get_alien_command("pull")
    mappings[local_file_builtins.PUSH] = require("alien.keymaps.utils").get_alien_command("push")
    mappings[local_file_builtins.AMEND] =
        require("alien.keymaps.utils").get_alien_command("commit --amend --reuse-message HEAD")

    mappings[local_file_builtins.COMMIT] = function()
        set_auto_diff(false)
        elements.terminal("git commit", { enter = true, window = { split = "right" } })
    end

    local stash = function(_, stash_name)
        return "git stash push -m " .. stash_name
    end

    mappings[local_file_builtins.STASH] = function()
        vim.ui.input({ prompt = "Stash name: " }, function(input)
            if not input then
                return
            end
            local local_action_opts = action_opts
            local_action_opts.input = input
            action(stash, local_action_opts)
        end)
    end

    mappings[local_file_builtins.STASH_WITH_FLAGS] = function()
        vim.ui.select({ "staged" }, { prompt = "Stash type:" }, function(stash_type)
            vim.ui.input({ prompt = "Stash name: " }, function(input)
                local cmd = "git stash push --" .. stash_type .. " -m " .. input
                action(cmd, action_opts)
            end)
        end)
    end

    mappings[local_file_builtins.NAVIGATE_TO_FILE] = function()
        local current_file = require("alien.extractors").extract("local_file")
        if not current_file then
            return
        end
        local filename = current_file.raw_filename
        vim.api.nvim_exec2("e " .. filename, {})
    end

    require("alien.keymaps").apply_mappings(require("alien.config").config.keymaps.local_file, mappings, opts)

    local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
    vim.api.nvim_create_autocmd("CursorMoved", {
        desc = "Diff the file under the cursor",
        buffer = bufnr,
        callback = function()
            if not AUTO_DISPLAY_DIFF then
                return
            end
            elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
            if vim.api.nvim_get_current_buf() == bufnr then
                open_diff()
            end
        end,
        group = alien_status_group,
    })

    vim.api.nvim_create_autocmd("BufHidden", {
        desc = "Close open diffs when buffer is hidden",
        buffer = bufnr,
        callback = function()
            set_auto_diff(false)
        end,
        group = alien_status_group,
    })
end

return M
