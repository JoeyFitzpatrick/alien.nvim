local create_nodes = require("alien.utils.tree-view.status-tree-view")._create_nodes

describe("create_nodes", function()
    it("should create a node with a single file path", function()
        local node = create_nodes({ " M lua/alien/elements/init.lua" })
        local expected = {
            children = {
                {
                    name = "lua/alien/elements",
                    type = "dir",
                    full_name = "lua/alien/elements",
                    children = {
                        {
                            name = " M init.lua",
                            full_name = "lua/alien/elements/ M init.lua",
                            type = "file",
                            children = {},
                        },
                    },
                },
            },
        }
        assert.are.same(expected, node)
    end)
    it("should create a node with multiple file paths", function()
        local node = create_nodes({ " M lua/alien/elements/init.lua", "M  lua/alien/test.lua" })
        local expected = {
            children = {
                {
                    name = "lua/alien",
                    full_name = "lua/alien",
                    type = "dir",
                    children = {
                        {
                            name = "elements",
                            full_name = "lua/alien/elements",
                            type = "dir",
                            children = {
                                {
                                    name = " M init.lua",
                                    full_name = "lua/alien/elements/ M init.lua",
                                    type = "file",
                                    children = {},
                                },
                            },
                        },
                        {
                            name = "M  test.lua",
                            full_name = "lua/alien/M  test.lua",
                            type = "file",
                            children = {},
                        },
                    },
                },
            },
        }
        assert.are.same(expected, node)
    end)
end)
