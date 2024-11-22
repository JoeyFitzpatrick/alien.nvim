local M = {}

--- Convert filepaths to tree view
---@param filepaths string[]
M.convert_to_tree_view = function(filepaths)
    for _, filepath in ipairs(filepaths) do
        local path_parts = {}
        for path_part in filepath:gmatch("[^/]+/") do
            table.insert(path_parts, path_part)
        end
        if not filepath:find("/$") then
            local lastPart = filepath:match(".-/([^/]+)$")
            if lastPart then
                table.insert(path_parts, lastPart)
            end
        end
        vim.print(path_parts)
    end
end

M.convert_to_tree_view({ "lua/alien/init.lua" })

return M
