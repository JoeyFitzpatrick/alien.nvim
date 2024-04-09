local M = {}
M.dump = function(output)
	if type(output) == "table" then
		local s = "{ "
		for k, v in pairs(output) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(output)
	end
end
M.table_to_string = function(tbl)
	local s = { "return {" }
	for i = 1, #tbl do
		s[#s + 1] = "{"
		for j = 1, #tbl[i] do
			s[#s + 1] = tbl[i][j]
			s[#s + 1] = ","
		end
		s[#s + 1] = "},"
	end
	s[#s + 1] = "}"
	return s
end
return M
