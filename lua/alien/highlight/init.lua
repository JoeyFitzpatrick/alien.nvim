local M = {}

local function to_hex(dec)
  local hex = ""
  if type(dec) == "string" then
    hex = dec
  else
    hex = string.format("%x", dec)
  end
  local new_hex = ""
  if #hex < 6 then
    new_hex = string.rep("0", 6 - #hex) .. hex
  else
    new_hex = hex
  end
  return "#" .. new_hex
end

local function get_colors(name)
  local success, color = pcall(vim.api.nvim_get_hl, 0, { name = name })
  if not success then
    return nil
  end

  if color["link"] then
    return to_hex(get_colors(color["link"]))
  elseif color["reverse"] and color["bg"] then
    return to_hex(color["bg"])
  elseif color["fg"] then
    return to_hex(color["fg"])
  end
end

M.get_palette = function()
  return {
    bg = get_colors("Normal"),
    red = get_colors("Error"),
    red_bg_dark = "#4f1d21",
    red_bg_light = "#620000",
    orange = get_colors("SpecialChar"),
    yellow = "#e9b770",
    -- yellow = get_colors("PreProc"),
    green = "#66ff00",
    light_green = "#84E184",
    green_bg_dark = "#27542a",
    green_bg_light = "#006200",
    cyan = get_colors("Operator"),
    blue = get_colors("Macro"),
    dark_blue = "#020204",
    light_blue = "#93D7FF",
    purple = "#e1a2da",
    -- purple = get_colors("Include"),
  }
end

M.setup_colors = function()
  local colors = M.get_palette()
  -- foreground colors
  vim.cmd(string.format("highlight %s guifg=%s", "AlienStaged", colors.green))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienDiffAdd", colors.green))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienCurrentBranch", colors.light_green))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienPartiallyStaged", colors.orange))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienUnstaged", colors.red))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienDiffRemove", colors.red))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienBranchName", colors.purple))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienHead", colors.purple))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienPushPullString", colors.yellow))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienCommitHash", colors.yellow))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienCommitFile", colors.yellow))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienBlameDate", colors.red))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienStashName", colors.yellow))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienCommitAuthorName", colors.light_blue))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienSpinner", colors.light_blue))

  -- background colors
  vim.cmd(string.format("highlight %s guibg=%s", "AlienStagedBg", colors.green_bg_dark))
  vim.cmd(string.format("highlight %s guibg=%s", "AlienUnstagedBg", colors.red_bg_dark))
  vim.cmd(string.format("highlight %s guibg=%s", "AlienTimeMachineCurrentCommit", colors.orange))
  vim.cmd(string.format("highlight %s guibg=%s", "AlienDiffNew", colors.green_bg_dark))
  vim.cmd(string.format("highlight %s guibg=%s", "AlienDiffOld", colors.red_bg_dark))

  -- highlights with fg and bg
  vim.cmd(string.format("highlight %s guifg=%s guibg=%s", "AlienCommitFileLineNr", colors.light_blue, colors.dark_blue))
end

--- Get the highlight group by object type
---@param object_type AlienObject
---@return function
M.get_highlight_by_object = function(object_type)
  ---@type table<AlienObject, function>
  local object_highlight_map = {
    local_file = require("alien.highlight.local-file-highlight").highlight,
    local_branch = require("alien.highlight.local-branch-highlight").highlight,
    commit = require("alien.highlight.commit-highlight").highlight,
    commit_file = require("alien.highlight.commit-file-highlight").highlight,
    blame = require("alien.highlight.blame-highlight").highlight,
    stash = require("alien.highlight.stash-highlight").highlight,
    show = require("alien.highlight.generic-highlight").highlight,
    diff = require("alien.highlight.generic-highlight").highlight,
  }
  return object_highlight_map[object_type]
end

return M
