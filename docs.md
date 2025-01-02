Just some notes for when I have proper docs.

## Examples
Using the public extract API (add more examples)
```lua
local commit = require("alien.extractors").extract("commit")
print(commit.hash)
```

## Misc
* Like vim-fugitive, the % character will populate the command with the filename of the current buffer

## Lesser-known git functionality
* G log -S {search term} --oneline will do git pickaxe, to see commits that changed occurences of given search term
