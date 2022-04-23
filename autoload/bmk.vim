"------------------------------------------------------
" set global variables
"------------------------------------------------------
func bmk#BmkInit()
  " set defaults
  let s:bmk_debug = 0
  let s:bmk_winwidth = 30
  let s:bmk_edit_dir_func = ""

  " set global variables
  if exists("g:bmk_winwidth")
    let s:bmk_winwidth = g:bmk_winwidth
  endif
  if exists("g:bmk_edit_dir_func")
    let s:bmk_edit_dir_func = g:bmk_edit_dir_func
  endif
endfunc

"------------------------------------------------------
" type
"------------------------------------------------------
func bmk#BmkUrlType(url)
  let url = a:url

  if (match(url, 'http\|https') == 0)
    let type = "http"
  elseif (match(url, '\.html$') != -1)
    let type = "html"
  elseif (match(url, '\.pdf$') != -1)
    let type = "pdf"
  elseif (match(url, '^//') == 0)
    let type = "network"
  elseif (match(url, '^\\') == 0)     " difficult to handle this format
    let type = "network"
  elseif (match(url, '^:') == 0)
    let type = "vim_command"
  elseif (isdirectory(url))
    let type = "dir"
  elseif (filereadable(url))
    let type = "file"
  elseif (match(url, '^> ') == 0)
    let type = "term_command"
  else
    let type = "no_match"
  endif

  return type
endfunc

func bmk#BmkGetDirName(val)
  let val = a:val
  let type = bmk#BmkUrlType(val)

  if type == "dir"
    let dir = val
  elseif type == "file"
    let dir = bmk#util#BmkGetDirName(val)
  elseif type == "html"
    let dir = bmk#util#BmkGetDirName(val)
  else
    let dir = ""
  endif

  return dir
endfunc

"------------------------------------------------------
" get item
"------------------------------------------------------
" bmk format
"   [title] str
"   space [-+] shortcut key    | val

" return "title"
func bmk#BmkGetTitle(line)
  let mx = '^\[\(.\+\)\].*'
  let line = a:line
  let line = matchstr(line, mx)
  let item = substitute(line, mx, '\1', '')
  return item
endfunc

" return indexed item
func bmk#BmkGetItem(line, idx)
  let mx = '[-+] \(.\+\)\s*|\s*\(.\+\)'
  let line = a:line
  let line = matchstr(line, mx)
  let item = substitute(line, mx, '\'.a:idx, '')
  let item = bmk#util#BmkRemoveEndSpaces(item)
  return item
endfunc

" return "shortcut key"
func bmk#BmkGetKeyItem()
  let line = getline('.')
  return bmk#BmkGetItem(line, 1)
endfunc

" return "val"
func bmk#BmkGetValueItem()
  let line = getline('.')
  return bmk#BmkGetItem(line, 2)
endfunc

func bmk#BmkGetExpandedValueItem()
  let line = getline('.')
  return expand(bmk#BmkGetItem(line, 2))
endfunc

"------------------------------------------------------
" print item
"------------------------------------------------------
func s:BmkPrintItem()
  if s:bmk_debug
    let key = bmk#BmkGetKeyItem()
    let val = bmk#BmkGetExpandedValueItem()
    let type = bmk#BmkUrlType(val)
    echo "key=[".key."], val=[".val."], type=[".type."]"
  else
    let key = bmk#BmkGetKeyItem()
    if (len(key) > s:bmk_winwidth / 2)
      echo key
    else
      echo ""
    endif
  endif
endfunc

func s:BmkPrevItem()
  normal -
  call s:BmkPrintItem()
endfunc

func s:BmkNextItem()
  normal +
  call s:BmkPrintItem()
endfunc

"------------------------------------------------------
" internal open
"------------------------------------------------------
func bmk#BmkEditDirInTerm(dir)
  if &buftype == 'terminal'
    exec "lcd" a:dir
    let bufnr = winbufnr(0)
    call term_sendkeys(bufnr, "cd ".a:dir."\<CR>")
  endif
endfunc

func bmk#BmkEditDir(dir, winnr)
  let dir = expand(a:dir)
  call vis#window#VisGotoWinnr(a:winnr)

  if &buftype == 'terminal'
    call bmk#BmkEditDirInTerm(dir)
  else
    if s:bmk_edit_dir_func != ""
      exec printf('call %s("%s")', s:bmk_edit_dir_func, dir)
    endif
  endif
endfunc

func bmk#BmkEditFile(file, winnr)
  let file = expand(a:file)
  let winnr = vis#window#VisFindEditor(a:winnr)
  call vis#window#VisGotoWinnr(winnr)

  let dir = bmk#util#BmkGetDirName(file)
  if &buftype == 'terminal'
    call bmk#BmkEditDirInTerm(dir)
  else
    exec "lcd" dir
    exec "edit" file
  endif
endfunc

func bmk#BmkEditPDF(file, winnr)
  let file = expand(a:file)
  let winnr = vis#window#VisFindEditor(a:winnr)
  call vis#window#VisGotoWinnr(winnr)

  let dir = bmk#util#BmkGetDirName(file)
  if &buftype == 'terminal'
    call bmk#BmkEditDirInTerm(dir)
  else
    exec "lcd" dir
    let cmd = printf("pdftotext %s -", file)
    let out = bmk#util#BmkSystem(cmd)
    let cmd = printf("edit %s.txt", file)
    exec cmd
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal buflisted
    setlocal noswapfile
    call bmk#util#BmkPut0(out)
    normal 1G
  endif
endfunc

func bmk#BmkExecVimCommand(cmd, winnr)
  call vis#window#VisGotoWinnr(a:winnr)

  let cmd = expand(a:cmd)
  let cmd = substitute(cmd, '_Plug_', "\<Plug>", '')

  if (cmd[0] == ':')
    exec cmd[1:]
  else
    call feedkeys(cmd)
  endif
endfunc

func bmk#BmkExecTermCommand(cmd, winnr)
  call vis#window#VisGotoWinnr(a:winnr)

  if &buftype != 'terminal'
    return
  endif

  let cmd = expand(a:cmd)
  let cmd = substitute(cmd, '<CR>', "\<CR>", '')
  if (match(cmd, '^> ') == 0)
    let cmd = cmd[2:]
  endif

  let bufnr = winbufnr(0)
  call term_sendkeys(bufnr, cmd)
endfunc

"------------------------------------------------------
" external open
"------------------------------------------------------
func bmk#BmkOpenURL(url)
  let url = expand(a:url)
  exec "silent !chrome.sh" url
  redraw!
endfunc

func bmk#BmkOpenDir(url)
  let url = expand(a:url)
  exec "silent !explorer.sh" url
  redraw!
endfunc

func bmk#BmkOpenFile(url)
  let url = expand(a:url)
  exec "silent !vscode.sh" url
  redraw!
endfunc

"------------------------------------------------------
" action
"------------------------------------------------------
func bmk#BmkOpen(url, winnr)
  let url = expand(a:url)
  let type = bmk#BmkUrlType(url)

  if (type == "http")
    call bmk#BmkOpenURL(url)
  elseif (type == "network")
    call bmk#BmkOpenDir(url)
  elseif (type == "dir")
    call bmk#BmkOpenDir(url)
  elseif (type == "file")
    call bmk#BmkOpenFile(url)
  elseif (type == "html")
    call bmk#BmkOpenFile(url)
  elseif (type == "pdf")
    call bmk#BmkOpenURL(url)
  elseif (type == "vim_command")
    call bmk#BmkExecVimCommand(url, a:winnr)
  elseif (type == "term_command")
    call bmk#BmkExecTermCommand(url, a:winnr)
  else
    echo "bmk#BmkOpen: not supported type: [".type."]"
    return 0
  endif

  return 1
endfunc

func bmk#BmkView(url, winnr)
  let url = expand(a:url)
  let type = bmk#BmkUrlType(url)

  if (type == "http")
    call bmk#BmkOpenURL(url)
  elseif (type == "network")
    call bmk#BmkOpenDir(url)
  elseif (type == "dir")
    call bmk#BmkOpenDir(url)
  elseif (type == "file")
    call bmk#BmkOpenURL(url)
  elseif (type == "html")
    call bmk#BmkOpenURL(url)
  elseif (type == "pdf")
    call bmk#BmkOpenURL(url)
  elseif (type == "vim_command")
    call bmk#BmkExecVimCommand(url, a:winnr)
  elseif (type == "term_command")
    call bmk#BmkExecTermCommand(url, a:winnr)
  else
    echo "bmk#BmkView: not supported type: [".type."]"
    return 0
  endif

  return 1
endfunc

func bmk#BmkEdit(url, winnr)
  let url = expand(a:url)
  let type = bmk#BmkUrlType(url)

  if s:bmk_debug
    echom "bmk#BmkEdit: url=[".url."], type=[".type."]"
  endif

  if (type == "http")
    call bmk#BmkOpenURL(url)
  elseif (type == "network")
    call bmk#BmkOpenDir(url)
  elseif (type == "dir")
    call bmk#BmkEditDir(url, a:winnr)
  elseif (type == "file")
    call bmk#BmkEditFile(url, a:winnr)
  elseif (type == "html")
    call bmk#BmkEditFile(url, a:winnr)
  elseif (type == "pdf")
    call bmk#BmkEditPDF(url, a:winnr)
  elseif (type == "vim_command")
    call bmk#BmkExecVimCommand(url, a:winnr)
  elseif (type == "term_command")
    call bmk#BmkExecTermCommand(url, a:winnr)
  else
    echo "bmk#BmkEdit: not supported type: [".type."]"
    return 0
  endif

  return 1
endfunc

"------------------------------------------------------
" action on bmk item
"------------------------------------------------------
func bmk#BmkOpenItem(winnr)
  let val = bmk#BmkGetExpandedValueItem()
  if val == ""
    return
  endif

  call bmk#BmkOpen(val, a:winnr)
endfunc

func bmk#BmkViewItem(winnr)
  let val = bmk#BmkGetExpandedValueItem()
  if val == ""
    return
  endif

  call bmk#BmkView(val, a:winnr)
endfunc

func bmk#BmkEditItem(winnr)
  let val = bmk#BmkGetExpandedValueItem()
  if val == ""
    return
  endif

  call bmk#BmkEdit(val, a:winnr)
endfunc

func bmk#BmkPreviewItem(winnr)
  let prev_winnr = winnr()
  call bmk#BmkEditItem(a:winnr)
  exec prev_winnr."wincmd w"
endfunc

"------------------------------------------------------
" action on <cfile> or the current buffer
"------------------------------------------------------
func bmk#BmkOpenThis()
  let val = expand("<cfile>")

  let r = bmk#BmkOpen(val, 0)
  if !r
    call bmk#BmkOpenFile('%:p')
  endif
endfunc

func bmk#BmkViewThis()
  let val = expand("<cfile>")

  let r = bmk#BmkView(val, 0)
  if !r
    call bmk#BmkOpenURL('%:p')
  endif
endfunc

"------------------------------------------------------
" map
"------------------------------------------------------
func bmk#BmkMapWin()
  if &filetype != "bmk"
    return
  endif

  if (vis#sidebar#VisInSideBar())
    nnoremap <silent> <buffer> <CR>    :call bmk#BmkEditItem(-2)<CR>
    nnoremap <silent> <buffer> <C-CR>  :call bmk#BmkViewItem(-2)<CR>
    nnoremap <silent> <buffer> <S-CR>  :call bmk#BmkOpenItem(-2)<CR>

    nnoremap <silent> <buffer> l       :call bmk#BmkPreviewItem(-2)<CR>
    nnoremap <silent> <buffer> j       :call <SID>BmkNextItem()<CR>
    nnoremap <silent> <buffer> k       :call <SID>BmkPrevItem()<CR>

    nnoremap <silent> <buffer> 2       :call bmk#BmkEditItem(2)<CR>
    nnoremap <silent> <buffer> 3       :call bmk#BmkEditItem(3)<CR>
    nnoremap <silent> <buffer> 4       :call bmk#BmkEditItem(4)<CR>
    nnoremap <silent> <buffer> 5       :call bmk#BmkEditItem(5)<CR>
    nnoremap <silent> <buffer> 6       :call bmk#BmkEditItem(6)<CR>
    nnoremap <silent> <buffer> 7       :call bmk#BmkEditItem(7)<CR>
    nnoremap <silent> <buffer> 8       :call bmk#BmkEditItem(8)<CR>
    nnoremap <silent> <buffer> 9       :call bmk#BmkEditItem(9)<CR>
  else
    nnoremap <silent> <buffer> <CR>    :call bmk#BmkEditItem(0)<CR>
    nnoremap <silent> <buffer> <C-CR>  :call bmk#BmkViewItem(0)<CR>
    nnoremap <silent> <buffer> <S-CR>  :call bmk#BmkOpenItem(0)<CR>
    if maparg('l') != ""
      nunmap <buffer> l
      nunmap <buffer> k
      nunmap <buffer> j
      nunmap <buffer> 2
      nunmap <buffer> 3
      nunmap <buffer> 4
      nunmap <buffer> 5
      nunmap <buffer> 6
      nunmap <buffer> 7
      nunmap <buffer> 8
      nunmap <buffer> 9
    endif
  endif
endfunc

func bmk#BmkToggleDebug()
  let s:bmk_debug = !s:bmk_debug
endfunc

