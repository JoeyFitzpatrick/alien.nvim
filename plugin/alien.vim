if exists("g:alien")
    finish
endif
let g:loaded_alien = 1

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 Hello lua require("alien").hello()
