local is_help_command = require("alien.command-mode")._is_help_command

describe("is help command", function()
    it("returns true if help option found at end of command", function()
        assert.are.equal(true, is_help_command("git log -h"))
        assert.are.equal(true, is_help_command("git log --help"))
    end)
    it("returns true if -h option found in middle of command", function()
        assert.are.equal(true, is_help_command("git log -h --oneline"))
    end)
    it("returns false if --help option found in middle of command", function()
        assert.are.equal(false, is_help_command("git log --help --oneline"))
    end)
    it("returns false if non-help flag that begins with '--h' is in command", function()
        assert.are.equal(false, is_help_command("git reset --hard"))
    end)
    it("returns false if '-h' is in command, but not as a flag", function()
        assert.are.equal(false, is_help_command("git commit -m 'something -h '"))
    end)
end)
