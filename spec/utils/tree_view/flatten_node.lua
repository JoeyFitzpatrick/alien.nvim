local flatten_node = require("alien.utils.tree-view")._flatten_node

describe("flatten_node", function()
    it("should flatten a node with a single file path", function()
        local node = require("alien.utils.tree-view")._create_nodes({ " M lua/alien/elements/init.lua" })
        flatten_node(node)
        local expected = {
            children = {
                {
                    name = " M lua/alien/elements",
                    type = "dir",
                    children = {
                        {
                            name = "init.lua",
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
        local node = require("alien.utils.tree-view")._create_nodes({
            " M lua/alien/elements/init.lua",
            " M lua/alien/init.lua",
        })
        flatten_node(node)
        local expected = {
            children = {
                {
                    name = " M lua/alien",
                    type = "dir",
                    children = {
                        {
                            name = "elements",
                            type = "dir",
                            children = {
                                {
                                    name = "init.lua",
                                    type = "file",
                                    children = {},
                                },
                            },
                        },
                        {
                            name = "init.lua",
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
