local M = {}

--- Returns size of table comprised of key-value pairs
---@param tbl table<string, any>
M.tbl_size = function(tbl)
    local size = 0
    for _ in pairs(tbl) do
        size = size + 1
    end
    return size
end

return M
