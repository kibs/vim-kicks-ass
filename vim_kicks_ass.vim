" Manage your VIM configuration with help from everybody
" Many thanks to Tim Pope and his pathogen plugin,
" from where i copied some great functions
"
" Maintainers:  Sune Kibsgaard Pedersen <sune@kibs.dk>
"               Jefferson Gonzalez <jgmdev@gmail.com>
" Homepage:     https://github.com/kibs/vim-kicks-ass
" License:      VIM License
"
" Thanks:       https://github.com/junegunn/vim-plug
"               which source code was used to impement
"               git repository parsing and cloning.

" make sure we only load once, also set this to 1 in .vimrc to disable plugin
if exists("g:loaded_vim_kicks_ass")
    finish
endif

let g:loaded_vim_kicks_ass = 1

" make sure the git application is on path
if !executable('git')
  echohl ErrorMsg
  echo '[vim-kicks-ass] needs git to function.'
  echohl None
  finish
endif

" vim_kicks_ass root folder and other settings
let s:root = fnamemodify(resolve(expand('<sfile>:p')), ":p:h")
let s:plugins_path = s:root."/plugins"
let s:colors_path = s:root."/colors"
let s:is_win = has('win32')
let s:base_spec = {'branch': 'master', 'frozen': 0}

" -------------------------------------------------------
" public functions
" -------------------------------------------------------

" add plugins
function vim_kicks_ass#with_plugins(plugins)
  let plugins = s:download(s:listify(a:plugins), "plugins")
  call s:add(plugins, s:path(s:plugins_path), "plugin")
endfunction

" remove plugins which should not be loaded
function vim_kicks_ass#without_plugins(plugins)
  call s:remove(s:listify(a:plugins), s:root.s:separator()."plugins")
endfunction

" set the colorscheme which should be loaded and used
function vim_kicks_ass#using_colorschemes(schemes)
  let schemes = s:download(s:listify(a:schemes), "colors")
  call s:add(schemes, s:path(s:colors_path), "colorscheme")
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

" update all submodules
function vim_kicks_ass#update_all()
  call s:msg("checking for module updates")
  echo system(
    \ "cd ".s:root.
    \ " && ".
    \ "git submodule foreach git pull origin master".
    \ " && ".
    \ "git submodule foreach git checkout master"
    \ )
endfunction

" add repo and enable it.
function vim_kicks_ass#with_repo(repo, type, ...)
  let name = ''
  let type = s:trim(a:type)
  if a:0 == 1
    let name = vim_kicks_ass#add_repo(repo, type, a:1)
  else
    let name = vim_kicks_ass#add_repo(repo, type)
  endif
  call s:add(s:listify(name, s:path(s:root.'/'.type), a:type))
endfunction

" clones a repository if doesn't exists.
function vim_kicks_ass#add_repo(repo, type, ...)
  if a:0 > 1
    return s:err('Invalid number of arguments (2..3)')
  endif
  let repo = s:trim(a:repo)
  let rtype = s:trim(a:type)
  let opts = a:0 == 1 ? s:parse_options(a:1) : s:base_spec
  let name = get(opts, 'as', fnamemodify(repo, ':t:s?\.git$??'))
  let spec = extend(s:infer_properties(name, repo, rtype), opts)
  let rpath = rtype.'/'.name
  if empty(glob(spec.dir))
    call s:msg("adding ".name)
    call system("cd ".s:root." && "."git submodule add ".spec.uri." ".rpath)
    call system("cd ".s:root." && "."git submodule update --init ".rpath)
    if spec.branch != "master"
      call system("cd ".spec.dir." && "."git checkout ".spec.branch)
    endif
    if has_key(spec, "do")
      call system("cd ".spec.dir." && ".spec.do)
    endif
  endif
  return name
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

" downloads only plugins with a / separator.
function s:download(repos, type)
  let repos = []
  for repo in a:repos
    if repo =~ '/'
      call add(repos, vim_kicks_ass#add_repo(repo, s:trim(a:type)))
    else
      call add(repos, repo)
    endif
  endfor
  return repos
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
      let paths = insert(paths, path)
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

function s:parse_options(arg)
  let opts = copy(s:base_spec)
  let type = type(a:arg)
  if type == type('')
    let opts.tag = a:arg
  elseif type == type({})
    call extend(opts, a:arg)
    if has_key(opts, 'dir')
      let opts.dir = s:dirpath(expand(opts.dir))
    endif
  else
    throw 'Invalid argument type (expected: string of dictionary)'
  endif
  return opts
endfunction

function s:infer_properties(name, repo, type)
  let repo = a:repo
  if s:is_local_plug(repo)
    return {'dir': s:dirpath(expand(repo))}
  else
    if repo =~ ':'
      let uri = repo
    else
      if repo !~ '/'
        throw printf('Invalid argument: %s (implicit `vim-scripts` expansion is deprecated)', repo)
      endif
      let fmt = 'https://git::@github.com/%s.git'
      let uri = printf(fmt, repo)
    endif
    let type_dir = s:path(s:root.'/'.s:trim(a:type))
    if !isdirectory(type_dir)
      call mkdir(type_dir, "p")
    endif
    return {'dir': s:dirpath(type_dir.'/'.a:name), 'uri': uri}
  endif
endfunction

if s:is_win
  function! s:rtp(spec)
    return s:path(a:spec.dir . get(a:spec, 'rtp', ''))
  endfunction

  function! s:path(path)
    return s:trim(substitute(a:path, '/', '\', 'g'))
  endfunction

  function! s:dirpath(path)
    return s:path(a:path) . '\'
  endfunction

  function! s:is_local_plug(repo)
    return a:repo =~? '^[a-z]:\|^[%~]'
  endfunction

  " Copied from fzf
  function! s:wrap_cmds(cmds)
    return map(['@echo off', 'for /f "tokens=4" %%a in (''chcp'') do set origchcp=%%a', 'chcp 65001 > nul'] +
      \ (type(a:cmds) == type([]) ? a:cmds : [a:cmds]) +
      \ ['chcp %origchcp% > nul'], 'v:val."\r"')
  endfunction

  function! s:batchfile(cmd)
    let batchfile = tempname().'.bat'
    call writefile(s:wrap_cmds(a:cmd), batchfile)
    let cmd = plug#shellescape(batchfile, {'shell': &shell, 'script': 1})
    if &shell =~# 'powershell\.exe$'
      let cmd = '& ' . cmd
    endif
    return [batchfile, cmd]
  endfunction
else
  function! s:rtp(spec)
    return s:dirpath(a:spec.dir . get(a:spec, 'rtp', ''))
  endfunction

  function! s:path(path)
    return s:trim(a:path)
  endfunction

  function! s:dirpath(path)
    return substitute(a:path, '[/\\]*$', '/', '')
  endfunction

  function! s:is_local_plug(repo)
    return a:repo[0] =~ '[/$~]'
  endfunction
endif

" \ on Windows unless shellslash is set, / everywhere else.
function s:separator()
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction " }}}1

function s:trim(str)
  return substitute(a:str, '[\/]\+$', '', '')
endfunction

function s:err(msg)
  echohl ErrorMsg
  echom '[vim-kicks-ass] '.a:msg
  echohl None
endfunction
