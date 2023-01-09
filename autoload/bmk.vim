"------------------------------------------------------
" init
"------------------------------------------------------
let g:bmk_bin_dir = expand('<sfile>:p:h:h')."/bin/"

func bmk#init()
  let g:bmk_debug = 0
  let g:bmk_winwidth = 30

  if !exists('g:bmk_edit_dir_func')
    let g:bmk_edit_dir_func = "VisFern"
  endif
  if !exists('g:bmk_open_url_prog')
    let g:bmk_open_url_prog = g:bmk_bin_dir."default_open.sh"
  endif
  if !exists('g:bmk_open_dir_prog')
    let g:bmk_open_dir_prog = g:bmk_bin_dir."default_open.sh"
  endif
  if !exists('g:bmk_open_file_prog')
    let g:bmk_open_file_prog = g:bmk_bin_dir."default_open.sh"
  endif
endfunc

func bmk#ToggleDebug()
  let g:bmk_debug = !g:bmk_debug
endfunc

"------------------------------------------------------
func bmk#GetDirName(val)
  let val = a:val
  let type = bmk#util#type(val)

  if type == "dir"
    let dir = val
  elseif type == "file"
    let dir = bmk#util#GetDirName(val)
  elseif type == "html"
    let dir = bmk#util#GetDirName(val)
  elseif type == "pdf"
    let dir = bmk#util#GetDirName(val)
  else
    let dir = ""
  endif

  return dir
endfunc

func bmk#EditDirInTerm(dir)
  if &buftype == 'terminal'
    exec "lcd" a:dir
    let bufnr = winbufnr(0)
    call term_sendkeys(bufnr, "cd ".a:dir."\<CR>")
  endif
endfunc

"------------------------------------------------------
" external open
"------------------------------------------------------
func bmk#OpenURL(url)
  let url = bmk#util#expand(a:url)
  let cmd = printf("%s '%s'", g:bmk_open_url_prog, url)
  echom cmd
  call system(cmd)
  redraw!
endfunc

func bmk#OpenDir(url)
  let url = bmk#util#expand(a:url)
  let cmd = printf("%s '%s'", g:bmk_open_dir_prog, url)
  echom cmd
  call system(cmd)
  redraw!
endfunc

func bmk#OpenFile(url)
  let url = bmk#util#expand(a:url)
  let cmd = printf("%s '%s'", g:bmk_open_file_prog, url)
  echom cmd
  call system(cmd)
  redraw!
endfunc

"------------------------------------------------------
" internal open
"------------------------------------------------------
func bmk#EditDir(dir, winnr=0)
  let dir = fnamemodify(resolve(bmk#util#expand(a:dir)), ':p')

  if filereadable(dir)
    let dir = fnamemodify(dir, ':h')
  endif

  if !isdirectory(dir)
    echom printf('not directory: %s', dir)
    return
  endif

  call vis#window#goto(a:winnr)

  if &buftype == 'terminal'
    call bmk#EditDirInTerm(dir)
  else
    if g:bmk_edit_dir_func != ""
      exec printf('call %s("%s")', g:bmk_edit_dir_func, dir)
    endif
  endif
endfunc

func bmk#EditFile(file, winnr=0)
  let file = fnamemodify(resolve(bmk#util#expand(a:file)), ':p')
  let winnr = vis#window#VisFindEditor(a:winnr)
  call vis#window#goto(winnr)

  let dir = bmk#util#GetDirName(file)
  if &buftype == 'terminal'
    call bmk#EditDirInTerm(dir)
  else
    exec "lcd" dir
    exec "edit" file
  endif
endfunc

func bmk#EditPDF(file, winnr=0)
  let file = fnamemodify(resolve(bmk#util#expand(a:file)), ':p')
  let winnr = vis#window#VisFindEditor(a:winnr)
  call vis#window#goto(winnr)

  let dir = bmk#util#GetDirName(file)
  if &buftype == 'terminal'
    call bmk#EditDirInTerm(dir)
  else
    exec "lcd" dir
    let cmd = printf("pdftotext %s -", file)
    let out = bmk#util#system(cmd)
    let cmd = printf("edit %s.txt", file)
    exec cmd
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal buflisted
    setlocal noswapfile
    call bmk#util#put0(out)
    normal 1G
  endif
endfunc

func bmk#ExecVimCommand(cmd, winnr=0)
  call vis#window#goto(a:winnr)

  let cmd = bmk#util#expand(a:cmd)
  let cmd = substitute(cmd, '_Plug_', "\<Plug>", '')

  if (cmd[0] == ':')
    exec cmd[1:]
  else
    call feedkeys(cmd)
  endif
endfunc

func bmk#ExecTermCommand(cmd, winnr=0)
  call vis#window#goto(a:winnr)

  if &buftype != 'terminal'
    return
  endif

  let cmd = bmk#util#expand(a:cmd)
  let cmd = substitute(cmd, '<CR>', "\<CR>", '')
  if (match(cmd, '^> ') == 0)
    let cmd = cmd[2:]
  endif

  let bufnr = winbufnr(0)
  call term_sendkeys(bufnr, cmd)
endfunc

"------------------------------------------------------
" action
"------------------------------------------------------
func bmk#Open(url, winnr=0)
  let url = bmk#util#expand(a:url)
  let type = bmk#util#type(url)

  if (type == "http")
    call bmk#OpenURL(url)
  elseif (type == "network")
    call bmk#OpenDir(url)
  elseif (type == "dir")
    call bmk#OpenDir(url)
  elseif (type == "file")
    call bmk#OpenFile(url)
  elseif (type == "html")
    call bmk#OpenFile(url)
  elseif (type == "pdf")
    call bmk#OpenURL(url)
  elseif (type == "vim_command" || type == "vim_normal")
    call bmk#ExecVimCommand(url, a:winnr)
  elseif (type == "term_command")
    call bmk#ExecTermCommand(url, a:winnr)
  else
    echo "bmk#Open: not supported type: [".type."]"
    return 0
  endif

  return 1
endfunc

func bmk#View(url, winnr=0)
  let url = bmk#util#expand(a:url)
  let type = bmk#util#type(url)

  if (type == "http")
    call bmk#OpenURL(url)
  elseif (type == "network")
    call bmk#OpenDir(url)
  elseif (type == "dir")
    call bmk#OpenDir(url)
  elseif (type == "file")
    call bmk#OpenURL(url)
  elseif (type == "html")
    call bmk#OpenURL(url)
  elseif (type == "pdf")
    call bmk#OpenURL(url)
  elseif (type == "vim_command" || type == "vim_normal")
    call bmk#ExecVimCommand(url, a:winnr)
  elseif (type == "term_command")
    call bmk#ExecTermCommand(url, a:winnr)
  else
    echo "bmk#View: not supported type: [".type."]"
    return 0
  endif

  return 1
endfunc

func bmk#Edit(url, winnr=0)
  let url = bmk#util#expand(a:url)
  let type = bmk#util#type(url)

  if g:bmk_debug
    echom "bmk#Edit: url=[".url."], type=[".type."]"
  endif

  if (type == "http")
    call bmk#OpenURL(url)
  elseif (type == "network")
    call bmk#OpenDir(url)
  elseif (type == "dir")
    call bmk#EditDir(url, a:winnr)
  elseif (type == "file")
    call bmk#EditFile(url, a:winnr)
  elseif (type == "html")
    call bmk#EditFile(url, a:winnr)
  elseif (type == "pdf")
    call bmk#EditPDF(url, a:winnr)
  elseif (type == "vim_command" || type == "vim_normal")
    call bmk#ExecVimCommand(url, a:winnr)
  elseif (type == "term_command")
    call bmk#ExecTermCommand(url, a:winnr)
  else
    echo "bmk#Edit: not supported type: [".type."]"
    return 0
  endif

  return 1
endfunc

"------------------------------------------------------
" action on <cfile> or the current buffer
"------------------------------------------------------
func bmk#OpenThis()
  let val = bmk#util#expand("<cfile>")

  let r = bmk#Open(val, 0)
  if !r
    call bmk#OpenFile('%:p')
  endif
endfunc

func bmk#ViewThis()
  let val = bmk#util#expand("<cfile>")

  let r = bmk#View(val, 0)
  if !r
    call bmk#OpenURL('%:p')
  endif
endfunc

