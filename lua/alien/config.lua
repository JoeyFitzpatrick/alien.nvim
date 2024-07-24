local M = {
	local_file = {
		display_diff = true,
	},
	keymaps = {
		global = {
			branch_picker = "<leader>B",
		},
		local_file = {
			stage_or_unstage = "s",
			stage_or_unstage_all = "a",
			restore_file = "d",
			pull = "p",
			pull_with_flags = "P",
			push = "<leader>p",
			push_with_flags = "<leader>P",
			commit = "c",
			commit_with_flags = "C",
			navigate_to_file = "<enter>",
			diff = "n",
			scroll_diff_down = "J",
			scroll_diff_up = "K",
		},
		local_branch = {
			switch = "s",
			new_branch = "n",
			delete = "d",
			rename = "R",
			merge = "m",
			rebase = "r",
		},
	},
}

return M