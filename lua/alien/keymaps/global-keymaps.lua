local keymaps = require("alien.config").config.keymaps.global
local register = require("alien.elements.register")
local global_actions = require("alien.global-actions.global-actions")

local M = {}

local keymaps_toggle = false
local function toggle_keymap_display()
    if keymaps_toggle then
        vim.cmd("q")
        keymaps_toggle = false
        return
    end
    local element = register.get_current_element()
    if not element or not element.object_type then
        return nil
    end
    local element_keymaps = require("alien.config").config.keymaps[element.object_type]
    if not element_keymaps then
        return
    end
    local max_keymap_length = 0
    for _, mapping in pairs(element_keymaps) do
        max_keymap_length = math.max(max_keymap_length, #mapping)
    end
    local parsed_keymaps = {}
    for key, value in pairs(element_keymaps) do
        local padding = ""
        for _ = 1, max_keymap_length - #value, 1 do
            padding = padding .. " "
        end
        table.insert(parsed_keymaps, string.format("%s:%s %s", value, padding, key))
    end

    local width = math.floor(vim.o.columns * 0.5)
    local height = math.floor(vim.o.lines * 0.5)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, parsed_keymaps)

    vim.keymap.set("n", "q", function()
        vim.cmd("q")
    end, { noremap = true, silent = true, buffer = bufnr })

    vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    })
    keymaps_toggle = true
end

M.set_global_keymaps = function()
    vim.keymap.set("n", keymaps.branch_picker, global_actions.git_branches, { noremap = true, silent = true })
    vim.keymap.set("n", keymaps.toggle_keymap_display, toggle_keymap_display, { noremap = true, silent = true })
end

return M
