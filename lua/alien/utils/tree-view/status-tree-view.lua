---@class StatusData
---@field display_name string
---@field name string
---@field type "dir" | "file"
---@field status? Status
---@field dir_status? "unstaged" | "staged" | "modified"

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

local function get_dir_status(dir_status, file_status)
    local STATUS_STAGED = require("alien.status").EXTRA_STATUSES.STATUS_STAGED
    local STATUS_UNSTAGED = require("alien.status").EXTRA_STATUSES.STATUS_UNSTAGED
    local STATUS_MODIFIED = require("alien.status").EXTRA_STATUSES.STATUS_MODIFIED
    local is_staged_file_status = require("alien.status").is_staged(file_status) or file_status == STATUS_STAGED
    if not dir_status then
        return is_staged_file_status and STATUS_STAGED or STATUS_UNSTAGED
    end
    if is_staged_file_status then
        if dir_status == STATUS_UNSTAGED or dir_status == STATUS_MODIFIED then
            return STATUS_MODIFIED
        else
            return STATUS_STAGED
        end
    else
        if dir_status == STATUS_STAGED or dir_status == STATUS_MODIFIED then
            return STATUS_MODIFIED
        else
            return STATUS_UNSTAGED
        end
    end
end

---@param node Node
---@param prefix? string
---@return StatusData[]
M.get_status_data = function(node, prefix)
    local status_data = {} ---@type StatusData[]
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
            ---@type StatusData
            local data = {
                display_name = display_name,
                name = child.full_name,
                type = DIR,
            }

            table.insert(status_data, data)
            local dir_lines = M.get_status_data(child, prefix .. require("alien.constants").TREE_SPACING)
            for _, dir_data in ipairs(dir_lines) do
                data.status = get_dir_status(data.status, dir_data.status)
            end

            for _, dir_data in ipairs(dir_lines) do
                if is_folded then
                    dir_data.display_name = nil
                end
                table.insert(status_data, dir_data)
            end
        elseif child.type == FILE then
            local child_full_name = child.full_name:match("%S+$")
            if child_full_name == nil then
                child_full_name = ""
            end
            ---@type StatusData
            local data = {
                display_name = prefix .. child.name,
                name = parent_name .. child_full_name,
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
        if data.display_name ~= nil then
            table.insert(lines, data.display_name)
        end
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

---@param status_data StatusData[]
---@param line_num integer
M._map_line_num_to_status_data = function(status_data, line_num)
    local filtered_status_data = vim.tbl_filter(function(data)
        return data.display_name ~= nil
    end, status_data)
    return filtered_status_data[line_num]
end

return M
