local M = {}

M.set_keymaps = function(bufnr)
    local run_action = require("alien.actions").run_action
    local action = require("alien.actions").action
    local is_staged = require("alien.status").is_staged
    local elements = require("alien.elements")
    local keymaps = require("alien.config").config.keymaps.local_file
    local config = require("alien.config").config.local_file
    local commands = require("alien.actions.commands")
    local create_command = commands.create_command
    local map = require("alien.keymaps").map
    local map_action_with_input = require("alien.keymaps").map_action_with_input
    local set_command_keymap = require("alien.keymaps").set_command_keymap
    local extract = require("alien.extractors.local-file-extractor").extract
    local utils = require("alien.utils")
    local STATUSES = require("alien.status").STATUSES

    local get_args = function()
        return extract(bufnr)
    end

    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
    local action_opts = { trigger_redraw = true }

    local diff_native = commands.create_command(function(local_file)
        local status = local_file.file_status
        local filename = local_file.filename
        if status == STATUSES.UNTRACKED then
            return "git diff --no-index /dev/null " .. filename
        end
        if require("alien.status").is_deleted(status) then
            if is_staged(status) then
                return "git diff --cached -- " .. filename
            end
            return "git diff -- " .. filename
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

    local toggle_auto_diff = function()
        set_auto_diff(not AUTO_DISPLAY_DIFF)
    end

    vim.keymap.set(
        "n",
        keymaps.toggle_auto_diff,
        toggle_auto_diff,
        vim.tbl_extend("force", opts, { desc = "Toggle auto diff" })
    )

    vim.keymap.set("n", keymaps.scroll_diff_down, function()
        local buffers = elements.register.get_child_elements({ object_type = "diff" })
        local buffer = buffers[1]
        if #buffers == 1 and buffer.channel_id then
            pcall(vim.api.nvim_chan_send, buffer.channel_id, "jj")
        end
    end, vim.tbl_extend("force", opts, { desc = "Scroll diff down" }))

    vim.keymap.set("n", keymaps.scroll_diff_up, function()
        local buffers = elements.register.get_child_elements({ object_type = "diff" })
        local buffer = buffers[1]
        if #buffers == 1 and buffer.channel_id then
            pcall(vim.api.nvim_chan_send, buffer.channel_id, "kk")
        end
    end, vim.tbl_extend("force", opts, { desc = "Scroll diff up" }))

    map(keymaps.staging_area, function()
        local current_file = extract(bufnr)
        if not current_file then
            return
        end
        set_auto_diff(false)
        require("alien.global-actions.detailed-diff").display_detailed_diff(current_file)
    end, vim.tbl_extend("force", opts, { desc = "Enter staging area" }))

    map(keymaps.stage_or_unstage, function()
        local local_file = extract(bufnr)
        if not local_file then
            return
        end
        local filename = local_file.filename
        local status = local_file.file_status
        if not is_staged(status) then
            action("git add -- " .. filename, action_opts)
        else
            action("git reset HEAD -- " .. filename, action_opts)
        end
    end, vim.tbl_extend("force", opts, { desc = "Stage/unstage file" }))

    local visual_stage_or_unstage_fn = function(local_files)
        local should_stage = false
        local filenames = ""
        for _, local_file in ipairs(local_files) do
            local status = local_file.status
            if not is_staged(status) then
                should_stage = true
            end
            filenames = filenames .. " '" .. local_file.name .. "'"
        end
        if should_stage then
            return "git add " .. filenames
        end
        return "git reset " .. filenames
    end

    vim.keymap.set("v", keymaps.stage_or_unstage, function()
        run_action(
            create_command(visual_stage_or_unstage_fn, function()
                local status_data = require("alien.elements.register.state").get_state(bufnr).status_data
                if not status_data then
                    return
                end
                local start_line, end_line = utils.get_visual_line_nums()
                local local_files = {}
                for i = start_line - 2, end_line - 2 do -- subtract 2 because the first two local file lines are not considered
                    table.insert(local_files, status_data[i])
                end
                return local_files
            end),
            { trigger_redraw = true }
        )
    end, vim.tbl_extend("force", opts, { desc = "Stage/unstage file in visual mode" }))

    ---@param local_files StatusData
    local stage_or_unstage_all_fn = function(local_files)
        for _, local_file in ipairs(local_files) do
            local status = local_file.status
            if local_file.type == "file" and not is_staged(status) then
                return "git add -A"
            end
        end
        return "git reset"
    end

    map(keymaps.stage_or_unstage_all, function()
        run_action(
            create_command(stage_or_unstage_all_fn, function()
                return require("alien.elements.register.state").get_state(bufnr).status_data
            end),
            { trigger_redraw = true }
        )
    end, vim.tbl_extend("force", opts, { desc = "Stage/unstage all files" }))

    map(keymaps.restore, function()
        local current_file = extract(bufnr)
        vim.ui.select(
            { "just this file", "nuke working tree", "hard reset", "mixed reset", "soft reset" },
            { prompt = "restore type: " },
            function(restore_type)
                if not restore_type then
                    return
                end
                local cmd
                if restore_type == "just this file" then
                    if not current_file then
                        return
                    end
                    if current_file.file_status == STATUSES.UNTRACKED then
                        cmd = "git clean -f -- " .. current_file.filename
                    elseif is_staged(current_file.file_status) then
                        cmd = "git reset -- "
                            .. current_file.filename
                            .. " && git clean -f -- "
                            .. current_file.filename
                    else
                        cmd = "git restore -- " .. current_file.filename
                    end
                elseif restore_type == "nuke working tree" then
                    cmd = "git reset --hard HEAD && git clean -fd"
                elseif restore_type == "hard reset" then
                    cmd = "git reset --hard HEAD"
                elseif restore_type == "mixed reset" then
                    cmd = "git reset --mixed HEAD"
                elseif restore_type == "soft reset" then
                    cmd = "git reset --soft HEAD"
                end
                local local_action_opts = action_opts
                local_action_opts.input = restore_type
                require("alien.actions").action(cmd, local_action_opts)
            end
        )
    end, vim.tbl_extend("force", opts, { desc = "Restore (delete) file" }))

    set_command_keymap(keymaps.pull, "pull", vim.tbl_extend("force", opts, { desc = "Pull" }))
    set_command_keymap(keymaps.push, "push", vim.tbl_extend("force", opts, { desc = "Push" }))
    set_command_keymap(
        keymaps.amend,
        "commit --amend --reuse-message HEAD",
        vim.tbl_extend("force", opts, { desc = "Amend last commit" })
    )

    map(keymaps.commit, function()
        set_auto_diff(false)
        elements.terminal("git commit", { enter = true, window = { split = "right" } })
    end, vim.tbl_extend("force", opts, { desc = "Commit" }))

    map_action_with_input(keymaps.stash, function(_, stash_name)
        return "git stash push -m " .. stash_name
    end, { prompt = "Stash name: " }, action_opts, vim.tbl_extend("force", opts, { desc = "Stash current changes" }))

    map(keymaps.stash_with_flags, function()
        vim.ui.select({ "staged" }, { prompt = "Stash type:" }, function(stash_type)
            vim.ui.input({ prompt = "Stash name: " }, function(input)
                local cmd = "git stash push --" .. stash_type .. " -m " .. input
                action(cmd, action_opts)
            end)
        end)
    end, vim.tbl_extend("force", opts, { desc = "Stash with options" }))

    map(keymaps.navigate_to_file, function()
        local current_file = extract(bufnr)
        if not current_file then
            return
        end
        local filename = current_file.raw_filename
        vim.api.nvim_exec2("e " .. filename, {})
    end, vim.tbl_extend("force", opts, { desc = "Open file in editor" }))

    map(keymaps.fold, function()
        local current_file = extract(bufnr)
        if not current_file then
            return
        end
        local state = require("alien.elements.register.state").get_state(bufnr)
        if not state then
            return
        end
        local current_fold = false
        if
            state.specific_state[current_file.raw_filename] and state.specific_state[current_file.raw_filename].folded
        then
            current_fold = true
        end
        require("alien.elements.register.state").set_state(
            bufnr,
            { specific_state = { [current_file.raw_filename] = { folded = not current_fold } } }
        )
        require("alien.elements.register").redraw_elements()
    end, vim.tbl_extend("force", opts, { desc = "Fold dir" }))

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
