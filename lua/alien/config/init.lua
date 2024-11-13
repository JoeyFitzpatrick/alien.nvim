local local_file_builtins = require("alien.config.builtins").local_file_builtins
local local_branch_builtins = require("alien.config.builtins").local_branch_builtins
local blame_builtins = require("alien.config.builtins").blame_builtins
local commit_builtins = require("alien.config.builtins").commit_builtins
local commit_file_builtins = require("alien.config.builtins").commit_file_builtins
local stash_builtins = require("alien.config.builtins").stash_builtins

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
            ["s"] = { fn = local_branch_builtins.SWITCH, desc = "Switch to branch" },
            ["n"] = { fn = local_branch_builtins.NEW_BRANCH, desc = "Create new branch" },
            ["d"] = { fn = local_branch_builtins.DELETE, desc = "Delete branch" },
            ["R"] = { fn = local_branch_builtins.RENAME, desc = "Rename branch" },
            ["m"] = { fn = local_branch_builtins.MERGE, desc = "Merge into current branch" },
            ["r"] = { fn = local_branch_builtins.REBASE, desc = "Rebase onto current branch" },
            ["<enter>"] = { fn = local_branch_builtins.LOG, desc = "Display branch log" },
            ["p"] = { fn = local_branch_builtins.PULL, desc = "Pull branch" },
            ["<leader>p"] = { fn = local_branch_builtins.PUSH, desc = "Push branch" },
        },
        blame = {
            ["<enter>"] = { fn = blame_builtins.DISPLAY_FILES, desc = "Display files in commit" },
            ["o"] = { fn = blame_builtins.COPY_COMMIT_URL, desc = "Copy commit URL to clipboard" },
            ["i"] = { fn = blame_builtins.COMMIT_INFO, desc = "Display commit info" },
        },
        commit = {
            ["<enter>"] = { fn = commit_builtins.DISPLAY_FILES, desc = "Display files in commit" },
            ["rw"] = { fn = commit_builtins.REWORD, desc = "Reword commit" },
            ["rv"] = { fn = commit_builtins.REVERT, desc = "Revert commit" },
            ["rs"] = { fn = commit_builtins.RESET, desc = "Reset to commit" },
            ["o"] = { fn = commit_builtins.COPY_COMMIT_URL, desc = "Copy commit URL to clipboard" },
            ["i"] = { fn = commit_builtins.COMMIT_INFO, desc = "Display commit info" },
        },
        commit_file = {
            ["J"] = { fn = commit_file_builtins.SCROLL_DIFF_DOWN, desc = "Scroll down diff" },
            ["K"] = { fn = commit_file_builtins.SCROLL_DIFF_UP, desc = "Scroll up diff" },
            ["D"] = { fn = commit_file_builtins.VIMDIFF, desc = "Detailed diff" },
            ["t"] = { fn = commit_file_builtins.TOGGLE_AUTO_DIFF, desc = "Toggle auto diff" },
            ["<C-v>"] = {
                fn = commit_file_builtins.OPEN_IN_VERTICAL_SPLIT,
                desc = "Open commit file in vertical split",
            },
            ["<C-h>"] = {
                fn = commit_file_builtins.OPEN_IN_HORIZONTAL_SPLIT,
                desc = "Open commit file in horizontal split",
            },
            ["<C-t>"] = { fn = commit_file_builtins.OPEN_IN_TAB, desc = "Open commit file in tab" },
            ["<C-w>"] = { fn = commit_file_builtins.OPEN_IN_WINDOW, desc = "Open commit file in window" },
        },
        stash = {
            ["p"] = { fn = stash_builtins.POP, desc = "Pop stash" },
            ["a"] = { fn = stash_builtins.APPLY, desc = "Apply stash" },
            ["d"] = { fn = stash_builtins.DROP, desc = "Drop stash" },
        },
    },
}

M.config = {}

return M
