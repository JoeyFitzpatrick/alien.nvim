---@class Node
---@field type "dir" | "file"
---@field children Node[]

local M = {}

---@param path_parts string[]
---@return Node
local function create_node(path_parts)
    local node = {}
    local current_node = {}
    node = current_node
    for i, part in ipairs(path_parts) do
        local type = i == #path_parts and "file" or "dir"
        current_node[part] = { type = type, children = {} }
        current_node = current_node[part].children
    end
    return node
end

--- Convert filepaths to tree view
---@param filepaths string[]
M.convert_to_tree_view = function(filepaths)
    local nodes = { children = {} }
    local current_node = nodes
    for _, filepath in ipairs(filepaths) do
        local path_parts = {}
        for path_part in filepath:gmatch("[^/]+") do
            table.insert(path_parts, path_part)
        end
        for i, part in ipairs(path_parts) do
            if current_node.children[part] then
                print("here")
                current_node = current_node.children[part]
            else
                current_node.children[part] = create_node({ unpack(path_parts, i) })[part]
                break
            end
        end
        current_node = nodes
    end
    return nodes
end

vim.print(M.convert_to_tree_view({ "lua/alien/init.lua", "lua/alien/constants.lua" }))

return M
