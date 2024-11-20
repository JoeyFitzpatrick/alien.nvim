local extract = require("alien.extractors.diff-extractor").extract

local mock_lines = {
    "diff --git a/lua/alien/config.lua b/lua/alien/config.lua",
    "index 465055b..1c4b9c1 100644",
    "--- a/lua/alien/config.lua",
    "+++ b/lua/alien/config.lua",
    "@@ -23,7 +23,7 @@ M.default_config = {",
    '             toggle_auto_diff = "t",',
    '             scroll_diff_down = "J",',
    '             scroll_diff_up = "K",',
    '-            detailed_diff = "D",',
    '+            staging_area = "D",',
    '             stash = "<leader>s",',
    '             stash_with_flags = "<leader>S",',
    '             amend = "<leader>am",',
    "@@ -55,7 +55,6 @@ M.default_config = {",
    "         commit_file = {",
    '             scroll_diff_down = "J",',
    '             scroll_diff_up = "K",',
    '-            detailed_diff = "D",',
    '             toggle_auto_diff = "t",',
    '             open_in_vertical_split = "<C-v>",',
    '             open_in_horizontal_split = "<C-h>",',
    "@@ -67,6 +66,14 @@ M.default_config = {",
    '             apply = "a",',
    '             drop = "d",',
    "         },",
    "+        diff = {",
    "+            staging_area = {",
    '+                stage_hunk = "<enter>",',
    '+                stage_line = "s",',
    '+                next_hunk = "i",',
    '+                previous_hunk = "p",',
    "+            },",
    "+        },",
    "     },",
    " }",
    " ",
}

local function place_cursor_on_line(line_num)
    vim.api.nvim_win_get_cursor = function()
        return { line_num, 0 }
    end
end

describe("diff extractor", function()
    before_each(function()
        vim.api.nvim_buf_get_lines = function()
            return mock_lines
        end
    end)
    it("should return correct hunk start line when cursor is on a @@ line", function()
        place_cursor_on_line(6)
        assert.are.equal(6, extract().hunk_start)
    end)
    it("should return correct hunk start line when cursor is after a @@ line", function()
        place_cursor_on_line(7)
        assert.are.equal(6, extract().hunk_start)
    end)
    it("should return nil when cursor is above first hunk", function()
        place_cursor_on_line(1)
        assert.are.equal(nil, extract())
    end)
    it("should return correct hunk end line when cursor is on a @@ line", function()
        place_cursor_on_line(6)
        assert.are.equal(13, extract().hunk_end)
    end)
    it("should return correct hunk end line when cursor is after a @@ line", function()
        place_cursor_on_line(7)
        assert.are.equal(13, extract().hunk_end)
    end)
    it("should return correct hunk end line when cursor is after last @@ line", function()
        place_cursor_on_line(30)
        assert.are.equal(36, extract().hunk_end)
    end)
    it("should return correct hunk first changed line when cursor above changed line", function()
        place_cursor_on_line(6)
        assert.are.equal(9, extract().hunk_first_changed_line)
    end)
    it("should return correct hunk first changed line when cursor on changed line", function()
        place_cursor_on_line(9)
        assert.are.equal(9, extract().hunk_first_changed_line)
    end)
    it("should return correct hunk first changed line when cursor after changed line", function()
        place_cursor_on_line(10)
        assert.are.equal(9, extract().hunk_first_changed_line)
    end)
    it("should return correct patch lines when cursor is in first hunk", function()
        place_cursor_on_line(6)
        local expected = {}
        for i = 3, 13, 1 do
            table.insert(expected, mock_lines[i])
        end
        table.insert(expected, "") -- we need to insert an empty line to ensure the patch applies correctly
        assert.are.same(expected, extract().patch_lines)
    end)
    it("should return correct patch lines when cursor is in second hunk", function()
        place_cursor_on_line(15)
        local expected = { mock_lines[3], mock_lines[4] }
        for i = 14, 21, 1 do
            table.insert(expected, mock_lines[i])
        end
        table.insert(expected, "") -- we need to insert an empty line to ensure the patch applies correctly
        assert.are.same(expected, extract().patch_lines)
    end)
end)
