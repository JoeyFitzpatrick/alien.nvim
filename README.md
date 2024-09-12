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

If you see an error like `pl.path requires LuaFileSystem`, you will need to make sure that your luarocks is using lua version 5.1.
One way to do that is to install lua 5.1, then install luarocks from source instead of via a package manager (e.g. Homebrew).
luarocks should then point to your lua 5.1, which should allow the tests to run. Check out the GitHub action that runs the test in CI for an example of how this should look.

Here's [an example of how to make luarocks use version 5.1](https://github.com/nvim-lua/nvim-lua-plugin-template/issues/17#issuecomment-2283293723). 
<details>
    <summary>
And the raw text in case the link is broken:
    </summary>
Yes, this is the exact same error. So first busted.runner isn't found because you have to set the LUA_PATH and LUA_CPATH. Add this to your .bashrc, .zshrc or wherever.

```eval "$(luarocks path)"```
This will automatically set those variables. Ofc you can just run them, but you will have to do it everytime you want to run luarocks test.

Now rerun the test command, you should get a different error.
The next step is to uninstall lua and luarocks and clean all the lua related files. This is because luarocks really badly handles the case where there are multiple lua versions and may still compile shared objects against the wrong one. (Related issue)

Here are example commands for Debian which is what I use, you have to change them to fit your package manager. Here is a simple command to find related lua files.

# This should list lua related files in /usr/share lib and include
# It removes errors
```find /usr/{share,lib,include} -name "*lua*" 2>/dev/null```
I'd advise against directly piping this into rm, you may have programs who have an embedded lua version, make sure you only delete the ones installed by lua package.
For safety, since you're deleting files as root, I advise you do something like this

```sudo -s # Become root```
```alias rm='rm -i' # Always ask for confirmation```
# Then do your thing
Once it's done, install the following packages (names may vary depending on your distro)
```
lua5.1
luajit
liblua5.1-0
luarocks
```
And now your tests should work fine!

Note: I don't know if manually deleting lua related files is necessary or safe. I'm pretty sure it is, especially the /usr/include file which is the one luarocks shared objects use. Maybe using apt purge to uninstall the packages would have deleted those, I don't know
</details>

## Credits
I took quite a bit of inspiration (read: stole) from the awesome [nvim-unception](https://github.com/samjwill/nvim-unception) plugin by [samjwill](https://github.com/samjwill). This plugin prevents nested terminal buffers from occurring. vim-fugitive has the same feature for commands that open an editor, such as `git commit`, and Alien has it as well, thanks to nvim-unception.

Thanks to [tpope](https://github.com/tpope) for creating and maintaining [vim-fugitive](https://github.com/tpope/vim-fugitive). In my opinion, it is the greatest vim plugin ever created, and it obviously inspired Alien.

Thanks to [jesseduffield](https://github.com/jesseduffield) for the awesome [lazygit](https://github.com/jesseduffield/lazygit), which also inspired Alien, and was my daily driver for quite some time.

## Self-Promotion
If you enjoy using Alien, please give it a star on GitHub!

[rockspec-format]: https://github.com/luarocks/luarocks/wiki/Rockspec-format
[luarocks]: https://luarocks.org
[luarocks-api-key]: https://luarocks.org/settings/api-keys
[gh-actions-secrets]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[busted]: https://lunarmodules.github.io/busted/
[nlua]: https://github.com/mfussenegger/nlua
[use-this-template]: https://github.com/new?template_name=nvim-lua-plugin-template&template_owner=nvim-lua
