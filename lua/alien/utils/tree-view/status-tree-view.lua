local M = {}

--- Turn the output of "git status --porcelain" into a file tree
---@param filepaths string[]
M.get_status_output_tree = function(filepaths)
    local parsed_filepaths = {}
    for _, path in ipairs(filepaths) do
        local last_slash_index = path:match(".*()/")
        if last_slash_index == nil then
            goto continue
        end
        local status = path:sub(1, 2)
        table.insert(parsed_filepaths, path:sub(4, last_slash_index) .. status .. " " .. path:sub(last_slash_index + 1))
        ::continue::
    end
    return require("alien.utils.tree-view").get_file_tree(parsed_filepaths)
end

return M
