local commands = require("alien.commands")
local window_constants = require("alien.window.constants")
local helpers = require("alien.utils.helpers")

local FIRST_BRANCH_LINE_NUMBER = 2

local M = {}
M.is_current_branch = function(line)
	return line:sub(1, 1) == "*"
end

M.get_branch_name_from_line = function(line)
	return line:sub(3)
end

M.set_buffer_colors = function()
	local line_count = vim.api.nvim_buf_line_count(0)
	for line_number = FIRST_BRANCH_LINE_NUMBER, line_count do
		local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

		if M.is_current_branch(line) then
			vim.api.nvim_buf_add_highlight(0, -1, "AlienCurrentBranch", line_number - 1, 0, -1)
			vim.api.nvim_buf_add_highlight(0, -1, "AlienBranchStar", line_number - 1, 0, 1)
		end
	end
end

M.get_buffer_args = function()
	local lines = vim.fn.systemlist(commands.local_branches)
	local buffer_type = window_constants.BUFFER_TYPES.BRANCHES
	table.insert(lines, 1, window_constants.BUFFER_TYPE_STRING[buffer_type])
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	end
	return {
		buffer_type = require("alien.window.constants").BUFFER_TYPES.BRANCHES,
		set_lines = set_lines,
		cursor_pos = { FIRST_BRANCH_LINE_NUMBER, 0 },
		set_keymaps = require("alien.keymaps.branch").set_status_buffer_keymaps,
		set_colors = M.set_buffer_colors,
	}
end

M.display_branch_picker = function(opts)
	opts = opts or {}
	local telescope = helpers.load_plugin("telescope")
	if not telescope then
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	pickers
		.new(opts, {
			prompt_title = "git branches",
			finder = finders.new_table({
				-- remove the "remotes/origin/" prefix from remote branches, and remove duplicates
				results = vim.fn.systemlist(
					"git branch --all --sort=-committerdate | sed 's|remotes/origin/||' | awk '!seen[$0]++'"
				),
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local branch_name = action_state.get_selected_entry()[1]
					local result = vim.fn.system("git checkout " .. branch_name)
					local exit_status = vim.v.shell_error

					-- Check the exit status to see if there was an error
					if exit_status ~= 0 then
						-- Exit status is non-zero, meaning git checkout failed
						-- Use vim.notify to show an error message
						vim.notify("Failed to checkout branch " .. branch_name .. ":\n" .. result, vim.log.levels.ERROR)
					else
						-- Exit status is zero, meaning git checkout was successful
						-- Use vim.notify to show a success message
						vim.notify(
							"Successfully checked out branch " .. branch_name .. ".\n" .. result,
							vim.log.levels.INFO
						)
					end
				end)
				return true
			end,
		})
		:find()
end

return M
