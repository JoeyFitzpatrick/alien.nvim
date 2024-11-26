local elements = require("alien.elements")
local keymaps = require("alien.config").config.keymaps.local_branch
local action = require("alien.actions").action
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map = require("alien.keymaps").map
local set_command_keymap = require("alien.keymaps").set_command_keymap
local ERROR_CODES = require("alien.actions.error-codes")

local extract = function()
    return require("alien.extractors.local-branch-extractor").extract(vim.api.nvim_get_current_line())
end

---@alias LocalBranch { branch_name: string }

local M = {}

M.set_keymaps = function(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
    local alien_opts = { trigger_redraw = true }

    map_action(keymaps.switch, function(branch)
        return "git switch " .. branch.branch_name
    end, alien_opts, vim.tbl_extend("force", opts, { desc = "Switch to branch" }))

    map_action_with_input(keymaps.new_branch, function(branch, new_branch_name)
        return "git switch --create " .. new_branch_name .. " " .. branch.branch_name
    end, { prompt = "New branch name: " }, alien_opts, vim.tbl_extend("force", opts, { desc = "Create new branch" }))

    local delete_branch_prompt = function(delete_branch_cmd)
        vim.ui.select(
            { "yes", "no" },
            { prompt = "This branch is not fully merged. Are you sure you want to delete it?" },
            function(selection)
                if selection == "yes" then
                    action(delete_branch_cmd .. " -D", alien_opts)
                end
            end
        )
    end

    map_action_with_input(
        keymaps.delete,
        function(branch, location)
            if location == "remote" then
                return "git push origin --delete " .. branch.branch_name
            elseif location == "local" then
                return "git branch --delete " .. branch.branch_name
            end
        end,
        { items = { "local", "remote" }, prompt = "Delete local or remote: " },
        { trigger_redraw = true, error_callbacks = { [ERROR_CODES.BRANCH_NOT_FULLY_MERGED] = delete_branch_prompt } },
        vim.tbl_extend("force", opts, { desc = "Delete branch" })
    )

    map_action_with_input(keymaps.rename, function(branch, new_branch_name)
        return "git branch -m " .. branch.branch_name .. " " .. new_branch_name
    end, { prompt = "Rename branch: " }, alien_opts, vim.tbl_extend("force", opts, { desc = "Rename branch" }))

    map_action(keymaps.merge, function(branch)
        return "git merge " .. branch.branch_name
    end, alien_opts, vim.tbl_extend("force", opts, { desc = "Merge into current branch" }))

    map_action(keymaps.rebase, function(branch)
        return "git rebase " .. branch.branch_name
    end, alien_opts, vim.tbl_extend("force", opts, { desc = "Rebase onto current branch" }))

    map(keymaps.log, function()
        local branch = extract()
        if not branch then
            return
        end
        elements.window(
            "git log " .. branch.branch_name .. " --pretty=format:'%h %<(25)%cr %<(25)%an %<(25)%s'",
            { highlight = require("alien.highlight.commit-highlight").highlight_oneline_pretty }
        )
    end, vim.tbl_extend("force", opts, { desc = "Open branch commits (log)" }))

    set_command_keymap(keymaps.pull, "pull", vim.tbl_extend("force", opts, { desc = "Pull" }))
    set_command_keymap(keymaps.push, "push", vim.tbl_extend("force", opts, { desc = "Push" }))

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
