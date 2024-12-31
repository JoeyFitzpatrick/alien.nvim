local get_commit_strategy = require("alien.command-mode.display-strategies.commit").get_strategy
local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

describe("get_commit_strategy", function()
    it("uses terminal mode (i.e. not insert) for commands that should print output", function()
        local display_strategy = get_commit_strategy("git commit -m 'mock message'")
        assert.are.equal(DISPLAY_STRATEGIES.TERMINAL, display_strategy)
    end)
    it("uses terminal insert mode for commands that should use interactive output", function()
        local display_strategy = get_commit_strategy("git commit")
        assert.are.equal(DISPLAY_STRATEGIES.TERMINAL_INSERT, display_strategy)
    end)
end)
