local M = {}

--- Get the translator for a given object type
---@param object_type AlienObject
M.get_translator = function(object_type)
	local object_translate_map = {
		local_file = require("alien.translators.local-file-translator").translate,
		local_branch = require("alien.translators.local-branch-translator").translate,
		commit = require("alien.translators.commit-translator").translate,
		commit_file = require("alien.translators.commit-file-translator").translate,
		blame = require("alien.translators.blame-translator").translate,
		stash = require("alien.translators.stash-translator").translate,
	}
	return object_translate_map[object_type]
end

return M
