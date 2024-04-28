## What is Alien?

- Alien is a opinionated, lean, neovim git plugin
    - Opinionated: sensible defaults, with behavior, feature set, and UI that is not necessarily the same as established git tools
    - Lean: each module should do only one thing, and should do it extremely well. Extraneous features and extensibility won’t be added.
    - Neovim: should use the buffers, splits, key maps, etc that make Neovim easy to work with
- Should be able to use a single plugin (Alien) and not need any other git plugins or tools within Neovim.

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
