" Manage your VIM configuration with help from everybody
" Many thanks to Tim Pope and his pathogen plugin,
" from where i copied some great functions
" 
" Maintainer:   Sune Kibsgaard Pedersen <sune@kibs.dk>
" Homepage:     https://github.com/kibs/vim-kicks-ass
" License:      VIM License

" make sure we only load once, also set this to 1 in .vimrc to disable plugin
if exists("g:loaded_vim_kicks_ass")
    finish
endif
let g:loaded_vim_kicks_ass = 1

" vim_kicks_ass root folder
let s:root = fnamemodify(resolve(expand('<sfile>:p')), ":p:h")

" -------------------------------------------------------
" public functions
" -------------------------------------------------------

" add plugins
function vim_kicks_ass#with_plugins(plugins)
    call s:add(s:listify(a:plugins), s:root.s:separator()."plugins", "plugin")
endfunction

" remove plugins which should not be loaded
function vim_kicks_ass#without_plugins(plugins)
    call s:remove(s:listify(a:plugins), s:root.s:separator()."plugins")
endfunction

" load presets
function vim_kicks_ass#using_presets(presets)
    let sep = s:separator()
    for preset in s:listify(a:presets)
        let path = s:root.sep."presets".sep.preset.".vim"
        if glob(path) == ""
            call s:msg("preset ".preset." not found")
        else
            execute ":source ".path
        endif
    endfor
endfunction

" set the colorscheme which should be loaded and used
function vim_kicks_ass#using_colorschemes(schemes)
    call s:add(s:listify(a:schemes), s:root.s:separator()."colors", "colorscheme")
endfunction

" -------------------------------------------------------
" private functions
" -------------------------------------------------------

" make sure we always get a list from some data
function s:listify(values)
    if type(a:values) == type("")
        return [a:values]
    else
        return a:values
    endif
endfunction

" tell user something
function s:msg(message)
    echo "[vim-kicks-ass] ".a:message
endfunction

" add dirs to runtimepath
function s:add(dirs, root, type)
    let paths = s:split(&rtp)
    let sep = s:separator()
    for dir in a:dirs
        let path = a:root.sep.dir
        if glob(path.sep."*") == ""
            call s:msg("initializing ".a:type." ".dir)
            call system("cd ".s:root." && git submodule update --init ".path)
        endif
        if index(paths, path) == -1
            let paths = add(paths, path)
        endif
    endfor
    let &rtp = s:join(paths)
endfunction

" remove dirs from runtimepath
function s:remove(dirs, root)
    let paths = s:split(&rtp)
    let sep = s:separator()
    for dir in a:dirs
        let i = index(paths, a:root.sep.dir)
        if i != -1
            call remove(paths, i)
        endif
    endfor
    let &rtp = s:join(paths)
endfunction

" split a path into a list
function s:split(path)
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction " }}}1

" convert a list to a path
function s:join(...)
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
function s:separator()
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction " }}}1
