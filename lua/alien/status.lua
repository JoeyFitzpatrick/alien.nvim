---@alias Status "A " | "AA" | " A" | "C " | " C" | "DD" | "DM" | "D " | " D" | "MM" | "M " | " M" | "R " | " R" | "UU" | "??"

local M = {}

---@type table<string, Status>
M.STATUSES = {
    ADDED = "A ",
    ADDED_BOTH_STAGED_UNSTAGED = "AA",
    ADDED_UNSTAGED = " A",
    COPIED_STAGED = "C ",
    COPIED_UNSTAGED = " C",
    DELETED_BOTH_STAGED_UNSTAGED = "DD",
    DELETED_MODIFIED_UNSTAGED = "DM",
    DELETED_STAGED = "D ",
    DELETED_UNSTAGED = " D",
    MODIFIED_PARTIALLY_STAGED = "MM",
    MODIFIED_STAGED = "M ",
    MODIFIED_UNSTAGED = " M",
    RENAMED_STAGED = "R ",
    RENAMED_UNSTAGED = " R",
    UNMERGED = "UU",
    UNTRACKED = "??",
}

M.EXTRA_STATUSES = {
    STATUS_STAGED = "staged",
    STATUS_UNSTAGED = "unstaged",
    STATUS_MODIFIED = "modified",
}

---@param status string
---@return boolean
M.is_valid_status = function(status)
    for _, valid_status in pairs(M.STATUSES) do
        if valid_status == status then
            return true
        end
    end
    return false
end

---@param status string
---@return boolean
M.is_staged = function(status)
    local staged_statuses = {
        M.STATUSES.MODIFIED_STAGED,
        M.STATUSES.ADDED,
        M.STATUSES.DELETED_STAGED,
        M.STATUSES.RENAMED_STAGED,
        M.STATUSES.COPIED_STAGED,
        M.EXTRA_STATUSES.STATUS_STAGED,
    }
    return vim.tbl_contains(staged_statuses, status)
end

---@param status string
---@return boolean
M.is_modified = function(status)
    local modified_statuses = {
        M.STATUSES.ADDED_BOTH_STAGED_UNSTAGED,
        M.STATUSES.DELETED_BOTH_STAGED_UNSTAGED,
        M.STATUSES.DELETED_MODIFIED_UNSTAGED,
        M.STATUSES.MODIFIED_PARTIALLY_STAGED,
        M.EXTRA_STATUSES.STATUS_MODIFIED,
    }
    return vim.tbl_contains(modified_statuses, status)
end

--- Returns true for a git status that represents a deleted file, and false otherwise.
---@param status string
---@return boolean
M.is_deleted = function(status)
    local deleted_statuses = {
        M.STATUSES.DELETED_BOTH_STAGED_UNSTAGED,
        M.STATUSES.DELETED_MODIFIED_UNSTAGED,
        M.STATUSES.DELETED_STAGED,
        M.STATUSES.DELETED_UNSTAGED,
    }
    return vim.tbl_contains(deleted_statuses, status)
end

--- Returns true for a git status that represents a deleted file, and false otherwise.
---@param status string
---@return boolean
M.is_renamed = function(status)
    local renamed_statuses = {
        M.STATUSES.RENAMED_STAGED,
        M.STATUSES.RENAMED_UNSTAGED,
    }
    return vim.tbl_contains(renamed_statuses, status)
end

return M
