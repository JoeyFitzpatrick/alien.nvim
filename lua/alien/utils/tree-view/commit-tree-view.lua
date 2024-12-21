---@class CommitData
---@field display_name string
---@field name string
---@field type "dir" | "file"

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
        local current_node = nodes
        for i, part in ipairs(path_parts) do
            local type = (i == #path_parts) and FILE or DIR
            current_node = require("alien.utils.tree-view")._find_or_create_node(current_node, part, type)
        end
    end
    require("alien.utils.tree-view")._flatten_node(nodes)
    require("alien.utils.tree-view")._sort_node(nodes, true)
    return nodes
end

---@param node Node
---@param prefix? string
---@return CommitData[]
M.get_commit_data = function(node, prefix)
    local commit_data = {} ---@type CommitData[]
    prefix = prefix or ""
    local state = require("alien.elements.register.state").get_state(vim.api.nvim_get_current_buf())

    for _, child in ipairs(node.children) do
        local parent_name = node.full_name and node.full_name .. "/" or ""
        local file_state_exists = state ~= nil
            and state.specific_state ~= nil
            and state.specific_state[child.full_name] ~= nil
        local is_folded = file_state_exists == true and state.specific_state[child.full_name].folded == true

        if child.type == DIR then
            local display_name = is_folded and prefix .. "   " .. child.name
                or prefix .. "   " .. child.name
            ---@type CommitData
            local data = {
                display_name = display_name,
                name = child.full_name,
                type = DIR,
            }

            table.insert(commit_data, data)
            local dir_lines = M.get_commit_data(child, prefix .. require("alien.constants").TREE_SPACING)

            for _, dir_data in ipairs(dir_lines) do
                if is_folded then
                    dir_data.display_name = nil
                end
                table.insert(commit_data, dir_data)
            end
        elseif child.type == FILE then
            local child_full_name = child.full_name
            if child_full_name == nil then
                child_full_name = ""
            end
            ---@type CommitData
            local data = {
                display_name = prefix .. child.name,
                name = child_full_name,
                type = FILE,
            }
            table.insert(commit_data, data)
        end
    end

    return commit_data
end

---@param commit_data CommitData[]
M.render_commit_data = function(commit_data)
    local lines = {}
    for _, data in ipairs(commit_data) do
        if data.display_name ~= nil then
            table.insert(lines, data.display_name)
        end
    end
    return lines
end

---@param filepaths string[]
---@return { lines: string[], commit_data: CommitData[] }
M.render_commit_file_tree = function(filepaths)
    local nodes = M._create_nodes(filepaths)
    local commit_data = M.get_commit_data(nodes)
    local lines = M.render_commit_data(commit_data)
    return {
        lines = lines,
        commit_data = commit_data,
    }
end

---@param commit_data CommitData[]
---@param line_num integer
M._map_line_num_to_commit_data = function(commit_data, line_num)
    local filtered_commit_data = vim.tbl_filter(function(data)
        return data.display_name ~= nil
    end, commit_data)
    return filtered_commit_data[line_num]
end

return M
