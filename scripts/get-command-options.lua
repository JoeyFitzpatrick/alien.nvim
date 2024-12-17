local parsed_commands = {}

local cmds = require("alien.command-mode.constants").PORCELAIN_COMMANDS
for _, cmd in ipairs(cmds) do
    local help_text_obj = vim.system({ "git", cmd, "-h" }):wait()
    local help_text = help_text_obj.stdout
    if not help_text or help_text:len() == 0 then
        help_text = help_text_obj.stderr
    end
    local cmd_option_pattern = "%-%-[a-zA-Z0-9%-]+"
    local cmd_options = help_text:gmatch(cmd_option_pattern)
    local parsed_options = {}
    for option in cmd_options do
        parsed_options[option] = option
    end
    parsed_commands[cmd] = { options = parsed_options }
end

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
