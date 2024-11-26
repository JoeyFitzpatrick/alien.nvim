local find_author = require("alien.highlight.commit-highlight")._find_author

describe("find_author", function()
    it("should find the author name in a line of log output", function()
        local lines = {
            "c3123ec7 3 weeks ago     dependabot[bot]           chore(deps): bump vite from 5.3.1 to 5.4.10",
            "112374b3 3 weeks ago     semantic-release-bot      chore(release): 2.42.0 [skip ci]",
            "4ab42cdc 3 weeks ago     Jessie Wooten             feat: add practice homepage, layout, and middleware protection (#938)",
        }
        for _, line in ipairs(lines) do
            local name_start, name_end = find_author(line)
            assert.are.equal(21, name_start)
            assert.are_not_equal(nil, name_end)
        end
    end)
end)
