local flatten_node = require("alien.utils.tree-view")._flatten_node

describe("flatten_node", function()
    it("should flatten a node with a single file path", function()
        local node =
            require("alien.utils.tree-view.status-tree-view")._create_nodes({ " M lua/alien/elements/init.lua" })
        flatten_node(node)
        local expected = {
            children = {
                {
                    name = "lua/alien/elements",
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
            },
        }
        assert.are.same(expected, node)
    end)
    it("should flatten a node with multiple file paths", function()
        local node = require("alien.utils.tree-view.status-tree-view")._create_nodes({
            " M lua/alien/elements/init.lua",
            " M lua/alien/init.lua",
        })
        flatten_node(node)
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
                            name = " M init.lua",
                            full_name = "lua/alien/ M init.lua",
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
