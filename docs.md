Just some notes for when I have proper docs.

## Examples
Using the public extract API (add more examples)
```lua
local commit = require("alien.extractors").extract("commit")
print(commit.hash)
```

Using native vim commands to control UI.
If you want to open something in a non-standard ui (for instance, open `G status` in a split instead of a full window), this is supported natively via command mode:
`split | G status`
`rightbelow vsplit | G branch`
Note that this functionality can be used in both the command line and in keymaps.

## Misc
* Like vim-fugitive, the % character will populate the command with the filename of the current buffer

## Lesser-known git functionality
* '<,'>G log -L do git log -L with line numbers
* G log -L :{function name}:% will do git log -L for function in current file, to see all commits that affected that function
* G log -S {search term} --oneline will do git pickaxe, to see commits that changed occurences of given search term
