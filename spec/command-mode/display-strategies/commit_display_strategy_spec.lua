local get_commit_strategy = require("alien.command-mode.display-strategies.commit").get_strategy
local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

describe("get_commit_strategy", function()
    it("uses dynamic resize (i.e. the default) for commands that should print output", function()
        local display_strategy, opts = get_commit_strategy("git commit -m 'mock message'")
        assert.are.equal(DISPLAY_STRATEGIES.TERMINAL, display_strategy)
        assert.are.equal(nil, opts)
    end)
    it("uses static size for commands that should use interactive output", function()
        local display_strategy, opts = get_commit_strategy("git commit")
        if not opts then
            error("opts should be defined here")
        end
        assert.are.equal(DISPLAY_STRATEGIES.TERMINAL, display_strategy)
        assert.are.equal(false, opts.dynamic_resize)
    end)
end)
