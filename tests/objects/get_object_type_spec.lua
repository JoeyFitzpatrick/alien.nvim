local objects = require("alien.objects")
local get_object_type = objects.get_object_type
local OBJECT_TYPES = objects.OBJECT_TYPES
local GIT_VERBS = objects.GIT_VERBS

describe("get_object_type", function()
	it("should return the matching git object for each git verb", function()
		local verb_object_pairs = {
			{ verb = GIT_VERBS.STATUS, object = OBJECT_TYPES.LOCAL_FILE },
			{ verb = GIT_VERBS.LOG, object = OBJECT_TYPES.COMMIT },
			{ verb = GIT_VERBS.DIFF, object = OBJECT_TYPES.DIFF },
			{ verb = GIT_VERBS.BRANCH, object = OBJECT_TYPES.LOCAL_BRANCH },
			{ verb = GIT_VERBS.DIFF_TREE, object = OBJECT_TYPES.COMMIT_FILE },
		}
		for _, pair in pairs(verb_object_pairs) do
			assert.equal(pair.object, get_object_type("git " .. pair.verb))
		end
	end)
	it("should return the matching git object when there are flags", function()
		local verb_object_pairs = {
			{ verb = GIT_VERBS.STATUS, object = OBJECT_TYPES.LOCAL_FILE },
			{ verb = GIT_VERBS.LOG, object = OBJECT_TYPES.COMMIT },
			{ verb = GIT_VERBS.DIFF, object = OBJECT_TYPES.DIFF },
			{ verb = GIT_VERBS.BRANCH, object = OBJECT_TYPES.LOCAL_BRANCH },
			{ verb = GIT_VERBS.DIFF_TREE, object = OBJECT_TYPES.COMMIT_FILE },
		}
		for _, pair in pairs(verb_object_pairs) do
			assert.equal(pair.object, get_object_type("git -f --flag --flag='something' " .. pair.verb .. " --flag -f"))
		end
	end)
	it("should return the matching git object for a diff-tree command", function()
		local cmd = "git diff-tree --no-commit-id --name-only 123abc -r"
		assert.equal(OBJECT_TYPES.COMMIT_FILE, get_object_type(cmd))
	end)
end)
