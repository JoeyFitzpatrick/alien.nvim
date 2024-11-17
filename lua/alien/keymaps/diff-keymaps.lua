local keymaps = require("alien.config").config.keymaps.diff
local map_action = require("alien.keymaps").map_action

local M = {}

M.set_unstaged_diff_keymaps = function(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
    local action_opts = { trigger_redraw = true }

    -- Get line nums from hunk. This currently returns the line num after the first @@ line, so we may need
    -- to add another property for the @@ line, and the lines at the top of the file that show the diff info
    -- Add these changes to a temp file. This will be a .patch file.
    -- Should be formatted like this:
    --
    -- diff --git a/lua/alien/config.lua b/lua/alien/config.lua
    -- index 465055b..1c4b9c1 100644
    -- --- a/lua/alien/config.lua
    -- +++ b/lua/alien/config.lua
    -- @@ -23,7 +23,7 @@ M.default_config = {
    --              toggle_auto_diff = "t",
    --              scroll_diff_down = "J",
    --              scroll_diff_up = "K",
    -- -            detailed_diff = "D",
    -- +            staging_area = "D",
    --              stash = "<leader>s",
    --              stash_with_flags = "<leader>S",
    --              amend = "<leader>am",
    --
    --
    map_action(keymaps.staging_area.stage_hunk, function(hunk)
        return "git status --short"
    end, action_opts, opts)
end

M.set_keymaps = function(bufnr) end

return M
