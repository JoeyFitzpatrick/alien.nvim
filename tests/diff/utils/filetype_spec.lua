local get_filetype = require("alien.diff").utils.get_filetype

describe("diff utils filetype", function()
	it("returns the correct filetype for filetypes that work normally", function()
		assert.equals("tsx", get_filetype("file.tsx"))
	end)
	it("returns the correct filetype for filetypes that do not work normally", function()
		assert.equals("typescript", get_filetype("file.ts"))
	end)
end)
