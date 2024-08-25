local M = {}

function M.create_git_command()
  for _, command in pairs({ "Git", "G" }) do
    -- Neovim API function to create user command
    vim.api.nvim_create_user_command(
      command, -- Command name
      function(input_args)
        -- Gather the argument provided to your :Git command
        local args = input_args.args

        -- Create the command string (assume 'git' is installed and configured properly in your environment)
        local git_command = "git " .. args

        -- Capture the output of the git command using io.popen
        local handle = io.popen(git_command)
        if handle then
          local result = handle:read("*a")
          handle:close()

          -- Print the output in the command line
          if result and result ~= "" then
            print(result)
          else
            print("No output from the git command or command failed.")
          end
        else
          print("Failed to execute git command.")
        end
      end,
      {
        nargs = "+", -- Require at least one argument
        complete = function(ArgLead, CmdLine, CursorPos)
          -- Optionally, you can implement completions here
          return { "status", "add", "commit", "push", "pull", "clone" } -- Example completions
        end,
      }
    )
  end
end

return M
