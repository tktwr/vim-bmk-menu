"------------------------------------------------------
" init
"------------------------------------------------------
let g:cpm_plugin_dir = expand('<sfile>:p:h:h')."/"

func cpm#init()
  let g:cpm_debug = 1
  let g:cpm_title_separator = "=============================="
  let g:cpm_separator = "──────────────────────────────"

  if !exists('g:cpm_key')
    let g:cpm_key = "\<Space>"
  endif
  if !exists('g:cpm_term_key')
    let g:cpm_term_key = "\<C-Space>"
  endif
  if !exists('g:cpm_files')
    let g:cpm_files = [
      \ g:cpm_plugin_dir."bmk/cmd.txt",
      \ g:cpm_plugin_dir."bmk/bmk.txt",
      \ ]
  endif
  if !exists('g:cpm_titles')
    let g:cpm_titles = {
      \ 'default'          : ['cmd.buf & cmd.sys', 'links'],
      \ 'default.terminal' : ['cmd.term', 'cmd.git'],
      \ 'default.fern'     : ['bmk.dir'],
      \ }
  endif
  if !exists('g:cpm_user_bmk_dir')
    let g:cpm_user_bmk_dir = '~/.bmk_dir.txt'
  endif
  if !exists('g:cpm_user_bmk_file')
    let g:cpm_user_bmk_file = '~/.bmk_file.txt'
  endif
endfunc

