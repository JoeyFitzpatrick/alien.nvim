local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action

local M = {}

local function handle_status_output(output)
	local head = output[1]
	local num_commits_to_pull = output[2]
	local num_commits_to_push = output[3]

	local pull_str = num_commits_to_pull == "0" and "" or "↓" .. num_commits_to_pull
	local push_str = num_commits_to_push == "0" and "" or "↑" .. num_commits_to_push
	for _ = 1, 3 do
		table.remove(output, 1)
	end
	table.insert(output, 1, head .. " " .. pull_str .. push_str)
	return output
end

M.stats_and_status = create_action({
	commands.current_head,
	commands.num_commits_to_pull,
	commands.num_commits_to_push,
	commands.staged_stats,
	commands.status,
}, {
	object_type = "local_file",
	output_handler = handle_status_output,
})

M.local_branches = create_action("git branch", { object_type = "local_branch" })

return M
