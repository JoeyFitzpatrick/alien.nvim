local get_status_data = require("alien.utils.tree-view.status-tree-view").get_status_data
local render_status_data = require("alien.utils.tree-view.status-tree-view").render_status_data

describe("render status output as a file tree", function()
    it("should render a simple file", function()
        local node = require("alien.utils.tree-view.status-tree-view")._create_nodes({ " M lua/alien/init.lua" })
        local data = get_status_data(node)
        local expected = {
            "   lua/alien",
            "     M init.lua",
        }
        assert.are.same(expected, render_status_data(data))
    end)
    it("should convert a node with multiple file paths", function()
        local node = require("alien.utils.tree-view.status-tree-view")._create_nodes({
            " M lua/alien/test.lua",
            "M  lua/alien/elements/init.lua",
        })
        local data = get_status_data(node)
        local expected = {
            "   lua/alien",
            "       elements",
            "        M  init.lua",
            "     M test.lua",
        }
        assert.are.same(expected, render_status_data(data))
    end)
end)
