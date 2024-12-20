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
    it("should create a node with a renamed file path", function()
        local node = create_nodes({
            "R  lua/alien/extractors/stash-extractor.lua -> lua/alien/extractors/stash-extractor-test.lua",
        })
        local expected = {
            children = {
                {
                    name = "lua/alien/extractors",
                    type = "dir",
                    full_name = "lua/alien/extractors",
                    children = {
                        {
                            name = "R  stash-extractor.lua -> stash-extractor-test.lua",
                            full_name = "lua/alien/extractors/R  stash-extractor.lua -> stash-extractor-test.lua",
                            type = "file",
                            children = {},
                        },
                    },
                },
            },
        }
        assert.are.same(expected, node)
    end)
    it("should create nodes with file paths with renamed dirs", function()
        local node = create_nodes({
            "R  spec/utils/tree_view/status-tree-view/create_nodes_spec.lua -> spec/utils/tree_view/status-tree-view-test/create_nodes_spec.lua",
            "R  spec/utils/tree_view/status-tree-view/get_status_data_spec.lua -> spec/utils/tree_view/status-tree-view-test/get_status_data_spec.lua",
            "R  spec/utils/tree_view/status-tree-view/render_status_data_spec.lua -> spec/utils/tree_view/status-tree-view-test/render_status_data_spec.lua",
        })
        local expected = {
            children = {
                {
                    name = "spec/utils/tree_view/status-tree-view-test",
                    type = "dir",
                    full_name = "spec/utils/tree_view/status-tree-view-test",
                    children = {
                        {
                            name = "R  create_nodes_spec.lua -> create_nodes_spec.lua",
                            full_name = "spec/utils/tree_view/status-tree-view-test/R  create_nodes_spec.lua -> create_nodes_spec.lua",
                            type = "file",
                            children = {},
                        },
                        {
                            name = "R  get_status_data_spec.lua -> get_status_data_spec.lua",
                            full_name = "spec/utils/tree_view/status-tree-view-test/R  get_status_data_spec.lua -> get_status_data_spec.lua",
                            type = "file",
                            children = {},
                        },
                        {
                            name = "R  render_status_data_spec.lua -> render_status_data_spec.lua",
                            full_name = "spec/utils/tree_view/status-tree-view-test/R  render_status_data_spec.lua -> render_status_data_spec.lua",
                            type = "file",
                            children = {},
                        },
                    },
                },
            },
        }
        assert.are.same(expected.children[1].children, node.children[1].children)
    end)
end)
