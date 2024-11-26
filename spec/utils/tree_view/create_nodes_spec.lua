local create_nodes = require("alien.utils.tree-view")._create_nodes

describe("create_nodes", function()
    it("should create a node with a single file path", function()
        local node = create_nodes({ " M lua/alien/elements/init.lua" })
        local expected = {
            children = {
                {
                    name = " M lua",
                    type = "dir",
                    children = {
                        {
                            name = "alien",
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
                            },
                        },
                    },
                },
            },
        }
        assert.are.same(expected, node)
    end)
end)
