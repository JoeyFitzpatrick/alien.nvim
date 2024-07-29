local M = {}

--- Get the translator for a given object type
---@param object_type AlienObject
M.get_translator = function(object_type)
	if object_type == "local_file" then
		return require("alien.translators.local-file-translator").translate
	elseif object_type == "local_branch" then
		return require("alien.translators.local-branch-translator").translate
	elseif object_type == "commit" then
		return require("alien.translators.commit-translator").translate
	elseif object_type == "commit_file" then
		return require("alien.translators.commit-file-translator").translate
	end
end

return M
