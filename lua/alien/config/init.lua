local local_file_builtins = require("alien.config.local_file_builtins")

local M = {}
M.default_config = {
    command_mode_commands = { "Git", "G" },
    local_file = {
        auto_display_diff = true,
    },
    commit_file = {
        auto_display_diff = true,
    },
    keymaps = {
        global = {
            branch_picker = "<leader>B",
            toggle_keymap_display = "g?",
        },
        local_file = {
            ["<enter>"] = {
                fn = local_file_builtins.STAGE_OR_UNSTAGE,
                desc = "Stage/unstage a file",
                modes = { "n", "v" },
            },
            ["a"] = { fn = local_file_builtins.STAGE_OR_UNSTAGE_ALL, desc = "Stage/unstage all files" },
            ["d"] = { fn = local_file_builtins.RESTORE, desc = "Restore (delete) a file" },
            ["p"] = { fn = local_file_builtins.PULL, desc = "Git pull" },
            ["<leader>p"] = { fn = local_file_builtins.PUSH, desc = "Git push" },
            ["c"] = { fn = local_file_builtins.COMMIT, desc = "Git commit" },
            ["o"] = { fn = local_file_builtins.NAVIGATE_TO_FILE, desc = "Open file in editor" },
            ["t"] = { fn = local_file_builtins.TOGGLE_AUTO_DIFF, desc = "Toggle auto diff" },
            ["J"] = { fn = local_file_builtins.SCROLL_DIFF_DOWN, desc = "Scroll down diff" },
            ["K"] = { fn = local_file_builtins.SCROLL_DIFF_UP, desc = "Scroll up diff" },
            ["D"] = { fn = local_file_builtins.VIMDIFF, desc = "Detailed diff" },
            ["<leader>s"] = { fn = local_file_builtins.STASH, desc = "Stash current changes" },
            ["<leader>S"] = { fn = local_file_builtins.STASH_WITH_FLAGS, desc = "Git stash with options" },
            ["<leader>am"] = { fn = local_file_builtins.AMEND, desc = "Amend last commit" },
        },
        local_branch = {
            switch = "s",
            new_branch = "n",
            delete = "d",
            rename = "R",
            merge = "m",
            rebase = "r",
            log = "<enter>",
            pull = "p",
            push = "<leader>p",
        },
        blame = {
            display_files = "<enter>",
            copy_commit_url = "o",
            commit_info = "i",
        },
        commit = {
            display_files = "<enter>",
            reword = "rw",
            revert = "rv",
            reset = "rs",
            copy_commit_url = "o",
            commit_info = "i",
        },
        commit_file = {
            scroll_diff_down = "J",
            scroll_diff_up = "K",
            vimdiff = "D",
            toggle_auto_diff = "t",
            open_in_vertical_split = "<C-v>",
            open_in_horizontal_split = "<C-h>",
            open_in_tab = "<C-t>",
            open_in_window = "<C-w>",
        },
        stash = {
            pop = "p",
            apply = "a",
            drop = "d",
        },
    },
}

M.config = {}

return M
