set ts=4 sw=4
set autoindent
set expandtab
set history=300
set nu

function Set_color_On()
		syntax on
		map <F1> :call Set_color_Off()<CR>
endfunction
function Set_color_Off()
		syntax off
		map <F1> :call Set_color_On()<CR>
endfunction

map ZZ :xa<CR>
map g 1G
map <F2> :e#<CR>
map <F3> :e$s<CR> " edit scrap file
" map <F4> :w!$s<CR> " make copy in scrap file
" map <F4> :wn<CR> " write next for going through a set of files
map <F4> :,/^$/s/^\( *\)  /\1# /<CR> " comment but respect indent
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

call Set_color_On()
