local M = {}

local active_spinners = {}

--- Add a spinner to a buffer at a given line number.
---@param bufnr integer
---@param line_num integer
M.start_spinner = function(bufnr, line_num)
    local spinner_chars = { "|", "/", "-", "\\" }
    local spinner_index = 1
    local spinner_started = false
    local position = nil
    local timer = vim.loop.new_timer()

    local function update_spinner()
        if not spinner_started then
            local line_length = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1]:len() - 1
            position = { line_num, line_length }
            vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
            vim.api.nvim_buf_set_text(bufnr, position[1], position[2], position[1], position[2] + 1, { "  " })
            local namespace = vim.api.nvim_create_namespace("AlienSpinner")
            vim.api.nvim_buf_add_highlight(bufnr, namespace, "AlienSpinner", line_num, line_length, line_length + 30)
            vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
            spinner_started = true
            active_spinners[bufnr] =
                { timer = timer, line_num = line_num, line_length = line_length, namespace = namespace }
        end

        if not position or not active_spinners[bufnr] then
            return
        end
        vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
        vim.api.nvim_buf_set_text(
            bufnr,
            position[1],
            position[2] + 1,
            position[1],
            position[2] + 2,
            { spinner_chars[spinner_index] }
        )
        vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

        spinner_index = (spinner_index % #spinner_chars) + 1
    end

    timer:start(0, 50, pcall(vim.schedule_wrap(update_spinner)))

    return timer
end

M.stop_spinner = function(bufnr)
    local active_spinner = active_spinners[bufnr]
    local timer = active_spinner.timer
    local line_num = active_spinner.line_num
    local line_length = active_spinner.line_length
    local namespace = active_spinner.namespace
    local position = { line_num, line_length }
    active_spinners[bufnr] = nil
    vim.schedule(function()
        if timer and timer:is_active() then
            timer:stop()
            timer:close()
            vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
            vim.api.nvim_buf_set_text(bufnr, position[1], position[2], position[1], position[2] + 1, { " " })
            vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
            vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
        end
    end)
end

return M
