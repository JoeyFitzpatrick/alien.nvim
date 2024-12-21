---@param action_output string[]
---@return CommitData[]
return function(action_output)
    local commit_file_tree = require("alien.utils.tree-view.commit-tree-view").render_commit_file_tree(action_output)
    local current_state = require("alien.elements.register.state").get_state(vim.api.nvim_get_current_buf()) or {}
    local specific_state = current_state.specific_state or {}
    return { commit_data = commit_file_tree.commit_data, specific_state = specific_state }
end
