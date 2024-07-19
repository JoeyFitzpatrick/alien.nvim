local M = {
	local_file = {
		display_diff = true,
	},
	keymaps = {
		global = {
			branch_picker = "<leader>b",
		},
		local_file = {
			stage_or_unstage = "s",
			stage_or_unstage_all = "a",
			restore_file = "d",
			pull = "p",
			push = "<leader>p",
			commit = "c",
			commit_with_flags = "C",
			navigate_to_file = "<enter>",
			diff = "n",
			scroll_diff_down = "J",
			scroll_diff_up = "K",
		},
	},
}

return M
