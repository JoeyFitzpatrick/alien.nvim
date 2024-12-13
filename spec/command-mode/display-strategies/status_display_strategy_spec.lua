local get_status_strategy = require("alien.command-mode.display-strategies.status").get_strategy
local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

describe("get_status_strategy", function()
    it("returns 'terminal' for commands that have options", function()
        local result = get_status_strategy("git status --long")
        assert.are.equal(result, DISPLAY_STRATEGIES.TERMINAL)
    end)
    it("returns 'ui' for commands that have no options", function()
        local result = get_status_strategy("git status")
        assert.are.equal(result, DISPLAY_STRATEGIES.UI)
    end)
end)
