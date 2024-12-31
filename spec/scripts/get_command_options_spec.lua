local parse_options_from_help_text = require("scripts.get-command-options")._parse_options_from_help_text

describe("get command options, e.g. git hash-object --literally", function()
    it("gets flags for commands", function()
        local hash_object_help_text = [[
usage: git hash-object [-t <type>] [-w] [--path=<file> | --no-filters]
   or: git hash-object [-t <type>] [-w] --stdin-paths [--no-filters]

    -t <type>		  object type
    -w			  write the object into the object database
    --stdin		  read the object from stdin
    --stdin-paths	  read file names from stdin
    --no-filters	  store file as is without filters
    --literally 	  just hash any random garbage to create corrupt objects for debugging Git
    --path <file>	  process file as it were from this path
]]

        local hash_object_options = {
            ["--literally"] = "--literally",
            ["--no-filters"] = "--no-filters",
            ["--path"] = "--path",
            ["--stdin"] = "--stdin",
            ["--stdin-paths"] = "--stdin-paths",
        }

        local result = parse_options_from_help_text(hash_object_help_text, "hash-object")
        assert.are.same(hash_object_options, result)
    end)
    it("gets subcommands for commands, e.g. git stash list, git stash show", function()
        local stash_help_text = [[
usage: git stash list [<log-options>]
   or: git stash show [-u | --include-untracked | --only-untracked] [<diff-options>] [<stash>]
   or: git stash drop [-q | --quiet] [<stash>]
   or: git stash pop [--index] [-q | --quiet] [<stash>]
   or: git stash apply [--index] [-q | --quiet] [<stash>]
   or: git stash branch <branchname> [<stash>]
   or: git stash [push [-p | --patch] [-S | --staged] [-k | --[no-]keep-index] [-q | --quiet]
		 [-u | --include-untracked] [-a | --all] [(-m | --message) <message>]
		 [--pathspec-from-file=<file> [--pathspec-file-nul]
		 [--] [<pathspec>...]
   or: git stash save [-p | --patch] [-S | --staged] [-k | --[no-]keep-index] [-q | --quiet]
		 [-u | --include-untracked] [-a | --all] [<message>]
   or: git stash clear
   or: git stash create [<message>]
   or: git stash store [(-m | --message) <message>] [-q | --quiet] <commit>
]]

        local stash_options = {
            ["--all"] = "--all",
            ["--include-untracked"] = "--include-untracked",
            ["--index"] = "--index",
            ["--message"] = "--message",
            ["--only-untracked"] = "--only-untracked",
            ["--patch"] = "--patch",
            ["--pathspec-file-nul"] = "--pathspec-file-nul",
            ["--pathspec-from-file"] = "--pathspec-from-file",
            ["--quiet"] = "--quiet",
            ["--staged"] = "--staged",
            ["list"] = "list",
            ["show"] = "show",
            ["drop"] = "drop",
            ["pop"] = "pop",
            ["apply"] = "apply",
            ["branch"] = "branch",
            ["push"] = "push",
            ["save"] = "save",
            ["clear"] = "clear",
            ["create"] = "create",
            ["store"] = "store",
        }

        local result = parse_options_from_help_text(stash_help_text, "stash")
        assert.are.same(stash_options, result)
    end)
end)
