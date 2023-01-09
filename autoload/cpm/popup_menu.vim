func! s:InMenu(name)
  let l = get(g:cpm_titles, a:name, [])
  if l != []
    " [DEBUG]
    "echom "l: ".string(l)
    return 1
  else
    return 0
  endif
endfunc

func! s:GetValidMenuName(name='default')
  let name = a:name

  if &buftype == 'terminal'
    let name = printf("%s.%s", name, &buftype)
  elseif &diff == 1
    let name = printf("%s.%s", name, 'diff')
  elseif &filetype != ''
    let name = printf("%s.%s", name, &filetype)
  endif

  if s:InMenu(name)
    return name
  endif
  if s:InMenu(a:name)
    return a:name
  endif

  return 'default'
endfunc

func! s:GetMenu(name, nr)
  let title = g:cpm_titles[a:name][a:nr]
  return g:cpm_menu_all[title]
endfunc

func! s:GetNumTitles(name)
  return len(g:cpm_titles[a:name])
endfunc

"------------------------------------------------------
func! s:NextNr()
  let n = s:GetNumTitles(w:cpm_menu_name)
  return (w:cpm_menu_nr + 1) % n
endfunc

func! s:PrevNr()
  let n = s:GetNumTitles(w:cpm_menu_name)
  return w:cpm_menu_nr == 0 ? n - 1 : w:cpm_menu_nr - 1
endfunc

func! s:FixPos(id)
  call popup_move(a:id, #{
  \ pos: 'botleft',
  \ line: 'cursor-1',
  \ col: 'cursor',
  \ })
endfunc

func! s:FindByKey(list_of_str, pattern)
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
" filter
"------------------------------------------------------
func! cpm#popup_menu#filter(id, key)
  let w:edit_type = 0
  if a:key == g:cpm_key || a:key == g:cpm_term_key
    call popup_close(a:id, 0)
    return 1
  elseif a:key == '0'
    call s:FixPos(a:id)
    return 1
  elseif a:key == 'l'
    call popup_close(a:id, 0)
    let nr = s:NextNr()
    let id = cpm#popup_menu#open(w:cpm_menu_name, nr)
    call s:FixPos(id)
    return 1
  elseif a:key == 'h'
    call popup_close(a:id, 0)
    let nr = s:PrevNr()
    let id = cpm#popup_menu#open(w:cpm_menu_name, nr)
    call s:FixPos(id)
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
    let idx = s:FindByKey(w:cpm_menu, pattern)
    if (idx != -1)
      let idx = idx + 1
      call popup_close(a:id, idx)
      return 1
    endif
  endif
  return popup_filter_menu(a:id, a:key)
endfunc

"------------------------------------------------------
" handler
"------------------------------------------------------
" vim 8.1
func! cpm#popup_menu#handler(id, result)
  if a:result == 0
  elseif a:result > 0
    let idx = a:result - 1

    " key in menu
    let key = w:cpm_menu[idx]
    let cmd = g:cpm_cmd_dict[key]
    let cmd = expand(cmd)

    " [DEBUG]
    "echom printf("key = [%s]", key)
    "echom printf("cmd = [%s]", cmd)

    if w:edit_type == 0
      call bmk#Edit(cmd, 0)
    elseif w:edit_type == 1
      call bmk#View(cmd, 0)
    elseif w:edit_type == 2
      call bmk#Open(cmd, 0)
    endif
  endif
endfunc

" nvim
func! cpm#popup_menu#handler_str(str)
  if a:str == ""
    return
  endif

  let key = a:str
  let cmd = g:cpm_cmd_dict[key]
  let cmd = expand(cmd)

  " [DEBUG]
  "echom printf("key = [%s]", key)
  "echom printf("cmd = [%s]", cmd)

  call bmk#Edit(cmd, 0)
endfunc

"------------------------------------------------------
" open
"------------------------------------------------------
func! cpm#popup_menu#open(menu_name='default', menu_nr=0)
  if (!exists('g:cpm_menu_all'))
    call cpm#io#Reload()
  endif
  let w:cpm_menu_name = s:GetValidMenuName(a:menu_name)
  let w:cpm_menu_nr = a:menu_nr
  let w:cpm_menu = s:GetMenu(w:cpm_menu_name, w:cpm_menu_nr)

  let sz = len(g:cpm_titles[w:cpm_menu_name])
  if sz > 1
    let title = printf(" %s %d/%d ", w:cpm_menu_name, w:cpm_menu_nr+1, sz)
  else
    let title = printf(" %s ", w:cpm_menu_name)
  endif

  if exists('*popup_menu')
    " vim 8.1
    let winid = vis#popup_menu#open(title, w:cpm_menu, 'cpm#popup_menu#handler', 'cpm#popup_menu#filter')
  elseif has('nvim') && exists('g:loaded_popup_menu')
    " nvim with the plugin 'Ajnasz/vim-popup-menu'
    let winid = vis#popup_menu#open(title, w:cpm_menu, 'cpm#popup_menu#handler_str', '')
  endif
  call win_execute(winid, 'setl syntax=cpm')
  return winid
endfunc

