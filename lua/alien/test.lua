local open_interactive_commit = function(cmd)
  local server_name = vim.v.servername
  local cmd_without_first_word_pattern = "^%S+%s+(.*)"
  cmd = "git -c core.editor='nvim --server "
    .. server_name
    .. " --remote' "
    .. string.match(cmd, cmd_without_first_word_pattern)
  return cmd
end

print(open_interactive_commit("git commit --no-verify"))
