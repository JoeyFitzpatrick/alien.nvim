local remove_quoted_text = require("alien.command-mode.utils").remove_quoted_text

describe("remove quoted text", function()
    it("removes quoted text from a string", function()
        assert.are.equal("git commit -m ", remove_quoted_text("git commit -m 'initial commit'"))
        assert.are.equal("git commit -m ", remove_quoted_text('git commit -m "initial commit"'))
    end)
    it("does not remove unbalanced quoted text from a string", function()
        -- note the missing single quote after "commit"
        assert.are.equal("git commit -m 'initial commit", remove_quoted_text("git commit -m 'initial commit"))
    end)
    it("removes multiple instances of quoted text from a string", function()
        assert.are.equal(
            -- note there is an additional space here, because there's a space after "-m" and before "--some-flag"
            "git commit -m  --some-flag ",
            remove_quoted_text("git commit -m 'initial commit' --some-flag 'remove this'")
        )
    end)
end)
