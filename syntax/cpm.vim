" Vim syntax file
" Language: cpm

"------------------------------------------------------
" syntax
"------------------------------------------------------
syn clear
" syntax is case sensitive
syn case match

syn match    cpmMenuShortCut     '^ . '
syn match    cpmSeparator        '^-\+$'
syn match    cpmSeparator        '^─\+$'
syn match    cpmTitle            '^=\+ .* =\+$' contains=cpmTag
syn match    cpmTag              '\[[^]]*\]' contained
syn match    cpmTagR             '([^)]*)'

"------------------------------------------------------
" highlight
"------------------------------------------------------
hi CpmRed           ctermfg=167 guifg=#fb4934
hi CpmGreen         ctermfg=142 guifg=#b8bb26
hi CpmYellow        ctermfg=214 guifg=#fabd2f
hi CpmBlue          ctermfg=109 guifg=#707fd9
hi CpmPurple        ctermfg=175 guifg=#d3869b
hi CpmAqua          ctermfg=108 guifg=#8ec07c
hi CpmOrange        ctermfg=208 guifg=#fe8019

hi CpmBg2           ctermfg=239 guifg=#504945

"------------------------------------------------------
" highlight link
"------------------------------------------------------
hi link cpmSeparator        CpmBg2
hi link cpmMenuShortCut     CpmRed
hi link cpmTitle            CpmOrange
hi link cpmTag              CpmYellow
hi link cpmTagR             CpmGreen
