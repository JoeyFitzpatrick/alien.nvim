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
            stage_or_unstage = "<enter>",
            stage_or_unstage_all = "a",
            restore = "d",
            pull = "p",
            push = "<leader>p",
            commit = "c",
            navigate_to_file = "o",
            toggle_auto_diff = "t",
            scroll_diff_down = "J",
            scroll_diff_up = "K",
            staging_area = "D",
            stash = "<leader>s",
            stash_with_flags = "<leader>S",
            amend = "<leader>am",
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
        diff = {
            staging_area = {
                stage_hunk = "<enter>",
                stage_line = "s",
                next_hunk = "i",
                previous_hunk = "p",
            },
        },
    },
}

M.config = {}

return M
