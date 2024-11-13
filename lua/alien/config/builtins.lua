local M = {}

M.local_file_builtins = {
    STAGE_OR_UNSTAGE = "stage_or_unstage",
    STAGE_OR_UNSTAGE_ALL = "stage_or_unstage_all",
    RESTORE = "restore",
    PULL = "pull",
    PUSH = "push",
    COMMIT = "commit",
    NAVIGATE_TO_FILE = "navigate_to_file",
    TOGGLE_AUTO_DIFF = "toggle_auto_diff",
    SCROLL_DIFF_DOWN = "scroll_diff_down",
    SCROLL_DIFF_UP = "scroll_diff_up",
    VIMDIFF = "vimdiff",
    STASH = "stash",
    STASH_WITH_FLAGS = "stash_with_flags",
    AMEND = "amend",
}

M.local_branch_builtins = {
    SWITCH = "switch",
    NEW_BRANCH = "new_branch",
    DELETE = "delete",
    RENAME = "rename",
    MERGE = "merge",
    REBASE = "rebase",
    LOG = "log",
    PULL = "pull",
    PUSH = "push",
}

M.blame_builtins = {
    DISPLAY_FILES = "display_files",
    COPY_COMMIT_URL = "copy_commit_url",
    COMMIT_INFO = "commit_info",
}

M.commit_builtins = {
    DISPLAY_FILES = "display_files",
    REWORD = "reword",
    REVERT = "revert",
    RESET = "reset",
    COPY_COMMIT_URL = "copy_commit_url",
    COMMIT_INFO = "commit_info",
}

M.commit_file_builtins = {
    SCROLL_DIFF_DOWN = "scroll_diff_down",
    SCROLL_DIFF_UP = "scroll_diff_up",
    VIMDIFF = "vimdiff",
    TOGGLE_AUTO_DIFF = "toggle_auto_diff",
    OPEN_IN_VERTICAL_SPLIT = "open_in_vertical_split",
    OPEN_IN_HORIZONTAL_SPLIT = "open_in_horizontal_split",
    OPEN_IN_TAB = "open_in_tab",
    OPEN_IN_WINDOW = "open_in_window",
}

M.stash_builtins = {
    POP = "pop",
    APPLY = "apply",
    DROP = "drop",
}

return M
