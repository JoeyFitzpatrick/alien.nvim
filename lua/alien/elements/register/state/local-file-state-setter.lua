---@param action_output string[]
---@return StatusData[]
return function(action_output)
    local status_file_tree = require("alien.utils.tree-view.status-tree-view").render_status_file_tree(action_output)
    local current_state = require("alien.elements.register.state").get_state(vim.api.nvim_get_current_buf()) or {}
    local specific_state = current_state.specific_state or {}
    return { status_data = status_file_tree.status_data, specific_state = specific_state }
end
