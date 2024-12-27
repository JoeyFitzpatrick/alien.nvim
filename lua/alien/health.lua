local M = {}

---@param exectuable string
---@param warn_only? boolean
local function check_executable(exectuable, warn_only)
    if vim.fn.executable(exectuable) == 1 then
        vim.health.ok(exectuable .. " is installed")
        return
    end
    if warn_only then
        vim.health.warn(exectuable .. " is not installed")
    else
        vim.health.error(exectuable .. " is not installed")
    end
end

M.check = function()
    vim.health.start("alien.nvim checks")

    local ok, alien = pcall(require, "alien")
    if not ok then
        vim.health.error("require('alien') failed")
    else
        vim.health.ok("require('alien') succeeded")

        if alien._setup_called then
            vim.health.ok("require('alien').setup() has been called")
        else
            vim.health.error("require('alien').setup() has not been called")
        end
    end

    check_executable("git")
    check_executable("delta", true)
    vim.fn.system("git -C . rev-parse 2>/dev/null")
    local in_git_repo = vim.v.shell_error == 0
    if in_git_repo then
        vim.health.ok("currently in git repository")
    else
        vim.health.error("not currently in git repository")
    end
end

return M
