local M = {}

local keymaps_toggle = false
M.toggle_keymap_display = function()
    if keymaps_toggle then
        vim.cmd("q")
        keymaps_toggle = false
        return
    end
    local element = require("alien.elements.register").get_current_element()
    if not element or not element.object_type then
        return
    end
    local element_keymaps = require("alien.config").config.keymaps[element.object_type]
    if not element_keymaps then
        return
    end

    local max_keymap_length = 0
    local keys = {}
    for key, mapping in pairs(element_keymaps) do
        max_keymap_length = math.max(max_keymap_length, #mapping["desc"])
        table.insert(keys, key)
    end
    local parsed_keymaps = {}
    for _, map_keys in ipairs(keys) do
        local padding = ""
        local mapping = element_keymaps[map_keys]
        for _ = 1, max_keymap_length - #mapping["desc"], 1 do
            padding = padding .. " "
        end
        table.insert(parsed_keymaps, string.format("%s:%s %s", mapping["desc"], padding, map_keys))
    end

    table.sort(parsed_keymaps)

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

    local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
    vim.api.nvim_create_autocmd("WinClosed", {
        desc = "Toggle off help float",
        buffer = bufnr,
        callback = function()
            keymaps_toggle = false
        end,
        group = alien_status_group,
    })
end

return M
