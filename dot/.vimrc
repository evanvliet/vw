set ts=4 sw=4
set autoindent
set expandtab
set history=300
set nu
syntax enable
autocmd BufRead,BufNewFile *.dart set filetype=dart
autocmd FileType css setlocal shiftwidth=2 tabstop=2
autocmd FileType dart setlocal shiftwidth=2 tabstop=2
autocmd FileType html setlocal shiftwidth=2 tabstop=2

let paths = split(globpath(&runtimepath, 'colors/*.vim'), "\n")
let s:colors = map(paths, 'fnamemodify(v:val, ":t:r")')
let s:colorno = 15
function Change_colorscheme()
        let s:colorno = s:colorno % len(s:colors)
        execute 'colorscheme '.s:colors[s:colorno]
        redraw
        execute 'colorscheme'
        let s:colorno = s:colorno + 1
endfunction

map ZZ :xa<CR>
map g 1G
" map <F1> " F1 used for help
map <F2> :e#<CR>
map <F3> :e$s<CR> " edit scrap file
" map <F4> :w!$s<CR> " make copy in scrap file
" map <F4> :wn<CR> " write next for going through a set of files
" map <F4> :,/^$/s/^\( *\)  /\1# /<CR> " comment but respect indent
map V :call Change_colorscheme()<CR>
map <F5> 072 bF r<CR>
map <F6> :"mac reserved
map <F7> :map<CR>
map <F8> :set ts=8 SW=4<cr>
map <F9> o:<<:<ESC>jo:<ESC> " make next line a block comment in a shell script
map <F9> dt $p " move following word to end of line
map <F10> :"F10 available<CR>
map <F11> :"mac reserved
map <F12> :"mac reserved
map <ESC>[25~ :"F13 available<CR>
map <ESC>[26~ :"F14 available<CR>
map <ESC>[28~ :"F15 available<CR>
map <ESC>[29~ :"F16 available<CR>
map <ESC>[31~ :"F17 available<CR>
map <ESC>[32~ :"F18 available<CR>
map <ESC>[33~ :map<CR>
