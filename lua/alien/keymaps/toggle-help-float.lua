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

    -- Get all buffer local keymaps
    local keymaps = {}
    local leader = vim.g.mapleader
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
        -- We only want keymaps that have a description
        if type(map["desc"]) == "string" and map["desc"]:len() > 0 then
            map["lhs"] = map["lhs"]:gsub(leader, "<leader>")
            table.insert(keymaps, map)
        end
    end
    if #keymaps == 0 then
        return
    end

    vim.print(vim.inspect(vim.api.nvim_buf_get_keymap(0, "n")))

    local max_keymap_length = 0
    for _, mapping in pairs(keymaps) do
        max_keymap_length = math.max(max_keymap_length, #mapping["desc"])
    end

    local parsed_keymaps = {}
    for _, map in ipairs(keymaps) do
        local padding = ""
        for _ = 1, max_keymap_length - #map["desc"], 1 do
            padding = padding .. " "
        end
        table.insert(parsed_keymaps, string.format("%s:%s %s", map["desc"], padding, map["lhs"]))
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

    vim.keymap.set("n", require("alien.config").config.keymaps.global.toggle_keymap_display, function()
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

    local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
    vim.api.nvim_create_autocmd("WinClosed", {
        desc = "Toggle help window switch",
        buffer = bufnr,
        callback = function()
            keymaps_toggle = false
        end,
        group = alien_status_group,
    })
end

return M
