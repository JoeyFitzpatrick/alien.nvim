local get_diff_stats = require("alien.global-actions.difftool.diff_stats").get_diff_stats

describe("get diff stats", function()
    it("parses diff stats into a readable format", function()
        -- This is the expected output of _get_raw_diff_stats
        require("alien.global-actions.difftool.diff_stats")._get_raw_diff_stats = function()
            local files_with_status = {
                "M       docs.md",
                "M       lua/alien/command-mode/constants/init.lua",
                "M       lua/alien/command-mode/display-strategies/add.lua",
            }
            local files_with_changed_lines = {
                "8       0       docs.md",
                "1       2       lua/alien/command-mode/constants/init.lua",
                "2       2       lua/alien/command-mode/display-strategies/add.lua",
            }
            return { files_with_status = files_with_status, files_with_changed_lines = files_with_changed_lines }
        end

        local expected = {
            "M docs.md 8, 0",
            "M lua/alien/command-mode/constants/init.lua 1, 2",
            "M lua/alien/command-mode/display-strategies/add.lua 2, 2",
        }
        assert.are.same(expected, get_diff_stats("commit1", "commit2"))
    end)
end)
