local M = {}

local function hexToRgb(hex)
    local r = tonumber(hex:sub(2, 3), 16)
    local g = tonumber(hex:sub(4, 5), 16)
    local b = tonumber(hex:sub(6, 7), 16)
    return r, g, b
end

local function rgbToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

M.modify_color = function(hex, modification_level)
    local r, g, b = hexToRgb(hex)
    r = math.floor(r * modification_level)
    g = math.floor(g * modification_level)
    b = math.floor(b * modification_level)
    return rgbToHex(r, g, b):sub(1, 7)
end

M.setup_highlights = function()
    local hlgroup = require("alien.highlight.constants").highlight_groups
    local is_light_background = vim.api.nvim_get_option_value("background", {}) == "light"
    vim.api.nvim_set_hl(0, hlgroup.ALIEN_DIFF_ADD, { bg = is_light_background and "NvimLightGreen" or "NvimDarkGreen" })
    vim.api.nvim_set_hl(0, hlgroup.ALIEN_DIFF_DELETE, { bg = is_light_background and "NvimLightRed" or "NvimDarkRed" })
    vim.api.nvim_set_hl(0, hlgroup.ALIEN_TITLE, { fg = is_light_background and "NvimDarkCyan" or "NvimLightCyan" })
    vim.api.nvim_set_hl(
        0,
        hlgroup.ALIEN_SECONDARY,
        { fg = is_light_background and "NvimDarkMagenta" or "NvimLightYellow" }
    )
    vim.api.nvim_set_hl(
        0,
        hlgroup.ALIEN_DIFF_TEXT,
        { fg = is_light_background and "NvimDarkGrey3" or "NvimLightGrey3" }
    )
    vim.api.nvim_set_hl(0, hlgroup.ALIEN_ERROR_MSG, { fg = is_light_background and "NvimDarkRed" or "NvimLightRed" })
end

--- Get the highlight group by object type
---@param object_type AlienObject
---@return function | nil
M.get_highlight_by_object = function(object_type)
    ---@type table<AlienObject, function>
    if not object_type then
        return nil
    end
    local ok, highlight_module = pcall(require, "alien.highlight." .. object_type:gsub("_", "-") .. "-highlight")
    if not ok or not highlight_module then
        return nil
    end
    return highlight_module.highlight
end

return M
