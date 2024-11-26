local M = {}

--- Find the author name in a line of log text, and return the start and end indexes if found.
--- This is used to highlight the author name.
---@param line string
---@return integer|nil, integer|nil
M._find_author = function(line)
    local name_start, name_end = line:find("%s%s+(.-)%s%s+")
    return name_start, name_end
end

M.highlight_oneline_pretty = function(bufnr)
    local hlgroups = require("alien.highlight.constants").highlight_groups
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        local commit = require("alien.extractors.commit-extractor").extract(line)
        if commit then
            vim.api.nvim_buf_add_highlight(bufnr, -1, hlgroups.ALIEN_SECONDARY, i - 1, commit.start, commit.ending)
            local name_start, name_end = M._find_author(line)
            if name_start ~= nil and name_end ~= nil then
                vim.api.nvim_buf_add_highlight(bufnr, -1, hlgroups.ALIEN_TITLE, i - 1, name_start - 1, name_end)
            end
        end
    end
end

M.highlight = function(bufnr)
    vim.api.nvim_set_option_value("filetype", "git", { buf = bufnr })
end

return M
