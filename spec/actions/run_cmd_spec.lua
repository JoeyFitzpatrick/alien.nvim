local run_cmd = require("alien.actions").run_cmd

describe("run_cmd", function()
  local mock_vim = {
    fn = {
      systemlist = function(_)
        return { "mock_output" }
      end,
    },
    v = {
      shell_error = 0,
    },
    print = function(_) end,
    notify = function(_) end,
    inspect = function(_)
      return "error_callbacks"
    end,
    log = {
      levels = { ERROR = "error" },
    },
  }

  before_each(function()
    _G.vim = mock_vim
  end)

  it("returns an empty array if no command is given", function()
    assert.are.same({}, run_cmd(""))
  end)

  it("returns the error message if command fails without callbacks", function()
    vim.fn.systemlist = function(_)
      return { "error_output" }
    end
    vim.v.shell_error = 1
    assert.are.same({ "error_output" }, run_cmd("some_failing_command"))
  end)

  it("calls error callback if command fails with error callbacks", function()
    local callback_called = false
    local error_callbacks = {
      [1] = function(_)
        callback_called = true
      end,
    }

    vim.fn.systemlist = function(_)
      return { "error_output" }
    end
    vim.v.shell_error = 1
    run_cmd("some_failing_command", error_callbacks)

    assert.is_true(callback_called)
  end)

  it("returns expected output when command doesn't fail", function()
    vim.fn.systemlist = function(_)
      return { "success_output" }
    end
    vim.v.shell_error = 0
    assert.are.same({ "success_output" }, run_cmd("some_command"))
  end)

  it("calls notify when there is an error and no callback", function()
    local notify_called = false
    vim.notify = function(message)
      notify_called = true
      assert.are.equals("error_output", message)
    end

    vim.fn.systemlist = function(_)
      return { "error_output" }
    end
    vim.v.shell_error = 1
    run_cmd("some_failing_command")

    assert.is_true(notify_called)
  end)
end)
