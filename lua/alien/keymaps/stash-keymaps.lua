local keymaps = require("alien.config").config.keymaps.stash
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input

local M = {}

M.set_keymaps = function(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
    local alien_opts = { trigger_redraw = true }

    map_action(keymaps.apply, function(stash)
        return string.format("git stash apply stash@{%s}", stash.index)
    end, alien_opts, vim.tbl_extend("force", opts, { desc = "Apply stash" }))

    map_action(keymaps.pop, function(stash)
        return string.format("git stash pop stash@{%s}", stash.index)
    end, alien_opts, vim.tbl_extend("force", opts, { desc = "Pop stash" }))

    map_action_with_input(
        keymaps.drop,
        function(stash, should_drop_stash)
            if should_drop_stash == "Yes" then
                return string.format("git stash drop stash@{%s}", stash.index)
            end
        end,
        { prompt = "Are you sure you want to drop this stash? ", items = { "Yes", "No" } },
        alien_opts,
        vim.tbl_extend("force", opts, { desc = "Drop stash" })
    )
end

return M
