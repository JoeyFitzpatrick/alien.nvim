---@param action_output string[]
---@return StatusData[]
return function(action_output)
    local status_file_tree = require("alien.utils.tree-view.status-tree-view").render_status_file_tree(action_output)
    return status_file_tree.status_data
end
