local M = {}

--- Display detailed diff for a given local file
---@param local_file LocalFile
M.display_detailed_diff = function(local_file)
    require("alien.elements").window(
        "git diff --cached " .. local_file.filename,
        { buffer_name = "Staged changes -- " .. local_file.raw_filename },
        function(_, bufnr)
            require("alien.keymaps.diff-keymaps").set_staging_keymaps(bufnr, true)
        end
    )

    require("alien.elements").split(
        "git diff " .. local_file.filename,
        { buffer_name = "Unstaged changes -- " .. local_file.raw_filename, split_opts = { split = "left" } },
        function(_, bufnr)
            require("alien.keymaps.diff-keymaps").set_staging_keymaps(bufnr, false)
        end
    )
end

return M
