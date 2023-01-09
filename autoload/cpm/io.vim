func! s:FillItem(separator, str='', place='left')
  let n = strchars(a:str)
  if a:place == 'left'
    let o = a:str.a:separator[n:]
  elseif a:place == 'right'
    let o = a:separator[n:].a:str
  elseif a:place == 'center'
    let nn = strchars(a:separator) - n
    let r = nn % 2
    let nl = nn/2 - 1
    let nr = nn/2 - 1 + r
    let sepl = a:separator[0:nl]
    let sepr = a:separator[0:nr]
    let o = sepl.a:str.sepr
  endif
  return o
endfunc

func! s:RegisterTitle(list, dict, title)
  let key = s:FillItem(g:cpm_title_separator, a:title, 'center')
  let val = ":echo"

  let a:dict[key] = val
  call add(a:list, key)
endfunc

func! s:RegisterSeparator(list, dict)
  let key = s:FillItem(g:cpm_separator)
  let val = ":echo"

  let a:dict[key] = val
  call add(a:list, key)
endfunc

func! s:Register(list, dict, line)
  let line = a:line
  let key = bmk#item#GetItem(line, 1)
  let val = bmk#item#GetItem(line, 2)

  let key = " ".key." "

  if g:cpm_debug && has_key(a:dict, key)
    echom printf("cpm.vim: duplicated key: %s", key)
  endif

  let a:dict[key] = val
  call add(a:list, key)
endfunc

"------------------------------------------------------
" load
"------------------------------------------------------
func! cpm#io#Load(cmd_file)
  let cmd_file = expand(a:cmd_file)
  if !filereadable(cmd_file)
    return
  endif

  let lines = readfile(cmd_file)
  for line in lines
    if (match(line, '^\[.\+\]') == 0)
      " title
      let title = bmk#item#GetTitle(line)

      let menu = []
      let g:cpm_menu_all[title] = menu
      let str = printf(' [%s] ', title)
      call s:RegisterTitle(menu, g:cpm_cmd_dict, str)
    elseif (match(line, '^\s*---') == 0)
      " separator
      call s:RegisterSeparator(menu, g:cpm_cmd_dict)
    elseif (match(line, '^\s*───') == 0)
      " separator
      call s:RegisterSeparator(menu, g:cpm_cmd_dict)
    elseif (match(line, '^\s*[-+] ') == 0)
      " item
      call s:Register(menu, g:cpm_cmd_dict, line)
    endif
  endfor
endfunc

func! cpm#io#MakeCombinedMenu(cmb_titles)
  let m = []
  let g:cpm_menu_all[a:cmb_titles] = m
  let l = split(a:cmb_titles, '\s*&\s*')
  for i in l
    let m += g:cpm_menu_all[i]
  endfor
endfunc

"------------------------------------------------------
" save
"------------------------------------------------------
func! cpm#io#SaveURL(url)
  let url = expand(a:url)

  if isdirectory(url)
    let file = expand(g:cpm_user_bmk_dir)
  else
    let file = expand(g:cpm_user_bmk_file)
  endif

  let dir = fnamemodify(file, ":p:h")
  call mkdir(dir, "p")

  let key = fnamemodify(url, ':p:s?/$??:t')
  let val = fnamemodify(url, ':p')
  let val = vis#util#VisUnexpand(val)

  let line = printf('-   %s | %s', key, val)
  call writefile([line], file, 'as')
endfunc

func! cpm#io#Save()
  call cpm#io#SaveURL(expand('%'))
endfunc

"------------------------------------------------------
" reload
"------------------------------------------------------
func! cpm#io#Reload()
  " menu_entry: cmd/dir/url
  let g:cpm_cmd_dict = {}

  " title: menu_list
  let g:cpm_menu_all = {}

  for file in g:cpm_files
    call cpm#io#Load(file)
  endfor

  " make combined menu
  for menu_type in keys(g:cpm_titles)
    let l = g:cpm_titles[menu_type]
    for i in l
      if match(i, '&') != -1
        call cpm#io#MakeCombinedMenu(i)
      endif
    endfor
  endfor

  " check wether titles exist in cpm_menu_all
  let loaded_titles = keys(g:cpm_menu_all)
  for menu_type in keys(g:cpm_titles)
    let titles = g:cpm_titles[menu_type]
    let valid_titles = []
    for i in titles
      let r = match(loaded_titles, i)
      if r != -1
        call add(valid_titles, i)
      endif
    endfor
    let g:cpm_titles[menu_type] = valid_titles
  endfor
endfunc

