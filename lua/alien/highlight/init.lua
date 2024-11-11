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
    r = math.floor(r * modification_level) -- Decrease the intensity by 20%
    g = math.floor(g * modification_level)
    b = math.floor(b * modification_level)
    return rgbToHex(r, g, b)
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
