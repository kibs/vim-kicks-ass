" Manage your VIM configuration with help from everybody
" Many thanks to Tim Pope and his pathogen plugin,
" from where i copied som great functions
" 
" Maintainer:   Sune Kibsgaard Pedersen <sune@kibs.dk>
" Homepage:     https://github.com/kibs/vim-kicks-ass
" License:      VIM License

if exists("g:loaded_vim_kicks_ass")
    finish
endif
let g:loaded_vim_kicks_ass = 1

" vim_kicks_ass root folder
let s:root = fnamemodify(resolve(expand('<sfile>:p')), ":p:h")

" split a path into a list
function! vim_kicks_ass#split(path) abort " {{{1
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction " }}}1

" convert a list to a path
function! vim_kicks_ass#join(...) abort " {{{1
  if type(a:1) == type(1) && a:1
    let i = 1
    let space = ' '
  else
    let i = 0
    let space = ''
  endif
  let path = ""
  while i < a:0
    if type(a:000[i]) == type([])
      let list = a:000[i]
      let j = 0
      while j < len(list)
        let escaped = substitute(list[j],'[,'.space.']\|\\[\,'.space.']\@=','\\&','g')
        let path .= ',' . escaped
        let j += 1
      endwhile
    else
      let path .= "," . a:000[i]
    endif
    let i += 1
  endwhile
  return substitute(path,'^,','','')
endfunction " }}}1

" \ on Windows unless shellslash is set, / everywhere else.
function! vim_kicks_ass#separator() abort " {{{1
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction " }}}1

" add directory to rtp if not already there
function vim_kicks_ass#add_to_runtimepath(dirs)
    let paths = vim_kicks_ass#split(&rtp)
    for dir in a:dirs
        if index(paths, dir) == -1
            let paths = add(paths, dir)
        endif
    endfor
    let &rtp = vim_kicks_ass#join(paths)
endfunction

" add plugins
function vim_kicks_ass#with_plugins(plugins)
    if type(a:plugins) == type("")
        let plugins = [a:plugins]
    else
        let plugins = a:plugins
    endif
    let sep = vim_kicks_ass#separator()
    let plugins_with_path = []

    for plugin in plugins
        let plugin_path = s:root.sep."plugins".sep.plugin
        if glob(plugin_path.sep."*") == ""
            call system("cd ".s:root." && git submodule update --init ".plugin_path)
        endif
        let plugins_with_path = add(plugins_with_path, plugin_path)
    endfor
    call vim_kicks_ass#add_to_runtimepath(plugins_with_path)
endfunction

" remove plugins which should not be loaded
function vim_kicks_ass#without_plugins(plugins)
    if type(a:plugins) == type("")
        let plugins = [a:plugins]
    else
        let plugins = a:plugins
    endif
    
    let paths = vim_kicks_ass#split(&rtp)
    let sep = vim_kicks_ass#separator()
    for plugin in plugins
        let i = index(paths, s:root.sep."plugins".sep.plugin)
        if i != -1
            call remove(paths, i)
        endif
    endfor
    let &rtp = vim_kicks_ass#join(paths)
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
        let sep = vim_kicks_ass#separator()
        call vim_kicks_ass#add_to_runtimepath([s:root.sep."colors".sep.a:scheme])
    endif
endfunction
