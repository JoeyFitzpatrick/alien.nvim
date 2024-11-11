local constants = require("alien.nested-buffers.constants")

local M = {}

local response_sock = nil
local quitpre_autocmd_id = nil
local bufunload_autocmd_id = nil
local filepath_to_check = nil
local blocked_terminal_buffer_id = nil
local last_replaced_buffer_id = nil

local function unblock_client_and_reset_state()
    -- Remove the autocmds we made.
    vim.api.nvim_del_autocmd(quitpre_autocmd_id)
    vim.api.nvim_del_autocmd(bufunload_autocmd_id)

    -- Unblock client by killing its editor session.
    vim.fn.rpcnotify(response_sock, "nvim_exec_lua", "vim.cmd('quit')", {})
    vim.fn.chanclose(response_sock)

    -- Reset state-sensitive variables.
    response_sock = nil
    quitpre_autocmd_id = nil
    bufunload_autocmd_id = nil
    filepath_to_check = nil
    blocked_terminal_buffer_id = nil
    last_replaced_buffer_id = nil
end

function _G.alien_handle_bufunload(unloaded_buffer_filepath)
    if unloaded_buffer_filepath == filepath_to_check then
        unblock_client_and_reset_state()
    end
end

function _G.alien_handle_quitpre(quitpre_buffer_filepath)
    if quitpre_buffer_filepath == filepath_to_check then
        -- If this buffer replaced the blocked terminal buffer, we should restore it to the same window.
        if blocked_terminal_buffer_id ~= nil and vim.fn.bufexists(blocked_terminal_buffer_id) == 1 then
            vim.cmd("split") -- Open a new window and switch focus to it.
            vim.cmd("buffer " .. blocked_terminal_buffer_id) -- Set the buffer for that window to the buffer that was replaced.
            vim.cmd("wincmd x") -- Navigate to previous (initial) window, and proceed with quitting.
        end

        unblock_client_and_reset_state()
    end
end

function _G.alien_edit_files(file_args, num_files_in_list)
    -- If there aren't arguments, we just want a new, empty buffer, but if
    -- there are, append them to the host Neovim session's arguments list.
    if num_files_in_list > 0 then
        -- Had some issues when using argedit. Explicitly calling these
        -- separately appears to work though.
        vim.cmd("0argadd " .. file_args)

        last_replaced_buffer_id = vim.fn.bufnr()
        vim.cmd("argument 1")
        vim.cmd("edit")
    else
        last_replaced_buffer_id = vim.fn.bufnr()
        vim.cmd("enew")
    end
end

function _G.alien_notify_when_done_editing(pipe_to_respond_on, filepath)
    filepath_to_check = filepath
    blocked_terminal_buffer_id = last_replaced_buffer_id
    response_sock = vim.fn.sockconnect("pipe", pipe_to_respond_on, { rpc = true })
    quitpre_autocmd_id =
        vim.api.nvim_create_autocmd("QuitPre", { command = "lua alien_handle_quitpre(vim.fn.expand('<afile>:p'))" })

    -- Create an autocmd for BufUnload as a failsafe should QuitPre not get triggered on the target buffer (e.g. if a user runs :bdelete).
    bufunload_autocmd_id =
        vim.api.nvim_create_autocmd("BufUnload", { command = "lua alien_handle_bufunload(vim.fn.expand('<afile>:p'))" })
end

function _G.alien_should_use_nested_nvim()
    return require("alien.elements.register").get_current_element() ~= nil
end

M.new_server_pipe_path = vim.call("serverstart")
vim.call("setenv", constants.alien_pipe_path_host_env_var, M.new_server_pipe_path)

return M
