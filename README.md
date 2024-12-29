## What is Alien?

Alien is a Neovim git client. It takes some ideas from [vim-fugitive](https://github.com/tpope/vim-fugitive), [lazygit](https://github.com/jesseduffield/lazygit), and [git](https://git-scm.com/) itself, and introduces some other ideas. The main features are:
- Any valid git command can be called via command-mode, e.g. `:Git commit`, like fugitive
- Autocompletion for those commands, e.g. typing `:Git switch` will cause valid branches to be autocompleted
- Commands that open an editor (such as `:Git commit` and `:Git rebase -i`) do so in the current instance of Neovim, instead of opening a nested editor
- Keymaps for common actions in various git contexts, e.g. `n` to create a new branch from the branch UI, like lazygit
- Rich UIs that always show the up-to-date git status and provide context for available actions
- Easy and straightforward customizability

🚧 NOTE: this plugin is in an alpha state. API changes and bugs are expected. 🚧

https://github.com/user-attachments/assets/dbae252d-2031-4703-8016-9b2cdd60e605



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

You can use any package manager you like, but note that you'll need to require and setup the plugin like so:

```lua
require("alien").setup()
```

After that, using Alien is as simple as calling git commands via the `:Git` command (or `:G`):
- `Git commit`
- `Git log -n 10`
- `Git commit -m "initial commit"`


## Usage
1. To use this plugin, simply call git commands from command mode, using the command(s) specified in your configuration (`G` and `Git` by default). Most commands will simply call the git command in terminal mode, with some improvements:
* The terminal will only take as much space as it needs, resizing as command output streams into the terminal
* The terminal can be remove by pressing "Enter", to make it very convenient to remove the terminal once you're done with the output
* There are no line numbers, for a cleaner look, similar to an actual terminal

There are some advantages to using terminal mode for these commands, as opposed to a regular buffer or printing command output:
* Command output will sometimes be mangled when translated to a buffer or printed, this is avoided with a terminal
* Command output keeps it's coloring
* Existing tools such as `delta` that improve git output can still be leveraged

Note that using the `%` character will expand it to the current buffer's filename, similar to vim-fugitive, e.g. `:Git log --follow %` to see commits that changed the current file.

### Default Configuration
Here is the default configuration for the plugin, as well as what each option does:

```lua
default_config = {
    command_mode_commands = { "Git", "G" }, -- The commands used for the command mode API, e.g. :Git status
    local_file = {
        auto_display_diff = true, -- Toggle autodiff on by default in the status ui
    },
    commit_file = {
        auto_display_diff = true, -- Toggle autodiff on by default in the commit file ui
    },
    keymaps = {
        global = {
            branch_picker = "<leader>B", -- a telescope picker to switch to a git branch
            toggle_keymap_display = "g?", -- the keymap to toggle keymap help for a command's UI
        },
        local_file = {
            stage_or_unstage = "<enter>",    -- unstage a file if it is staged, stage it otherwise
            stage_or_unstage_all = "a",      -- unstage all files if they are all staged, stage all files otherwise
            restore = "d",                   -- restore a single file or reset the working tree
            pull = "p",                      -- run git pull
            push = "<leader>p",              -- run git push
            commit = "c",                    -- run git commit
            navigate_to_file = "o",          -- open file in the editor
            scroll_diff_down = "J",          -- scroll the diff window down
            scroll_diff_up = "K",            -- scroll the diff window up
            toggle_auto_diff = "t",          -- toggle autodiff on or off
            staging_area = "D",              -- enter a staging area, to stage hunks instead of the entire file
            stash = "<leader>s",             -- run git stash
            stash_with_flags = "<leader>S",  -- run git stash, with options
            amend = "<leader>am",            -- amend the last commit with current staged changes
            fold = "z",                      -- toggle folding on a directory
        },
        local_branch = {
            switch = "s",       -- switch to the branch under the cursor
            new_branch = "n",   -- create a new branch off of the branch under the cursor
            delete = "d",       -- delete a branch
            rename = "R",       -- rename a branch
            merge = "m",        -- merge the branch under the cursor into the current branch
            rebase = "r",       -- merge the branch under the cursor into the current branch
            log = "<enter>",    -- enter the log UI for a branch
            pull = "p",         -- run git pull
            push = "<leader>p", -- run git push
        },
        blame = {
            display_files = "<enter>",  -- enter the commit file UI for a commit
            copy_commit_url = "o",      -- copy the commit url to the system clipboard
            commit_info = "i",          -- display the commit message in a floating window
        },
        commit = {
            display_files = "<enter>",  -- enter the commit file UI for a commit
            revert = "rv",              -- revert a given commit
            reset = "rs",               -- reset to a given commit
            copy_commit_url = "o",      -- copy the commit url to the system clipboard
            commit_info = "i",          -- display the commit message in a floating window
        },
        commit_file = {
            scroll_diff_down = "J",             -- scroll the diff window down
            scroll_diff_up = "K",               -- scroll the diff window up
            toggle_auto_diff = "t",             -- toggle autodiff on or off
            open_in_vertical_split = "<C-v>",   -- open a file at the given commit in a vertical split
            open_in_horizontal_split = "<C-h>", -- open a file at the given commit in a horizontal split
            open_in_tab = "<C-t>",              -- open a file at the given commit in a tab
            open_in_window = "<C-w>",           -- open a file at the given commit in the current window
        },
        stash = {
            pop = "p",      -- pop the stash
            apply = "a",    -- apply the stash
            drop = "d",     -- drop the stash
        },
        diff = {
            next_hunk = "i",            -- navigate to the next hunk
            previous_hunk = "p",        -- navigate to the previous hunk
            staging_area = {
                stage_hunk = "<enter>", -- stage/unstage the current hunk
                stage_line = "s",       -- stage/unstage the given line
            },
        },
    },
}
```

### Special Commands

Some commands that are often used, or are normally cumbersome to use, are handled differently than just running the command in terminal mode. This typically means opening a buffer that serves as a UI for the command. Here are the special commands:
* `git status`
* `git branch`
* `git log`
* `git commit`
* `git blame`
* `git status`
* `git stash list`

Note that for any command that brings up a UI:
* You can close the UI by pressing `q`, in addition to the normal methods, such as `:q`
* The jumplist still works like normal `<C-i>` and `<C-o>`
* You can view keymaps by pressing `g?`

### Git Status
Using the `:Git status` command brings up a list of all staged and unstaged changes. By default, autodiff is toggled on, meaning that when your cursor moves to a file, a diff of that file is automatically displayed. This can be toggled off by default from your config, by passing an option to the plugin:

```lua
-- Example for lazy.nvim
{
  "joeyfitzpatrick/alien.nvim",
  config = function()
        require("alien").setup({
            local_file = {
                auto_display_diff = true,
            },
        })
  end
}
```

The [default configuration section](#default-configuration) shows the keymaps for the status UI, under the `local_file` keymaps. Note that these keymaps work on both directories and single files.

If you want to see the normal output of "git status" instead of the UI, you can pass any flags to the command, and it will display the normal output of that command, instead of displaying the UI. Note that `:Git status --long` will display the normal output, that you would see when running `git status` in the terminal

### Git Branch
Git commands that display a list of branches, such as `:Git branch`, `:Git branch --all`, `:Git branch --merged`, and so on, bring up a branch UI, from which keymaps can be used to view commits, rename branches, merge branches, etc. The [default configuration section](#default-configuration) shows every keymap, as does pressing `g?` in the branch UI.

Git branch commands that do not display a list of branches, such as `:Git branch --delete`, run the command in terminal mode, as if it were a non-special command.

### Git Log
Git log commands will typically open a UI. The [default configuration section](#default-configuration) shows every keymap, as does pressing `g?` in the log UI.

When pressing the `log` keymap on a branch from the branch UI, it will display a specially formatted log output, but you can use plain old `:Git log`, or map a more sophisticated log command if you wish.

TODO: add git log -L docs

In large repos (e.g. the Linux kernel repo), this command will take some time, unless you specify that you only want a limited number of commits, e.g. `:Git log -n 100` for the most recent 100 commits. There is some work that would make this much faster, by streaming in the content to the buffer instead of writing it all at once, but this has not been implemented yet.

## UI Management (Tabs, Windows, Buffers)
When Alien opens a UI, this will typically either open a new buffer in the current window, or open a new window in a split. In either case, the window can be closed with the `q` keymap, which will return you to the last non-Alien buffer that was open.

If you want to open something in a non-standard ui, this is supported natively via command mode:
Open `G status` in a left split instead of a full window: `split | G status`
Open `G branch` in a right split instead of a full window `rightbelow vsplit | G branch`
Note that this functionality can be used in both command mode and in keymaps.

## Dependencies

### Optional
[Delta](https://github.com/dandavison/delta) - improved git diff output (used in the demos/examples)


## Development

I welcome contributors of any experience level. If you'd like to contribute, you can start by cloning the repo and running the setup script. This script should handle everything you need to get started making contributions, including setting up git hooks.

```bash
git clone https://github.com/JoeyFitzpatrick/alien.nvim.git
cd alien.nvim
sh scripts/setup-development.sh
```

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
