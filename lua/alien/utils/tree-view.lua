---@class Node
---@field type "dir" | "file"
---@field name string
---@field children Node[]

local DIR = "dir"
local FILE = "file"

local M = {}

--- Flatten a node, such that nodes with a single dir child are concatenated together
---@param node Node
local function flatten_node(node)
    while #node.children == 1 and node.children[1].type == "dir" do
        local subdir_child = node.children[1]
        if node.name == nil then
            node.name = ""
        else
            node.name = node.name .. "/"
        end
        node.name = node.name .. subdir_child.name
        node.children = subdir_child.children
        node.type = subdir_child.type
    end

    for _, child in ipairs(node.children) do
        flatten_node(child)
    end
end

--- Sort a node. Dirs before files at the same level, then sort alphabetically
---@param node Node
local function sort_node(node)
    table.sort(node.children, function(a, b)
        if a.type == b.type then
            return a.name < b.name
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

--- Convert filepaths to tree view
---@param filepaths string[]
---@return Node
M._convert_to_tree_view = function(filepaths)
    local nodes = { children = {} }

    local function find_or_create_node(current_node, part, type)
        for _, child in ipairs(current_node.children) do
            if child.name == part then
                return child
            end
        end
        local new_node = { name = part, type = type, children = {} }
        table.insert(current_node.children, new_node)
        return new_node
    end

    for _, filepath in ipairs(filepaths) do
        local path_parts = {}
        for path_part in filepath:gmatch("[^/]+") do
            table.insert(path_parts, path_part)
        end
        local current_node = nodes
        for i, part in ipairs(path_parts) do
            local type = (i == #path_parts) and FILE or DIR
            current_node = find_or_create_node(current_node, part, type)
        end
    end

    flatten_node(nodes)
    return nodes
end

--- Get a file tree from a base node.
---@param node Node
---@param prefix? string
---@return string[]
M._node_to_file_tree = function(node, prefix)
    local lines = {}
    prefix = prefix or ""

    sort_node(node)
    for _, child in ipairs(node.children) do
        local line
        if child.type == DIR then
            line = prefix .. "  " .. child.name
            table.insert(lines, line)
            local dir_lines = M._node_to_file_tree(child, prefix .. "    ")
            for _, l in ipairs(dir_lines) do
                table.insert(lines, l)
            end
        elseif child.type == FILE then
            line = prefix .. child.name
            table.insert(lines, line)
        end
    end

    return lines
end

--- Get a file tree from a list of filepaths, by converting them to a node first.
---@param filepaths string[]
M.get_file_tree = function(filepaths)
    return M._node_to_file_tree(M._convert_to_tree_view(filepaths))
end

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
        table.insert(parsed_filepaths, path:sub(3, last_slash_index) .. status .. " " .. path:sub(last_slash_index + 1))
        ::continue::
    end
    return M.get_file_tree(parsed_filepaths)
end

return M
