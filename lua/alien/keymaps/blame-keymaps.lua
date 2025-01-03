local keymaps = require("alien.config").config.keymaps.blame
local elements = require("alien.elements")
local map = require("alien.keymaps").map
local commands = require("alien.actions.commands")

local M = {}

local extract = function()
    return require("alien.extractors.blame-extractor").extract(vim.api.nvim_get_current_line())
end

M.set_keymaps = function(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }

    map(keymaps.commit_info, function()
        local commit = extract()
        if not commit then
            return
        end
        elements.float("git log -n 1 " .. commit.hash)
    end, vim.tbl_extend("force", opts, { desc = "Display commit info" }))

    map(keymaps.display_files, function()
        local commit = extract()
        if not commit then
            return
        end

        local tree_cmd = "git diff-tree --no-commit-id --name-only " .. commit.hash .. " -r"
        elements.window(tree_cmd, {
            output_handler = function(lines)
                local new_lines = require("alien.utils").run_cmd(
                    "git log " .. commit.hash .. " -n 1 --pretty=format:'%h %cr %an ◯ %s'"
                )
                for _, line in ipairs(lines) do
                    table.insert(new_lines, line)
                end
                return new_lines
            end,
        })
    end, vim.tbl_extend("force", opts, { desc = "Display commit files" }))

    map(keymaps.copy_commit_url, function()
        local commit = extract()
        if not commit then
            return
        end
        commands.copy_git_commit_url(commit.hash)
    end, vim.tbl_extend("force", opts, { desc = "Copy commit url" }))

    map(keymaps.show, function()
        local commit = extract()
        if not commit then
            return
        end
        elements.float("git show " .. commit.hash)
    end, vim.tbl_extend("force", opts, { desc = "Show commit" }))
end

return M
