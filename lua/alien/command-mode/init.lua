local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

---@alias DisplayStrategyOpts { dynamic_resize?: boolean } | nil

local M = {}

local GIT_PREFIXES = { "git", "gitk", "gitweb" }
local PORCELAIN_COMMAND_STRATEGY_MAP = {
    add = DISPLAY_STRATEGIES.PRINT,
    blame = DISPLAY_STRATEGIES.BLAME,
    branch = require("alien.command-mode.display-strategies.branch").get_strategy,
    commit = require("alien.command-mode.display-strategies.commit").get_strategy,
    diff = DISPLAY_STRATEGIES.DIFF,
    grep = DISPLAY_STRATEGIES.SHOW,
    help = DISPLAY_STRATEGIES.SHOW,
    log = DISPLAY_STRATEGIES.UI,
    merge = require("alien.command-mode.display-strategies.merge").get_strategy,
    mergetool = DISPLAY_STRATEGIES.MERGETOOL,
    notes = require("alien.command-mode.display-strategies.notes").get_strategy,
    rebase = require("alien.command-mode.display-strategies.rebase").get_strategy,
    show = DISPLAY_STRATEGIES.SHOW,
    stash = require("alien.command-mode.display-strategies.stash").get_strategy,
    status = require("alien.command-mode.display-strategies.status").get_strategy,
}

--- Takes a git command, and returns the git verb.
---@param cmd string
---@return string
M.get_subcommand = function(cmd)
    local first_word = cmd:match("%w+")
    if not first_word or not vim.tbl_contains(GIT_PREFIXES, first_word) then
        error("Error: called parse with a non-git command")
    end
    local second_word = cmd:match("%S+%s+(%S+)")
    if not second_word then
        error("Error: no subcommand passed to git commmand")
    end
    return second_word
end

--- Get the command strategy for a given command.
---@param cmd string
---@return string, DisplayStrategyOpts
M.get_command_strategy = function(cmd)
    local subcommand = M.get_subcommand(cmd)
    local strategy = PORCELAIN_COMMAND_STRATEGY_MAP[subcommand]
    if type(strategy) == "string" then
        return strategy
    end
    if type(strategy) == "function" then
        return strategy(cmd)
    end
    return DISPLAY_STRATEGIES.TERMINAL
end

---@param cmd string
local function print_output(cmd)
    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify(output, vim.log.levels.ERROR)
    else
        vim.notify(output, vim.log.levels.INFO)
    end
    require("alien.elements.register").redraw_elements()
end

local patterns = {
    ["^git status$"] = function()
        return require("alien.actions.commands").status
    end,
    ["^git log %-L"] = function(cmd, input_args)
        if require("alien.command-mode.utils").is_visual_range(input_args) then
            return cmd .. input_args.line1 .. "," .. input_args.line2 .. ":" .. vim.api.nvim_buf_get_name(0)
        end
        return cmd
    end,
}

---@param cmd string
---@param input_args { line1?: integer, line2?: integer, range?: integer }
---@return string
local intercept = function(cmd, input_args)
    cmd = require("alien.command-mode.utils").populate_filename(cmd)
    for pattern, fn in pairs(patterns) do
        if cmd:find(pattern) then
            cmd = fn(cmd, input_args)
            return cmd
        end
    end
    return cmd
end

--- Runs the given git command with a command display strategy.
---@param cmd string
---@param input_args { line1?: integer, line2?: integer, range?: integer }
M.run_command = function(cmd, input_args)
    local strategy, custom_opts = M.get_command_strategy(cmd)
    cmd = intercept(cmd, input_args)
    local output_handler_fn = require("alien.actions.output-handlers").get_output_handler(cmd)
    local output_handler = output_handler_fn and { output_handler = output_handler_fn } or nil
    if strategy == DISPLAY_STRATEGIES.TERMINAL then
        local default_opts = { enter = true, dynamic_resize = true, window = { split = "below" } }
        local opts = vim.tbl_deep_extend("force", default_opts, custom_opts or {})
        require("alien.elements").terminal(cmd, opts)
    elseif strategy == DISPLAY_STRATEGIES.PRINT then
        print_output(cmd)
    elseif strategy == DISPLAY_STRATEGIES.UI then
        require("alien.elements").window(cmd, output_handler)
    elseif strategy == DISPLAY_STRATEGIES.BLAME then
        require("alien.global-actions.blame").blame(cmd)
    elseif strategy == DISPLAY_STRATEGIES.SHOW then
        local show_cmd = cmd .. " | col -b"
        require("alien.elements").window(
            show_cmd,
            { output_handler = require("alien.actions.output-handlers").get_output_handler(show_cmd) }
        )
    end
end

--- Set up Git command with given commands. Note that the command comes from the config, and does not have to be "Git".
function M.create_git_command()
    for _, command in pairs(require("alien.config").config.command_mode_commands) do
        vim.api.nvim_create_user_command(
            command, -- Command name, e.g. "Git", "G"
            function(input_args)
                local git_command = "git " .. input_args.args
                M.run_command(git_command, input_args)
            end,
            {
                nargs = "+", -- Require at least one argument
                complete = function(arglead, cmdline)
                    local completion = require("alien.command-mode.completion").complete_git_command(arglead, cmdline)
                    return vim.tbl_filter(function(val)
                        return vim.startswith(val, arglead)
                    end, completion)
                end,
                range = true,
            }
        )
    end
end

return M
