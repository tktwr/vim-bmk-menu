if exists("g:loaded_bmk")
  finish
endif
let g:loaded_bmk = 1

call bmk#init()
call cpm#init()

"------------------------------------------------------
" command
"------------------------------------------------------
command! -nargs=+ BmkEditDir   call bmk#EditDir(<f-args>)
command! -nargs=+ BmkEditFile  call bmk#EditFile(<f-args>)
command! -nargs=+ BmkOpenItem  call bmk#item#OpenItem(0, <f-args>)
command! -nargs=+ BmkViewItem  call bmk#item#ViewItem(0, <f-args>)
command! -nargs=+ BmkEditItem  call bmk#item#EditItem(0, <f-args>)

command! -nargs=* CpmOpen      call cpm#popup_menu#open(<f-args>)
command!          CpmReload    call cpm#io#Reload()

"------------------------------------------------------
" autocmd
"------------------------------------------------------
augroup ag_bmk
  autocmd!
  autocmd BufWinEnter *        call bmk#map#setup()
  autocmd WinEnter    *        call bmk#map#setup()
augroup END

