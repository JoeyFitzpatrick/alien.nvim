local elements = require("alien.elements")
local actions = require("alien.actions")
local highlight = require("alien.highlight")
local config = require("alien.config")
local command_mode = require("alien.command-mode")
local nested_buffers = require("alien.nested-buffers")

local M = {}

config.config = vim.tbl_deep_extend("force", config.default_config, vim.g.alien_configuration or {})

M.setup = function()
  highlight.setup_colors()
  require("alien.keymaps").set_global_keymaps()
  command_mode.create_git_command(config.config.command_mode_commands)
  nested_buffers.setup_nested_buffers()
end

M.status = function()
  elements.buffer(actions.stats_and_status, { title = "AlienStatus" })
end

M.local_branches = function()
  elements.buffer(actions.local_branches, { title = "AlienBranches" })
end

M.blame = require("alien.global-actions.blame").blame

return M
