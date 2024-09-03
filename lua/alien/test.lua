local commit_from_alien = false
local test_group = vim.api.nvim_create_augroup("Alien", { clear = true })
local set_autocmds = function()
  vim.api.nvim_create_autocmd("WinClosed", {
    desc = "Test git stuff",
    callback = function()
      if commit_from_alien then
        vim.fn.system("git commit --file=.git/COMMIT_EDITMSG --cleanup=strip")
        commit_from_alien = false
      end
    end,
    group = test_group,
  })
end

local function git_commit_in_nvim()
  local server_name = vim.v.servername
  local cmd = "git -c core.editor='nvim --server " .. server_name .. " --remote' commit"

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(bufnr, true, { split = "right" })
  vim.api.nvim_buf_call(bufnr, function()
    commit_from_alien = true
    set_autocmds()
    vim.fn.termopen(cmd)
  end)
end

git_commit_in_nvim()
