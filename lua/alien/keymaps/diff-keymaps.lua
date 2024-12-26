local keymaps = require("alien.config").config.keymaps.diff
local map = require("alien.keymaps").map
local extract = require("alien.extractors.diff-extractor").extract

local M = {}

M.set_staging_keymaps = function(bufnr, is_staged)
    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
    local action_opts = { trigger_redraw = true }

    map(keymaps.staging_area.stage_hunk, function()
        local hunk = extract()
        if not hunk then
            return
        end
        local local_opts = action_opts
        local_opts.stdin = hunk.patch_lines
        local cmd
        if is_staged then
            cmd = "git apply --reverse --cached --whitespace=nowarn -"
        else
            cmd = "git apply --cached --whitespace=nowarn -"
        end
        require("alien.actions").action(cmd, action_opts)
    end, vim.tbl_extend("force", opts, { desc = "Stage/unstage hunk" }))

    map(keymaps.staging_area.stage_line, function()
        local hunk = extract()
        if not hunk or not hunk.patch_single_line then
            return
        end
        local local_opts = action_opts
        local_opts.stdin = hunk.patch_single_line
        vim.print(hunk.patch_single_line)
        local cmd
        if is_staged then
            cmd = "git apply --reverse --cached --whitespace=nowarn -"
        else
            cmd = "git apply --cached --whitespace=nowarn -"
        end
        require("alien.actions").action(cmd, action_opts)
    end, vim.tbl_extend("force", opts, { desc = "Stage/unstage line" }))
end

M.set_keymaps = function(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }

    map(keymaps.next_hunk, function()
        local hunk = extract()
        if not hunk then
            local cursor = vim.api.nvim_win_get_cursor(0)
            for line_num, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, -1, false)) do
                if line:sub(1, 2) == "@@" then
                    vim.api.nvim_win_set_cursor(0, { line_num + 1, cursor[2] })
                    return
                end
            end
            return
        end
        if hunk.next_hunk_start == nil then
            return
        end
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_cursor(0, { hunk.next_hunk_start, cursor[2] })
    end, vim.tbl_extend("force", opts, { desc = "Go to next hunk" }))

    map(keymaps.previous_hunk, function()
        local hunk = extract()
        if not hunk or hunk.previous_hunk_start == nil then
            return
        end
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_cursor(0, { hunk.previous_hunk_start, cursor[2] })
    end, vim.tbl_extend("force", opts, { desc = "Go to previous hunk" }))
end

return M
