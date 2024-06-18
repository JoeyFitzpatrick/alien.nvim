## Todos
* Create highlighter for local_file object, should be extensible to other objects
* Create more local_file actions

## What is Alien?

- Alien is a composable git client for Neovim.

## Installation

Here's an example using [Lazy](https://github.com/folke/lazy.nvim):

```lua
{
  "joeyfitzpatrick/alien.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- optional
  },
  config = true
}

```

If you're not using lazy, you'll need to require and setup the plugin like so:

```lua
	require("alien").setup()
```

You will probably also want to set up a keymap to call some of the commands:

```lua
	vim.keymap.set("n", "<leader>s", function()
		require("alien").status()
    end, { desc = "Alien Status" })
```

## Dependencies

### Optional
[Delta](https://github.com/dandavison/delta) - improved git diff output
