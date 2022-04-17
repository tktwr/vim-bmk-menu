"------------------------------------------------------
" util
"------------------------------------------------------
func bmk#util#TtGetDirName(filepath)
  return substitute(a:filepath, "/[^/]*$", "", "")
endfunc

"------------------------------------------------------
" buffer
"------------------------------------------------------
func bmk#util#TtClear()
  silent %d _
endfunc

func bmk#util#TtPut0(text)
  silent 0put =a:text
endfunc

func bmk#util#TtPut(text)
  silent put =a:text
endfunc

func bmk#util#TtRemoveBeginSpaces(line)
  return substitute(a:line, '^\s*', '', '')
endfunc

func bmk#util#TtRemoveEndSpaces(line)
  return substitute(a:line, '\s*$', '', '')
endfunc

func bmk#util#TtRemoveBeginEndSpaces(line)
  return bmk#util#TtRemoveBeginSpaces(bmk#util#TtRemoveEndSpaces(a:line))
endfunc

func bmk#util#TtSystem(cmd)
  let out = system(a:cmd)
  return substitute(out, "\<CR>", '', 'g')
endfunc

