Just some notes for when I have proper docs.

## Misc
* Like vim-fugitive, the % character will populate the command with the filename of the current buffer

## Lesser-known git functionality
* '<,'>G log -L do git log -L with line numbers
* G log -L :{function name}:% will do git log -L for function in current file, to see all commits that affected that function
* G log -S {search term} --oneline will do git pickaxe, to see commits that changed occurences of given search term
