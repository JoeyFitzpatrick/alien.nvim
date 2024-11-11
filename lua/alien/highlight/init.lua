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
    return rgbToHex(r, g, b)
end

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

---@param name string
---@return vim.api.keyset.get_hl_info | nil
local function get_colors(name)
    local success, color = pcall(vim.api.nvim_get_hl, 0, { name = name })
    if not success then
        return nil
    end

    if color["link"] then
        return get_colors(color["link"])
    end
    return color
end

M.setup_highlights = function()
    local hlgroup = require("alien.highlight.constants").highlight_groups
    vim.api.nvim_set_hl(0, hlgroup.ALIEN_DIFF_ADD, { bg = M.modify_color(to_hex(get_colors("DiffAdd")["bg"]), 1.4) })
    vim.api.nvim_set_hl(
        0,
        hlgroup.ALIEN_DIFF_DELETE,
        { bg = M.modify_color(to_hex(get_colors("DiffDelete")["fg"]), 0.4) }
    )
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
