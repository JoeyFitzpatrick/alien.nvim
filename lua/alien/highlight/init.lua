local M = {}

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
