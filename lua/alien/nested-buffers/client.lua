local utils = require("alien.nested-buffers.utils")
local constants = require("alien.nested-buffers.constants")

-- We don't want to overwrite :h shada
vim.o.sdf = "NONE"

-- We don't want to start. Send the args to the server instance instead.
local args = vim.call("argv")

local arg_str = ""
for _, iter in pairs(args) do
  local absolute_filepath = utils.get_absolute_filepath(iter)
  if string.len(arg_str) == 0 then
    arg_str = utils.escape_special_chars(absolute_filepath)
  else
    arg_str = arg_str .. " " .. utils.escape_special_chars(absolute_filepath)
  end
end

-- Send messages to host on existing pipe.
local sock = vim.fn.sockconnect("pipe", os.getenv(constants.alien_pipe_path_host_env_var), { rpc = true })

local should_use_nested_nvim_call = "return alien_should_use_nested_nvim()" -- note that using 'return' allows for getting the returned value of the fn
local should_use_nested_nvim = vim.fn.rpcrequest(sock, "nvim_exec_lua", should_use_nested_nvim_call, {})
if should_use_nested_nvim == vim.NIL or not should_use_nested_nvim then
  return
end

local edit_files_call = "alien_edit_files(" .. '"' .. arg_str .. '", ' .. #args .. ")"
vim.fn.rpcrequest(sock, "nvim_exec_lua", edit_files_call, {})

-- Start up a pipe so that the client can listen for a response from the host session.
local nested_pipe_path = vim.call("serverstart")

-- Send the pipe path and edited filepath to the host so that it knows what file to look for and who to respond to.
local notify_when_done_call = "alien_notify_when_done_editing("
  .. vim.inspect(nested_pipe_path)
  .. ","
  .. vim.inspect(arg_str)
  .. ")"
vim.fn.rpcnotify(sock, "nvim_exec_lua", notify_when_done_call, {})

-- Sleep forever. The host session will kill this when it's done editing.
while true do
  vim.cmd("sleep 10")
end
