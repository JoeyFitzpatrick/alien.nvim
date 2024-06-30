local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action

local M = {}

M.status = create_action(commands.status)
M.stats = create_action({
	{ commands.current_head, commands.num_commits("pull"), commands.num_commits("push") },
	commands.staged_stats,
})
M.commits_to_pull = create_action(commands.num_commits("pull"))
M.commits_to_push = create_action(commands.num_commits("push"))

return M
