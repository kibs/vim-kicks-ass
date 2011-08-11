" cucumber      : syntax highligting for cucumber features
" endwise       : auto end added when needed
" ruby-debugger : debugging ruby scripts, variables, backtraces, breakpoints
call vim_kicks_ass#with_plugins(["cucumber","endwise","ruby-debugger"])

" in the ruby world we like 2 spaces for indenting
au filetype ruby setlocal tabstop=2
au filetype ruby setlocal shiftwidth=2
au filetype ruby setlocal softtabstop=2
