local M = {}

--- Display detailed diff for a given local file
---@param local_file LocalFile
M.display_detailed_diff = function(local_file)
    require("alien.elements").window(
        "git diff " .. local_file.filename,
        { buffer_name = "Unstaged changes -- " .. local_file.raw_filename }
    )
    require("alien.elements").split(
        "git diff --cached " .. local_file.filename,
        { buffer_name = "Staged changes -- " .. local_file.raw_filename }
    )
end

return M
