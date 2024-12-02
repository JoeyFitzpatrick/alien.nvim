local get_status_data = require("alien.utils.tree-view.status-tree-view").get_status_data

describe("convert a node representing status output to status data", function()
    it("should convert a simple node", function()
        local node = require("alien.utils.tree-view.status-tree-view")._create_nodes({ " M lua/alien/init.lua" })
        local expected = {
            {
                name = "lua/alien",
                display_name = "   lua/alien",
                type = "dir",
                status = "unstaged",
            },
            {
                name = "lua/alien/init.lua",
                display_name = "     M init.lua",
                type = "file",
                status = " M",
            },
        }
        assert.are.same(expected, get_status_data(node))
    end)
    it("should convert a node with multiple file paths", function()
        local node = require("alien.utils.tree-view.status-tree-view")._create_nodes({
            " M lua/alien/test.lua",
            "M  lua/alien/elements/init.lua",
        })
        local expected = {
            {
                name = "lua/alien",
                display_name = "   lua/alien",
                type = "dir",
                status = "modified",
            },
            {
                name = "lua/alien/elements",
                display_name = "       elements",
                type = "dir",
                status = "staged",
            },
            {
                name = "lua/alien/elements/init.lua",
                display_name = "        M  init.lua",
                type = "file",
                status = "M ",
            },
            {
                name = "lua/alien/test.lua",
                display_name = "     M test.lua",
                type = "file",
                status = " M",
            },
        }
        assert.are.same(expected, get_status_data(node))
    end)
end)
