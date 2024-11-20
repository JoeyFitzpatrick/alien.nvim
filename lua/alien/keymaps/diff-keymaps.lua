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
    end, opts)
end

M.set_keymaps = function(bufnr) end

return M
