local M = {}

local parsed_commands = {}
local cmd_option_pattern = "%-%-[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9%-]*"
local get_subcommand_pattern = function(cmd)
    return "git " .. cmd .. " %[?([%w%-]+)"
end

---@param help_text string
---@param cmd string
---@return string[]
M._parse_options_from_help_text = function(help_text, cmd)
    local options = {}
    for flag in help_text:gmatch(cmd_option_pattern) do
        options[flag] = flag
    end
    for subcommand in help_text:gmatch(get_subcommand_pattern(cmd)) do
        options[subcommand] = subcommand
    end
    return options
end

M.get_command_options = function()
    local cmds = require("alien.command-mode.constants").PORCELAIN_COMMANDS
    for _, cmd in ipairs(cmds) do
        local help_text_obj = vim.system({ "git", cmd, "-h" }):wait()
        local help_text = help_text_obj.stdout
        if not help_text or help_text:len() == 0 then
            help_text = help_text_obj.stderr
        end
        if not help_text then
            error("Could not get help text for command: " .. cmd)
        end
        local parsed_options = M._parse_options_from_help_text(help_text, cmd)
        parsed_commands[cmd] = { options = parsed_options }
    end

    local log_help = require("scripts.constants").log_help
    local parsed_options = M._parse_options_from_help_text(log_help, "log")
    parsed_commands.log = { options = parsed_options }

    local function write_table_to_file(tbl, filename)
        local file = io.open(filename, "w")
        if file then
            local table_string = vim.inspect(tbl)
            file:write("return " .. table_string)
            file:close()
        else
            error("Could not open file " .. filename .. " for writing.")
        end
    end

    write_table_to_file(parsed_commands, "lua/alien/command-mode/constants/command-options.lua")
    print("done")
end

-- M.get_command_options()

return M
