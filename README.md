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


## Development

### Run tests


Running tests requires either

- [luarocks][luarocks]
- or [busted][busted] and [nlua][nlua]

to be installed[^1].

[^1]: The test suite assumes that `nlua` has been installed
      using luarocks into `~/.luarocks/bin/`.

You can then run:

```bash
luarocks test --local
# or
busted
```

Or if you want to run a single test file:

```bash
luarocks test spec/path_to_file.lua --local
# or
busted spec/path_to_file.lua
```

If you see an error like `module 'busted.runner' not found`:

```bash
eval $(luarocks path --no-bin)
```

[rockspec-format]: https://github.com/luarocks/luarocks/wiki/Rockspec-format
[luarocks]: https://luarocks.org
[luarocks-api-key]: https://luarocks.org/settings/api-keys
[gh-actions-secrets]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[busted]: https://lunarmodules.github.io/busted/
[nlua]: https://github.com/mfussenegger/nlua
[use-this-template]: https://github.com/new?template_name=nvim-lua-plugin-template&template_owner=nvim-lua
