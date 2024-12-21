---@alias CommandArgs LocalBranch | Commit

local M = {}

--- Create a command string or function that returns a command string.
--- If the command is a function, pass a get_args fn that returns the arguments to the command.
---@param cmd string | (fun(args?: CommandArgs): string)
---@param get_args function | nil
---@param input string | nil
M.create_command = function(cmd, get_args, input)
    if type(cmd) == "string" then
        return cmd
    end
    if not get_args then
        return cmd()
    end
    return function()
        local args = { get_args() }
        if not args or #args == 0 then
            return cmd({}, input)
        end
        table.insert(args, input)
        local unpack = unpack or table.unpack
        local ok, result = pcall(cmd, unpack(args))
        if ok then
            return result
        end
    end
end

--- Get the arguments to pass to create_command
---@param extract fun(string): table
---@return fun(input: string | nil): (table | fun(): table)
M.get_args = function(extract)
    return function(input)
        if input then
            return function()
                return extract(vim.api.nvim_get_current_line()), input
            end
        end
        return extract(vim.api.nvim_get_current_line())
    end
end

M.status = "git status --porcelain --untracked=all | sort -k1.4"
-- output stats for staged files, or a message if no files are staged
M.staged_stats =
    "git diff --staged --shortstat | grep -q '^' && git diff --staged --shortstat || echo 'No files staged'"
M.current_head = "git rev-parse --abbrev-ref HEAD"

---@param branch? string
M.num_commits_to_pull = function(branch)
    if not branch then
        return "git rev-list --count HEAD..@{u}"
    end
    return string.format("git rev-list --count %s..origin/%s", branch, branch)
end

---@param branch? string
M.num_commits_to_push = function(branch)
    if not branch then
        return "git rev-list --count @{u}..HEAD"
    end
    return string.format("git rev-list --count origin/%s..%s", branch, branch)
end

---@param branch? string
M.current_remote = function(branch)
    branch = branch or "HEAD"
    return "git rev-parse --symbolic-full-name --abbrev-ref " .. branch .. "@{u}"
end

-- TODO: make this work for non-github urls
local function find_remote_url()
    local handle = io.popen("git config --get remote.origin.url")
    if not handle then
        error("Could not fetch remote.origin.url from config")
    end
    local repo_url = handle:read("*a")
    handle:close()

    if not repo_url or repo_url == "" then
        error("Could not fetch the GitHub URL. Ensure you're in a git repository with a remote 'origin'.")
    end

    repo_url = repo_url:gsub("\n", "")
    if repo_url:sub(1, 4) == "git@" then
        -- SSH Format: git@github.com:user/repo.git
        repo_url = repo_url:match("git@github.com:(.+).git")
    elseif repo_url:sub(1, 8) == "https://" then
        -- HTTPS Format: https://github.com/user/repo.git
        repo_url = repo_url:match("https://github.com/(.+).git")
        -- Alternatively, handle URLs without a ".git" suffix
        if not repo_url then
            repo_url = repo_url:match("https://github.com/(.+)")
        end
    else
        error("The URL format is unrecognized or unsupported.")
    end

    if not repo_url then
        error("Unable to parse the GitHub URL.")
    end

    return "https://github.com/" .. repo_url .. "/commit/"
end

--- Function to open a Git commit in the browser using dynamically fetched GitHub URL
---@param commit_hash string
M.copy_git_commit_url = function(commit_hash)
    if not commit_hash or commit_hash == "" then
        error("Commit hash is required")
    end

    local repository_url = find_remote_url() .. commit_hash

    -- os.execute(string.format("xdg-open %q", repositoryURL)) -- For Unix/Linux systems
    -- os.execute(string.format("sh -c 'open %q' &", repository_url)) -- for Mac
    -- os.execute(string.format("start %q", repositoryURL))  -- For Windows
    vim.fn.setreg("+", repository_url)
    vim.print("Copied " .. repository_url .. " to clipboard")
end

return M
