local M = {}

M.git_branches = function(opts)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "git branches",
            finder = finders.new_table({
                -- remove the "remotes/origin/" prefix from remote branches, and remove duplicates
                results = vim.fn.systemlist(
                    "git branch --all --sort=-committerdate | sed 's|remotes/origin/||' | awk '!seen[$0]++'"
                ),
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local branch_name = action_state.get_selected_entry()[1]
                    local result = vim.fn.system("git checkout " .. branch_name)
                    local exit_status = vim.v.shell_error

                    -- Check the exit status to see if there was an error
                    if exit_status ~= 0 then
                        -- Exit status is non-zero, meaning git checkout failed
                        -- Use vim.notify to show an error message
                        vim.notify("Failed to checkout branch " .. branch_name .. ":\n" .. result, vim.log.levels.ERROR)
                    else
                        -- Exit status is zero, meaning git checkout was successful
                        -- Use vim.notify to show a success message
                        vim.notify(
                            "Successfully checked out branch " .. branch_name .. ".\n" .. result,
                            vim.log.levels.INFO
                        )
                    end
                end)
                return true
            end,
        })
        :find()
end

return M
