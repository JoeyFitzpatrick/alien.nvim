local M = {}

--- Set state on an element.
--- This state will be a table, which is merged with the element's state.
--- Previous state values are overwritten.
--- Returns true if state was set successfully, and false otherwise.
---@param bufnr integer
---@param state table<string, any>
---@return boolean
M.set_state = function(bufnr, state)
    local set_state_successful = false
    local element = require("alien.elements.register").get_element(bufnr)
    if not element then
        return set_state_successful
    end
    if not element.state then
        element.state = {}
    end
    element.state = vim.tbl_deep_extend("force", element.state, state)
    set_state_successful = true
    return set_state_successful
end

--- Get state for an element.
---@param bufnr integer
---@return table<string, any> | nil
M.get_state = function(bufnr)
    local element = require("alien.elements.register").get_element(bufnr)
    if not element then
        return nil
    end
    return element.state
end

---@param cmd_or_fn string | fun(): string
---@return function | nil
M.get_state_setter = function(cmd_or_fn)
    local cmd
    if type(cmd) == "function" then
        cmd = cmd_or_fn()
    else
        cmd = cmd_or_fn
    end
    local object_type = require("alien.objects").get_object_type(cmd)
    if not object_type then
        return nil
    end
    local ok, state_setter =
        pcall(require, "alien.elements.register.state." .. object_type:gsub("_", "-") .. "-state-setter")
    if not ok then
        return nil
    end
    return state_setter
end

return M
