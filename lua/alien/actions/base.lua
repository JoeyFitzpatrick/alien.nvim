local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action

local M = {}

M.status = create_action(commands.status)
M.stats = create_action(commands.stats)
M.stats_and_status = create_action(commands.stats_and_status, "local_file")
M.commits_to_pull = create_action(commands.num_commits("pull"))
M.commits_to_push = create_action(commands.num_commits("push"))

return M
