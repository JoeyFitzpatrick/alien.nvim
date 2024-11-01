local create_action = require("alien.actions").create_action

local function output(str1, str2)
  return { output = { str1, str2 } }
end

describe("create_action", function()
  local called_redraw = false
  local called_get_object_type = false
  before_each(function()
    called_redraw = false
    called_get_object_type = false
    require("alien.elements.register").redraw_elements = function()
      called_redraw = true
    end
    require("alien.objects").get_object_type = function()
      called_get_object_type = true
    end
  end)

  local cmd = "echo hello"
  it("runs a command string", function()
    assert.same(output("hello"), create_action(cmd)())
  end)
  it("runs a command function", function()
    assert.same(
      output("hello"),
      create_action(function()
        return cmd
      end)()
    )
  end)
  it("uses output handler", function()
    assert.same(
      output("hello", "world"),
      create_action(cmd, {
        output_handler = function(lines)
          return { unpack(lines), "world" }
        end,
      })()
    )
  end)
  it("calls redraw when flag is set", function()
    create_action(cmd, { trigger_redraw = true })()
    assert.are.equal(true, called_redraw)
  end)
  it("does not call redraw when flag is not set", function()
    create_action(cmd, {})()
    assert.are.equal(false, called_redraw)
  end)
  it("does not call redraw when flag is set to false", function()
    create_action(cmd, { trigger_redraw = false })()
    assert.are.equal(false, called_redraw)
  end)
  it("gets the object type when it isn't passed in", function()
    create_action(cmd, {})()
    assert.are.equal(true, called_get_object_type)
  end)
  it("uses object type from flags when passed in", function()
    local result = create_action(cmd, { object_type = "local_file" })()
    assert.are.equal(false, called_get_object_type)
    assert.are.equal("local_file", result.object_type)
  end)
end)
