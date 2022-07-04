"======================================================
" Custom Popup Menu
"======================================================
"------------------------------------------------------
" init
"------------------------------------------------------
let s:cpm_plugin_dir = expand('<sfile>:p:h:h')."/"

func cpm#CpmInit()
  " set defaults
  let s:separator = "------------------------------"
  let s:cpm_key = "\<Space>"
  let s:cpm_term_key = "\<C-Space>"
  let s:cpm_user_bmk_dir = '~/.bmk_dir.txt'
  let s:cpm_user_bmk_file = '~/.bmk_file.txt'
  let s:cpm_files = [
    \ s:cpm_plugin_dir."bmk/cmd.txt",
    \ s:cpm_plugin_dir."bmk/bmk.txt",
    \ ]
  let s:cpm_titles = {
    \ 'default'          : ['cmd.buf & cmd.sys', 'links'],
    \ 'default.terminal' : ['cmd.term', 'cmd.git'],
    \ 'default.fern'     : ['bmk.dir'],
    \ }

  call cpm#CpmSetting()
endfunc

func cpm#CpmSetting()
  "------------------------------------------------------
  " user defined global variables
  "------------------------------------------------------
  if exists("g:cpm_key")
    let s:cpm_key = g:cpm_key
  endif
  if exists("g:cpm_term_key")
    let s:cpm_term_key = g:cpm_term_key
  endif
  if exists("g:cpm_files")
    let s:cpm_files = g:cpm_files
  endif
  if exists("g:cpm_titles")
    let s:cpm_titles = g:cpm_titles
  endif
  if exists("g:cpm_user_bmk_dir")
    let s:cpm_user_bmk_dir = g:cpm_user_bmk_dir
  endif
  if exists("g:cpm_user_bmk_file")
    let s:cpm_user_bmk_file = g:cpm_user_bmk_file
  endif
endfunc

"------------------------------------------------------
" util
"------------------------------------------------------
func! s:CpmFillItem(str, separator, place='left')
  let n = len(a:str)
  if a:place == 'left'
    let o = a:str.a:separator[n:]
  elseif a:place == 'right'
    let o = a:separator[n:].a:str
  elseif a:place == 'center'
    let nn = len(a:separator) - n
    let r = nn % 2
    let nl = nn/2 - 1
    let nr = nn/2 - 1 + r
    let sepl = a:separator[0:nl]
    let sepr = a:separator[0:nr]
    let o = sepl.a:str.sepr
  endif
  return o
endfunc

func! s:CpmFindByKey(list_of_str, pattern)
  let idx = 0
  for s in a:list_of_str
    if (match(s, a:pattern) == 0)
      return idx
    endif
    let idx = idx + 1
  endfor
  return -1
endfunc

"------------------------------------------------------
" load
"------------------------------------------------------
func! s:CpmRegisterSeparator(list, dict, title, place='left')
  let key = s:CpmFillItem(a:title, s:separator, a:place)
  let val = ":echo"

  let a:dict[key] = val
  call add(a:list, key)
endfunc

func! s:CpmRegister(list, dict, line)
  let line = a:line
  let key = bmk#BmkGetItem(line, 1)
  let val = bmk#BmkGetItem(line, 2)

  let key = " ".key." "

  let a:dict[key] = val
  call add(a:list, key)
endfunc

func! s:CpmLoad(cmd_file)
  let cmd_file = expand(a:cmd_file)
  if !filereadable(cmd_file)
    return
  endif

  let lines = readfile(cmd_file)
  for line in lines
    if (match(line, '^\[.\+\]') == 0)
      " title
      let title = bmk#BmkGetTitle(line)

      let menu = []
      let s:cpm_menu_all[title] = menu
      let str = printf(' [%s] ', title)
      call s:CpmRegisterSeparator(menu, s:cpm_cmd_dict, str, 'center')
    elseif (match(line, '^\s*---') == 0)
      " separator
      call s:CpmRegisterSeparator(menu, s:cpm_cmd_dict, '   ')
    elseif (match(line, '^\s*[-+] ') == 0)
      " item
      call s:CpmRegister(menu, s:cpm_cmd_dict, line)
    endif
  endfor
endfunc

func! s:CpmMakeCombinedMenu(cmb_titles)
  let m = []
  let s:cpm_menu_all[a:cmb_titles] = m
  let l = split(a:cmb_titles, '\s*&\s*')
  for i in l
    let m += s:cpm_menu_all[i]
  endfor
endfunc

"------------------------------------------------------
" save
"------------------------------------------------------
func! cpm#CpmSaveURL(url)
  let url = expand(a:url)

  if isdirectory(url)
    let file = expand(s:cpm_user_bmk_dir)
  else
    let file = expand(s:cpm_user_bmk_file)
  endif

  let key = fnamemodify(url, ':p:s?/$??:t')
  let val = fnamemodify(url, ':p')
  let val = vis#util#VisUnexpand(val)

  let line = printf('-   %s | %s', key, val)
  call writefile([line], file, 'as')
endfunc

func! cpm#CpmSave()
  call cpm#CpmSaveURL(expand('%'))
endfunc

"------------------------------------------------------
" popup menu
"------------------------------------------------------
func! s:CpmInMenu(name)
  let l = get(s:cpm_titles, a:name, [])
  if l != []
    " [DEBUG]
    "echom "l: ".string(l)
    return 1
  else
    return 0
  endif
endfunc

func! s:CpmGetValidMenuName(name='default')
  let name = a:name

  if &buftype == 'terminal'
    let name = printf("%s.%s", name, &buftype)
  elseif &diff == 1
    let name = printf("%s.%s", name, 'diff')
  elseif &filetype != ''
    let name = printf("%s.%s", name, &filetype)
  endif

  if s:CpmInMenu(name)
    return name
  endif
  if s:CpmInMenu(a:name)
    return a:name
  endif

  return 'default'
endfunc

func! s:CpmGetMenu(name, nr)
  let title = s:cpm_titles[a:name][a:nr]
  return s:cpm_menu_all[title]
endfunc

func! s:CpmGetNumTitles(name)
  return len(s:cpm_titles[a:name])
endfunc

func! s:CpmNextNr()
  let n = s:CpmGetNumTitles(w:cpm_menu_name)
  return (w:cpm_menu_nr + 1) % n
endfunc

func! s:CpmPrevNr()
  let n = s:CpmGetNumTitles(w:cpm_menu_name)
  return w:cpm_menu_nr == 0 ? n - 1 : w:cpm_menu_nr - 1
endfunc

func! s:CpmFixPos(id)
  call popup_move(a:id, #{
  \ pos: 'botleft',
  \ line: 'cursor-1',
  \ col: 'cursor',
  \ })
endfunc

func! cpm#CpmFilter(id, key)
  let w:edit_type = 0
  if a:key == s:cpm_key || a:key == s:cpm_term_key
    call popup_close(a:id, 0)
    return 1
  elseif a:key == '0'
    call s:CpmFixPos(a:id)
    return 1
  elseif a:key == 'l'
    call popup_close(a:id, 0)
    let nr = s:CpmNextNr()
    let id = cpm#CpmOpen(w:cpm_menu_name, nr)
    call s:CpmFixPos(id)
    return 1
  elseif a:key == 'h'
    call popup_close(a:id, 0)
    let nr = s:CpmPrevNr()
    let id = cpm#CpmOpen(w:cpm_menu_name, nr)
    call s:CpmFixPos(id)
    return 1
  elseif a:key == "\<C-CR>"
    let w:edit_type = 1
    return popup_filter_menu(a:id, "\<CR>")
  elseif a:key == "\<S-CR>"
    let w:edit_type = 2
    return popup_filter_menu(a:id, "\<CR>")
  else
    if a:key == '.'
      let pattern = '^ \. '
    else
      let pattern = '^ '.a:key.' '
    endif
    let idx = s:CpmFindByKey(w:cpm_menu, pattern)
    if (idx != -1)
      let idx = idx + 1
      call popup_close(a:id, idx)
      return 1
    endif
  endif
  return popup_filter_menu(a:id, a:key)
endfunc

"------------------------------------------------------
" vim 8.1
func! cpm#CpmHandler(id, result)
  if a:result == 0
  elseif a:result > 0
    let idx = a:result - 1

    " key in menu
    let key = w:cpm_menu[idx]
    let cmd = s:cpm_cmd_dict[key]
    let cmd = expand(cmd)

    " [DEBUG]
    "echom printf("key = [%s]", key)
    "echom printf("cmd = [%s]", cmd)

    if w:edit_type == 0
      call bmk#BmkEdit(cmd, 0)
    elseif w:edit_type == 1
      call bmk#BmkView(cmd, 0)
    elseif w:edit_type == 2
      call bmk#BmkOpen(cmd, 0)
    endif
  endif
endfunc

" nvim
func! cpm#CpmPopupMenuHandlerStr(str)
  let key = a:str." "
  let cmd = s:cpm_cmd_dict[key]
  let cmd = expand(cmd)

  " [DEBUG]
  "echom printf("key = [%s]", key)
  "echom printf("cmd = [%s]", cmd)

  call bmk#BmkEdit(cmd, 0)
endfunc

"------------------------------------------------------
func! cpm#CpmOpen(menu_name='default', menu_nr=0)
  if (!exists('s:cpm_menu_all'))
    call cpm#CpmReload()
  endif
  let w:cpm_menu_name = s:CpmGetValidMenuName(a:menu_name)
  " [DEBUG]
  "echom "menu: ".w:cpm_menu_name
  let w:cpm_menu_nr = a:menu_nr
  let w:cpm_menu = s:CpmGetMenu(w:cpm_menu_name, w:cpm_menu_nr)

  if exists('*popup_menu')
    let winid = s:CpmPopupMenuImplVim81(w:cpm_menu)
  elseif has('nvim') && exists('g:loaded_popup_menu_plugin')
    let winid = s:CpmPopupMenuImplNvim(w:cpm_menu)
  else
    let winid = s:CpmPopupMenuImplInput(w:cpm_menu)
  endif
  return winid
endfunc

" vim 8.1
func! s:CpmPopupMenuImplVim81(list)
  let winid = popup_menu(a:list, #{
    \ filter: 'cpm#CpmFilter',
    \ callback: 'cpm#CpmHandler',
    \ border: [0,0,0,0],
    \ padding: [0,0,0,0],
    \ pos: 'botleft',
    \ line: 'cursor-1',
    \ col: 'cursor',
    \ moved: 'WORD',
    \ })
  return winid
endfunc

" nvim with the plugin 'kamykn/popup-menu.nvim'
func! s:CpmPopupMenuImplNvim(list)
  let Callback_fn = {selected_str -> cpm#CpmPopupMenuHandlerStr(selected_str)}
  call popup_menu#open(a:list, Callback_fn)
  return 0
endfunc

" old vim / nvim
func! s:CpmPopupMenuImplInput(list)
  let index = inputlist(a:list)
  call cpm#CpmPopupMenuHandler(0, index)
  return 0
endfunc

" print a list
func! s:CpmPopupMenuImplPrint(list)
  for i in a:list
    echo i
  endfor
  return 0
endfunc

"------------------------------------------------------
" reload
"------------------------------------------------------
func! cpm#CpmReload()
  call bmk#BmkSetting()
  call cpm#CpmSetting()

  " menu_entry: cmd/dir/url
  let s:cpm_cmd_dict = {}

  " title: menu_list
  let s:cpm_menu_all = {}

  for file in s:cpm_files
    call s:CpmLoad(file)
  endfor

  " make combined menu
  for menu_type in keys(s:cpm_titles)
    let l = s:cpm_titles[menu_type]
    for i in l
      if match(i, '&') != -1
        call s:CpmMakeCombinedMenu(i)
      endif
    endfor
  endfor

  " check wether titles exist in cpm_menu_all
  let loaded_titles = keys(s:cpm_menu_all)
  for menu_type in keys(s:cpm_titles)
    let titles = s:cpm_titles[menu_type]
    let valid_titles = []
    for i in titles
      let r = match(loaded_titles, i)
      if r != -1
        call add(valid_titles, i)
      endif
    endfor
    let s:cpm_titles[menu_type] = valid_titles
  endfor
endfunc

