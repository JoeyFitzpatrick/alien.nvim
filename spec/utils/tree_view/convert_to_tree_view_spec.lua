local get_status_output_tree = require("alien.utils.tree-view").get_status_output_tree

describe("convert status output to tree", function()
    it("should convert a tree with multiple outputs", function()
        local status_output = {
            " M lua/alien/elements/init.lua",
            " D lua/alien/utils.lua",
            "?? lua/alien/utils/init.lua",
            "?? lua/alien/utils/tree-view.lua",
            "?? spec/utils/tree_view_spec.lua",
        }

        local tree_output = {
            "   lua/alien",
            "       elements",
            "         M init.lua",
            "       utils",
            "        ?? init.lua",
            "        ?? tree-view.lua",
            "     D utils.lua",
            "   spec/utils",
            "    ?? tree_view_spec.lua",
        }
        assert.are.same(tree_output, get_status_output_tree(status_output))
    end)
    it("should convert a tree with a single filepath", function()
        local single_file_status_output = { " M lua/alien/elements/init.lua" }
        local single_file_tree_output = {
            "   lua/alien/elements",
            "     M init.lua",
        }
        assert.are.same(single_file_tree_output, get_status_output_tree(single_file_status_output))
    end)
end)
