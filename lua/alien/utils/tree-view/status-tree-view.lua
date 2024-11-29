---@class StatusData
---@field display_name string
---@field name string
---@field type "dir" | "file"
---@field status? Status

local DIR = "dir"
local FILE = "file"

local M = {}

--- Convert filepaths to nodes
---@param filepaths string[]
---@return Node
M._create_nodes = function(filepaths)
    local nodes = { children = {} }
    for _, filepath in ipairs(filepaths) do
        local path_parts = {} ---@type string[]
        for path_part in filepath:gmatch("[^/]+") do
            table.insert(path_parts, path_part)
        end
        local status = path_parts[1]:sub(1, 2)
        path_parts[1] = path_parts[1]:sub(4)
        path_parts[#path_parts] = status .. " " .. path_parts[#path_parts]
        local current_node = nodes
        for i, part in ipairs(path_parts) do
            local type = (i == #path_parts) and FILE or DIR
            current_node = require("alien.utils.tree-view")._find_or_create_node(current_node, part, type)
        end
    end
    require("alien.utils.tree-view")._flatten_node(nodes)
    require("alien.utils.tree-view")._sort_node(nodes)
    return nodes
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
        table.insert(parsed_filepaths, path:sub(4, last_slash_index) .. status .. " " .. path:sub(last_slash_index + 1))
        ::continue::
    end
    return require("alien.utils.tree-view").get_file_tree(parsed_filepaths)
end

---@param node Node
---@param prefix? string
---@return StatusData[]
M.get_status_data = function(node, prefix)
    local status_data = {} ---@type StatusData[]
    prefix = prefix or ""

    for _, child in ipairs(node.children) do
        local parent_name = node.full_name and node.full_name .. "/" or ""
        if child.type == DIR then
            ---@type StatusData
            local data = {
                display_name = prefix .. "   " .. child.name,
                name = child.full_name,
                type = DIR,
            }
            table.insert(status_data, data)
            local dir_lines = M.get_status_data(child, prefix .. require("alien.constants").TREE_SPACING)
            for _, dir_data in ipairs(dir_lines) do
                table.insert(status_data, dir_data)
            end
        elseif child.type == FILE then
            ---@type StatusData
            local data = {
                display_name = prefix .. child.name,
                name = parent_name .. child.full_name:match("%S+$"),
                type = FILE,
                status = child.name:match("^(..)%s"),
            }
            table.insert(status_data, data)
        end
    end

    return status_data
end

---@param status_data StatusData[]
M.render_status_data = function(status_data)
    local lines = {}
    for _, data in ipairs(status_data) do
        table.insert(lines, data.display_name)
    end
    return lines
end

---@param filepaths string[]
---@return { lines: string[], status_data: StatusData[] }
M.render_status_file_tree = function(filepaths)
    local nodes = M._create_nodes(filepaths)
    local status_data = M.get_status_data(nodes)
    local lines = M.render_status_data(status_data)
    return {
        lines = lines,
        status_data = status_data,
    }
end

return M
