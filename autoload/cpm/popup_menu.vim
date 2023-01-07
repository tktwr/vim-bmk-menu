"------------------------------------------------------
" popup_menu for vim
"------------------------------------------------------
func cpm#popup_menu#filter(id, key)
  return popup_filter_menu(a:id, a:key)
endfunc

func cpm#popup_menu#callback(id, result)
endfunc

func cpm#popup_menu#open_vim(title, list, callback, filter)
  let title = printf(" %s ", a:title)

  let opt = {
    \ 'title'       : title,
    \ 'callback'    : a:callback,
    \ 'filter'      : a:filter,
    \ 'padding'     : [0,0,0,0],
    \ 'border'      : [1,1,1,1],
    \ 'borderchars' : ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    \ 'pos'         : 'botleft',
    \ 'line'        : 'cursor-1',
    \ 'col'         : 'cursor',
    \ 'moved'       : 'WORD',
    \ }
  return popup_menu(a:list, opt)
endfunc

"------------------------------------------------------
" popup_menu for nvim
"------------------------------------------------------
func cpm#popup_menu#callback_str(str)
endfunc

func cpm#popup_menu#open_nvim(title, list, callback)
  let winid = popup_menu#open(a:list, function(a:callback))
  set signcolumn=auto
  return winid
endfunc

"------------------------------------------------------
" popup_menu
"------------------------------------------------------
func cpm#popup_menu#open(title, list, callback='', filter='')
  if exists('*popup_menu')
    " vim 8.1
    let callback = a:callback == '' ? 'cpm#popup_menu#callback' : a:callback
    let filter = a:filter == '' ? 'cpm#popup_menu#filter' : a:filter
    let winid = cpm#popup_menu#open_vim(a:title, a:list, callback, filter)
  elseif has('nvim') && exists('g:loaded_popup_menu')
    " nvim with the plugin 'Ajnasz/vim-popup-menu'
    let callback = a:callback == '' ? 'cpm#popup_menu#callback_str' : a:callback
    let winid = cpm#popup_menu#open_nvim(a:title, a:list, callback)
  endif
  call win_execute(winid, 'setl syntax=cpm')
  return winid
endfunc

func cpm#popup_menu#has()
  if exists('*popup_menu')
    return 1
  elseif has('nvim') && exists('g:loaded_popup_menu')
    return 1
  endif
  return 0
endfunc

