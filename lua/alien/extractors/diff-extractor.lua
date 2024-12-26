---@class Hunk
---@field hunk_start integer
---@field hunk_end integer
---@field hunk_first_changed_line integer
---@field patch_lines string[]
---@field patch_single_line? string[]
---@field next_hunk_start? integer
---@field previous_hunk_start? integer

local M = {}

---@param line string
---@return boolean
local function is_patch_line(line)
    return line:sub(1, 2) == "@@"
end

---@param patch_line string
---@return string?
local function get_single_line_patch(patch_line, line_num)
    local old_start, old_count, new_start, new_count, content =
        string.match(patch_line, "@@ %-(%d+),(%d+) %+(%d+),(%d+) @@ (.*)")
    old_start, old_count, new_start, new_count =
        tonumber(old_start), tonumber(old_count), tonumber(new_start), tonumber(new_count)

    -- Validate if the line number is within bounds
    if line_num == nil or new_start == nil or new_count == nil then
        return nil
    end
    if line_num < new_start or line_num >= (new_start + new_count) then
        return nil -- line_num is outside the range of the patch change
    end

    -- Calculate the new `old_start` and counts for a single line
    local offset = line_num - new_start
    local single_old_line = old_start + offset
    local single_new_line = new_start + offset

    -- Return the single line patch line
    return string.format("@@ -%d,1 +%d,1 @@ %s", single_old_line, single_new_line, content)
end

--- Returns info on a diff hunk
---@return Hunk | nil
M.extract = function()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local hunk_start, hunk_end, hunk_first_changed_line = nil, nil, nil
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i = line_num, 1, -1 do
        if is_patch_line(lines[i]) then
            hunk_start = i + 1
            break
        end
    end
    if hunk_start == nil then
        return nil
    end

    for i = line_num + 1, #lines, 1 do
        if is_patch_line(lines[i]) then
            hunk_end = i - 1
            break
        end
    end
    if hunk_end == nil then
        hunk_end = #lines
    end

    for i = hunk_start, hunk_end, 1 do
        local first_char = lines[i]:sub(1, 1)
        if first_char == "+" or first_char == "-" then
            hunk_first_changed_line = i
            break
        end
    end
    if hunk_first_changed_line == nil then
        return nil
    end

    local next_hunk_start, previous_hunk_start = nil, nil
    for i = hunk_start - 2, 1, -1 do -- -2 represents the line before the @@ line of the current hunk
        if is_patch_line(lines[i]) then
            previous_hunk_start = i + 1
            break
        end
    end

    local not_in_last_line = lines[hunk_end + 1] and lines[hunk_end + 2]
    if not_in_last_line and is_patch_line(lines[hunk_end + 1]) then
        next_hunk_start = hunk_end + 2
    end

    -- First few lines of diff are like this:
    -- diff --git a/lua/alien/keymaps/diff-keymaps.lua b/lua/alien/keymaps/diff-keymaps.lua
    -- index 3dcb93a..8da090a 100644
    -- --- a/lua/alien/keymaps/diff-keymaps.lua
    -- +++ b/lua/alien/keymaps/diff-keymaps.lua
    -- @@ -9,7 +9,7 @@ M.set_unstaged_diff_keymaps = function(bufnr)

    local patch_lines = { lines[3], lines[4] }

    for i = hunk_start - 1, hunk_end, 1 do
        table.insert(patch_lines, lines[i])
    end

    -- TODO: figure out why this is needed to make applying patches not fail due to corrupt patch errors
    table.insert(patch_lines, "")

    local patch_single_line = nil
    local current_line = lines[line_num]
    if not is_patch_line(current_line) then
        patch_single_line =
            { lines[3], lines[4], get_single_line_patch(lines[hunk_first_changed_line], line_num), current_line, "" }
    end

    return {
        hunk_start = hunk_start,
        hunk_end = hunk_end,
        hunk_first_changed_line = hunk_first_changed_line,
        patch_lines = patch_lines,
        patch_single_line = patch_single_line,
        next_hunk_start = next_hunk_start,
        previous_hunk_start = previous_hunk_start,
    }
end

return M
