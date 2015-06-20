" php-doc : helpers for creating phpdoc
call vim_kicks_ass#with_plugins(["php-doc","php-fix-html-indent"])

" add PhpDoc command and binding
com! -nargs=0 -bang PhpDoc call PhpDoc()
nnoremap <Leader>pd :PhpDoc<CR>

" php-complete : autocompletion support
call vim_kicks_ass#with_plugins(["php-complete"])

" enable code completion support
set omnifunc=syntaxcomplete#Complete

" php-cs-fixer : format source code using PHP Coding Standards
call vim_kicks_ass#with_plugins(["php-cs-fixer"])

" php-namespace : insert needed namespaces at heading of file
call vim_kicks_ass#with_plugins(["php-namespace"])
