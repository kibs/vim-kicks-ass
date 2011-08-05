" Manage your VIM configuration with help from everybody
" Maintainer:   Sune Kibsgaard Pedersen <sune@kibs.dk>
" Homepage:     https://github.com/kibs/vim-kicks-ass
" License:      VIM License

if exists("g:loaded_vim_kicks_ass")
    finish
endif
let g:loaded_vim_kicks_ass = 1

" vim_kicks_ass root folder
let s:root = fnamemodify(resolve(expand('<sfile>:p')), ":p:h")

" configuration for #for_real function
let s:plugins = {}
let s:keymaps = {}
let s:colorscheme = ""

" add plugins which should be loaded
function vim_kicks_ass#with_plugins(plugins)
    if type(a:plugins) == type("")
        let plugins = [a:plugins]
    else
        let plugins = a:plugins
    endif

    for plugin in plugins
        let s:plugins[plugin] = plugin
    endfor
endfunction

" remove plugins which should not be loaded
function vim_kicks_ass#without_plugins(plugins)
    if type(a:plugins) == type("")
        let plugins = [a:plugins]
    else
        let plugins = a:plugins
    endif

    for plugin in plugins
        if has_key(s:plugins, plugin)
            call remove(s:plugins, plugin)
        endif
    endfor
endfunction

" add keymaps which should be loaded
function vim_kicks_ass#with_keymaps(keymaps)
    if type(a:keymaps) == type("")
        let keymaps = [a:keymaps]
    else
        let keymaps = a:keymaps
    endif

    for keymap in keymaps
        let s:keymaps[keymap] = keymap
    endfor
endfunction

" remove keymaps which should not be loaded
function vim_kicks_ass#without_keymaps(keymaps)
    if type(a:keymaps) == type("")
        let keymaps = [a:keymaps]
    else
        let keymaps = a:keymaps
    endif

    for keymap in keymaps
        if has_key(s:keymaps, keymap)
            call remove(s:keymaps, keymap)
        endif
    endfor
endfunction

" set the colorscheme which should be loaded and used
function vim_kicks_ass#using_colorscheme(scheme)
    if type(a:scheme) == type("")
        let s:colorscheme = a:scheme
    endif
endfunction

" load plugins and keymaps, sets colorscheme
" does all the actual work
function vim_kicks_ass#for_real()
    let bundles = []
    for plugin in values(s:plugins)
        call add(bundles, "plugins/" . plugin)
    endfor

    if s:colorscheme != ""
        call add(bundles, "colors/" . s:colorscheme)
    endif

    call system(s:root . "/lib/setup.sh " . join(bundles, " "))
    call pathogen#infect()
    " set colorscheme if a colorscheme is selected
    " source all selected keymaps
endfunction
