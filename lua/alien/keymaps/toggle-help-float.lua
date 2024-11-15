local M = {}

local keymaps_toggle = false

local function get_buffer_keymaps_with_descs()
    local keymaps = {}
    local leader = vim.g.mapleader
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
        if type(map["desc"]) == "string" and map["desc"]:len() > 0 then
            map["lhs"] = map["lhs"]:gsub(leader, "<leader>")
            table.insert(keymaps, map)
        end
    end
    return keymaps
end

local function get_max_keymap_length(keymaps)
    local max_keymap_length = 0
    for _, mapping in pairs(keymaps) do
        max_keymap_length = math.max(max_keymap_length, #mapping["desc"])
    end
    return max_keymap_length
end

local function get_keymaps_as_sorted_strings(keymaps, max_keymap_length)
    local parsed_keymaps = {}
    for _, map in ipairs(keymaps) do
        local padding = ""
        for _ = 1, max_keymap_length - #map["desc"], 1 do
            padding = padding .. " "
        end
        table.insert(parsed_keymaps, string.format("%s:%s %s", map["desc"], padding, map["lhs"]))
    end
    table.sort(parsed_keymaps)
    return parsed_keymaps
end

---@param input string
local function get_text_after_colon(input)
    local start, ending, str = input:find(":%s*(%S.*)")
    return start, ending, str
end

local function set_help_window_keymaps(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "q", function()
        vim.cmd("q")
    end, opts)

    vim.keymap.set("n", require("alien.config").config.keymaps.global.toggle_keymap_display, function()
        vim.cmd("q")
    end, opts)

    vim.keymap.set("n", "<enter>", function()
        local _, _, keys = get_text_after_colon(vim.api.nvim_get_current_line())
        vim.cmd("q")
        if keys then
            vim.api.nvim_input(keys)
        end
    end, opts)
end

local function highlight_help_window(bufnr)
    for line_num, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        local map_start, _, _ = get_text_after_colon(line)
        if map_start == nil then
            goto continue
        end
        vim.api.nvim_buf_add_highlight(
            bufnr,
            -1,
            require("alien.highlight.constants").highlight_groups.ALIEN_TITLE,
            line_num - 1,
            map_start,
            -1
        )
        ::continue::
    end
end

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

    local keymaps = get_buffer_keymaps_with_descs()
    if #keymaps == 0 then
        return
    end

    local max_keymap_length = get_max_keymap_length(keymaps)

    local parsed_keymaps = get_keymaps_as_sorted_strings(keymaps, max_keymap_length)

    local width = math.floor(vim.o.columns * 0.5)
    local height = math.floor(vim.o.lines * 0.5)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, parsed_keymaps)

    highlight_help_window(bufnr)
    set_help_window_keymaps(bufnr)

    vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
        title = require("alien.objects").get_object_type_desc(element.object_type) .. " Keymaps",
    })
    keymaps_toggle = true

    local alien_help_group = vim.api.nvim_create_augroup("AlienHelp", { clear = true })
    vim.api.nvim_create_autocmd("WinClosed", {
        desc = "Toggle help window switch",
        buffer = bufnr,
        callback = function()
            keymaps_toggle = false
        end,
        group = alien_help_group,
    })
end

return M
