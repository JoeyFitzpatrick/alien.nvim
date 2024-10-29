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
      stage_or_unstage = "s",
      stage_or_unstage_all = "a",
      restore = "d",
      pull = "p",
      push = "<leader>p",
      commit = "c",
      navigate_to_file = "<enter>",
      toggle_auto_diff = "t",
      scroll_diff_down = "J",
      scroll_diff_up = "K",
      vimdiff = "D",
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
      log = "l",
      pull = "p",
      push = "<leader>p",
    },
    blame = {
      display_files = "s",
      copy_commit_url = "o",
      commit_info = "i",
    },
    commit = {
      display_files = "s",
      reword = "rw",
      revert = "rv",
      reset = "rs",
      copy_commit_url = "o",
      commit_info = "i",
    },
    commit_file = {
      open = "s",
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
