---@class Node
---@field type "dir" | "file"
---@field name string
---@field full_name string
---@field children Node[]

local M = {}

--- Flatten a node, such that nodes with a single dir child are concatenated together
---@param base_node Node
M._flatten_node = function(base_node)
    local function flatten(node)
        for _, child in ipairs(node.children) do
            flatten(child)
        end
        while #node.children == 1 and node.children[1].type == "dir" do
            local subdir_child = node.children[1]
            node.name = node.name and node.name .. "/" or ""
            node.full_name = node.full_name and node.full_name .. "/" or ""
            node.name = node.name .. subdir_child.name
            node.full_name = subdir_child.full_name
            node.children = subdir_child.children
            node.type = subdir_child.type
        end
    end
    flatten(base_node)
end

--- Sort a node. Dirs before files at the same level, then sort alphabetically
---@param node Node
local function sort_node(node)
    table.sort(node.children, function(a, b)
        if a.type == b.type then
            if a.type == "file" then
                return a.name:sub(4) < b.name:sub(4) -- don't account for status when sorting
            else
                return a.name < b.name
            end
        else
            return a.type == "dir"
        end
    end)

    for _, child in ipairs(node.children) do
        if child.type == "dir" then
            sort_node(child)
        end
    end
end

M._sort_node = sort_node

---@param current_node Node
---@param part string
---@param type "file" | "dir"
---@return Node
M._find_or_create_node = function(current_node, part, type)
    for _, child in ipairs(current_node.children) do
        if child.name == part then
            return child
        end
    end
    local parent_name = current_node.full_name and current_node.full_name .. "/" or ""
    ---@type Node
    local new_node = { name = part, full_name = parent_name .. part, type = type, children = {} }
    table.insert(current_node.children, new_node)
    return new_node
end

return M
