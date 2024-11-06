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
  return new_hex
end

local function get_colors(name)
  local success, color = pcall(vim.api.nvim_get_hl, 0, { name = name })
  if not success then
    print("Could not retrieve highlight group:", name)
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
  local bg = get_colors("Normal")
  local red = get_colors("Error")
  local red_bg_dark = "4f1d21"
  local red_bg_light = "620000"
  local orange = get_colors("SpecialChar")
  local yellow = "e9b770"
  -- local yellow = get_colors("PreProc")
  local green = "66ff00"
  local green_bg_dark = "27542a"
  local green_bg_light = "006200"
  local cyan = get_colors("Operator")
  local blue = get_colors("Macro")
  local dark_blue = "020204"
  local light_blue = "03cff6"
  local purple = "e1a2da"
  -- local purple = get_colors("Include")
  return {
    bg = "#" .. bg,
    red = "#" .. red,
    red_bg_dark = "#" .. red_bg_dark,
    red_bg_light = "#" .. red_bg_light,
    orange = "#" .. orange,
    yellow = "#" .. yellow,
    green = "#" .. green,
    green_bg_dark = "#" .. green_bg_dark,
    green_bg_light = "#" .. green_bg_light,
    cyan = "#" .. cyan,
    blue = "#" .. blue,
    dark_blue = "#" .. dark_blue,
    light_blue = "#" .. light_blue,
    purple = "#" .. purple,
  }
end

M.setup_colors = function()
  local colors = M.get_palette()
  -- foreground colors
  vim.cmd(string.format("highlight %s guifg=%s", "AlienStaged", colors.green))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienDiffAdd", colors.green))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienCurrentBranch", colors.green))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienPartiallyStaged", colors.orange))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienUnstaged", colors.red))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienDiffRemove", colors.red))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienBranchName", colors.purple))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienBranchStar", colors.purple))
  vim.cmd(string.format("highlight %s guifg=%s", "AlienTimeMachineCommit", colors.purple))
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
