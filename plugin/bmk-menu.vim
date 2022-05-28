"======================================================
" Bmk
"======================================================
"if v:version < 802
"  finish
"endif

if exists("g:loaded_bmk")
  finish
endif
let g:loaded_bmk = 1

"------------------------------------------------------
" public func
"------------------------------------------------------
func BmkOpenURL(url)
  call bmk#BmkOpenURL(a:url)
endfunc

func BmkOpenFile(url)
  call bmk#BmkOpenFile(a:url)
endfunc

func BmkOpenDir(url)
  call bmk#BmkOpenDir(a:url)
endfunc

"------------------------------------------------------
func BmkEditDir(dir, winnr=0)
  call bmk#BmkEditDir(a:dir, a:winnr)
endfunc

func BmkEditFile(file, winnr=0)
  call bmk#BmkEditFile(a:file, a:winnr)
endfunc

"------------------------------------------------------
func BmkOpen(url, winnr=0)
  call bmk#BmkOpen(a:url, a:winnr)
endfunc

func BmkView(url, winnr=0)
  call bmk#BmkView(a:url, a:winnr)
endfunc

func BmkEdit(url, winnr=0)
  call bmk#BmkEdit(a:url, a:winnr)
endfunc

"------------------------------------------------------
func BmkOpenThis()
  call bmk#BmkOpenThis()
endfunc

func BmkViewThis()
  call bmk#BmkViewThis()
endfunc

"------------------------------------------------------
func BmkToggleDebug()
  call bmk#BmkToggleDebug()
endfunc

"------------------------------------------------------
func CpmSave()
  call cpm#CpmSave()
endfunc

"------------------------------------------------------
" command for bmk
"------------------------------------------------------
command! -nargs=+ BmkEditDir   call bmk#BmkEditDir(<f-args>)
command! -nargs=+ BmkEditFile  call bmk#BmkEditFile(<f-args>)

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
call cpm#CpmInit()
