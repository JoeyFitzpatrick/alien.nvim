local M = {}

--- Get raw diff stats for a group of files.
---@param commit1 string
---@param commit2 string
---@return { files_with_status: string[], files_with_changed_lines: string[] }
M._get_raw_diff_stats = function(commit1, commit2)
    local files_with_status = vim.fn.systemlist(string.format("git diff --name-status %s %s", commit1, commit2))
    local files_with_changed_lines = vim.fn.systemlist(string.format("git diff --numstat %s %s", commit1, commit2))
    return { files_with_status = files_with_status, files_with_changed_lines = files_with_changed_lines }
end

--- Get diff stats for a group of files.
--- Each file should be formatted something like `status` `filename` `number of changed files`
---@param commit1 string
---@param commit2 string
---@return string[]
M.get_diff_stats = function(commit1, commit2)
    local raw_diff_stats = M._get_raw_diff_stats(commit1, commit2)
    local files_with_status = raw_diff_stats.files_with_status
    local files_with_changed_lines = raw_diff_stats.files_with_changed_lines
    if #files_with_status ~= #files_with_changed_lines then
        error("Alien: unable to parse diff stats")
    end
    local diff_stats = {}
    for i = 1, #files_with_status do
        local file_with_status = files_with_status[i]
        local file_with_changed_lines = files_with_changed_lines[i]
        local status = file_with_status:sub(1, 1)
        local filename = file_with_status:match("%S+$")
        local lines_added = file_with_changed_lines:match("%S+")
        local lines_removed = file_with_changed_lines:match("%s(%S+)")
        table.insert(diff_stats, string.format("%s %s %d, %d", status, filename, lines_added, lines_removed))
    end
    return diff_stats
end

return M
