"======================================================
" Bmk
"======================================================
if v:version < 802
  finish
endif

if exists("g:loaded_bmk")
  finish
endif
let g:loaded_bmk = 1

"------------------------------------------------------
" command for bmk
"------------------------------------------------------
command! -nargs=+ BmkEditDir   call bmk#BmkEditDir(<f-args>)
command! -nargs=+ BmkEditFile  call bmk#BmkEditFile(<f-args>)

func BmkEditDir(dir, winnr)
  call bmk#BmkEditDir(a:dir, a:winnr)
endfunc

func BmkEditFile(file, winnr)
  call bmk#BmkEditFile(a:file, a:winnr)
endfunc

"------------------------------------------------------
" command for cpm
"------------------------------------------------------
command!          CpmReload    call cpm#CpmReload()
command! -nargs=* CpmOpen      call cpm#CpmOpen(<f-args>)

"------------------------------------------------------
" autocmd
"------------------------------------------------------
augroup ag_bmk
  autocmd!
  autocmd BufWinEnter *        call bmk#BmkMapWin()
  autocmd WinEnter    *        call bmk#BmkMapWin()
augroup END

"------------------------------------------------------
" init
"------------------------------------------------------
call bmk#BmkInit()
