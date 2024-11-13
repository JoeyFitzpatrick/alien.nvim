local elements = require("alien.elements")
local action = require("alien.actions").action
local ERROR_CODES = require("alien.actions.error-codes")

local extract = function()
    return require("alien.extractors.local-branch-extractor").extract(vim.api.nvim_get_current_line())
end

---@alias LocalBranch { branch_name: string }

local M = {}

M.set_keymaps = function(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
    local action_opts = { trigger_redraw = true }
    local local_branch_builtins = require("alien.config.builtins").local_branch_builtins
    local mappings = {}

    mappings[local_branch_builtins.SWITCH] = function()
        action(function(branch)
            return "git switch " .. branch.branch_name
        end, action_opts)
    end

    mappings[local_branch_builtins.NEW_BRANCH] = function()
        vim.ui.input({ prompt = "New branch name: " }, function(input)
            if not input then
                return
            end
            local local_action_opts = action_opts
            local_action_opts.input = input
            action(function(branch, new_branch_name)
                return "git switch --create " .. new_branch_name .. " " .. branch.branch_name
            end, local_action_opts)
        end)
    end

    local delete_branch_prompt = function(delete_branch_cmd)
        vim.ui.select(
            { "yes", "no" },
            { prompt = "This branch is not fully merged. Are you sure you want to delete it?" },
            function(selection)
                if selection == "yes" then
                    action(delete_branch_cmd .. " -D", action_opts)
                end
            end
        )
    end

    mappings[local_branch_builtins.DELETE] = function()
        vim.ui.select({ "local", "remote" }, { prompt = "Delete local or remote: " }, function(input)
            if not input then
                return
            end
            local local_action_opts = action_opts
            local_action_opts.input = input
            local_action_opts.error_callbacks = { [ERROR_CODES.BRANCH_NOT_FULLY_MERGED] = delete_branch_prompt }
            action(function(branch, location)
                print(branch.branch_name)
                if location == "remote" then
                    return "git push origin --delete " .. branch.branch_name
                elseif location == "local" then
                    return "git branch --delete " .. branch.branch_name
                end
            end, local_action_opts)
        end)
    end

    mappings[local_branch_builtins.RENAME] = function()
        vim.ui.input({ prompt = "Rename branch: " }, function(input)
            if not input then
                return
            end
            local local_action_opts = action_opts
            local_action_opts.input = input
            action(function(branch, new_branch_name)
                return "git branch -m " .. branch.branch_name .. " " .. new_branch_name
            end, local_action_opts)
        end)
    end

    mappings[local_branch_builtins.MERGE] = function()
        action(function(branch)
            return "git merge " .. branch.branch_name
        end, action_opts)
    end

    mappings[local_branch_builtins.REBASE] = function()
        action(function(branch)
            return "git rebase " .. branch.branch_name
        end, action_opts)
    end

    mappings[local_branch_builtins.LOG] = function()
        local branch = extract()
        if not branch then
            return
        end
        elements.window(
            "git log " .. branch.branch_name .. " --pretty=format:'%h\t%cr\t%an\t%s'",
            { highlight = require("alien.highlight.commit-highlight").highlight_oneline_pretty }
        )
    end

    mappings[local_branch_builtins.PULL] = require("alien.keymaps.utils").get_alien_command("pull")
    mappings[local_branch_builtins.PUSH] = require("alien.keymaps.utils").get_alien_command("push")

    require("alien.keymaps").apply_mappings(require("alien.config").config.keymaps.local_branch, mappings, opts)

    -- Autocmds
    local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
    vim.api.nvim_create_autocmd("BufWinEnter", {
        desc = "Move cursor to current branch",
        buffer = bufnr,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            for row, line in ipairs(lines) do
                if line:sub(1, 1) == "*" then
                    vim.api.nvim_win_set_cursor(0, { row, 0 })
                    break
                end
            end
        end,
        group = alien_status_group,
    })
end

return M
