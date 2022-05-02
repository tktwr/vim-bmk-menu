"------------------------------------------------------
" util
"------------------------------------------------------
func bmk#util#BmkGetDirName(filepath)
  let filepath = fnamemodify(expand(a:filepath), ':p')
  if (isdirectory(filepath))
    return filepath
  else
    return fnamemodify(filepath, ':h')
  endif
endfunc

"------------------------------------------------------
" buffer
"------------------------------------------------------
func bmk#util#BmkClear()
  silent %d _
endfunc

func bmk#util#BmkPut0(text)
  silent 0put =a:text
endfunc

func bmk#util#BmkPut(text)
  silent put =a:text
endfunc

func bmk#util#BmkRemoveBeginSpaces(line)
  return substitute(a:line, '^\s*', '', '')
endfunc

func bmk#util#BmkRemoveEndSpaces(line)
  return substitute(a:line, '\s*$', '', '')
endfunc

func bmk#util#BmkRemoveBeginEndSpaces(line)
  return bmk#util#BmkRemoveBeginSpaces(bmk#util#BmkRemoveEndSpaces(a:line))
endfunc

func bmk#util#BmkSystem(cmd)
  let out = system(a:cmd)
  return substitute(out, "\<CR>", '', 'g')
endfunc

