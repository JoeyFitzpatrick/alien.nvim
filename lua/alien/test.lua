-- Function to trigger git commit
local function git_commit_in_nvim()
  local server_name = vim.v.servername

  vim.cmd("term git -c core.editor='nvim --server " .. server_name .. " --remote' commit")
end

git_commit_in_nvim()
