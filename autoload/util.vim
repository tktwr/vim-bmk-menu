"------------------------------------------------------
" util
"------------------------------------------------------
func util#TtGetDirName(filepath)
  return substitute(a:filepath, "/[^/]*$", "", "")
endfunc

"------------------------------------------------------
" buffer
"------------------------------------------------------
func util#TtClear()
  silent %d _
endfunc

func util#TtPut0(text)
  silent 0put =a:text
endfunc

func util#TtPut(text)
  silent put =a:text
endfunc

func util#TtRemoveBeginSpaces(line)
  return substitute(a:line, '^\s*', '', '')
endfunc

func util#TtRemoveEndSpaces(line)
  return substitute(a:line, '\s*$', '', '')
endfunc

func util#TtRemoveBeginEndSpaces(line)
  return util#TtRemoveBeginSpaces(util#TtRemoveEndSpaces(a:line))
endfunc

func util#TtSystem(cmd)
  let out = system(a:cmd)
  return substitute(out, "\<CR>", '', 'g')
endfunc

