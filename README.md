# vim-bmk-menu

vim-bmk-menu is a user defined popup menu specified in bookmark files.

Requirements: Vim >= 8.1 or Neovim >= 0.7.0 (limited functionalities)

## Install

Install plugins using a plugin manager such as
[vim-plug](https://github.com/junegunn/vim-plug).

Install
[popup-menu.nvim](https://github.com/kamykn/popup-menu.nvim)
to support a popup menu in neovim.
~~~
if has('nvim')
  Plug 'kamykn/popup-menu.nvim'
endif
~~~

vim-bmk-menu is supposed to be used with
[vim-ide-style](https://github.com/tktwr/vim-ide-style).
~~~
Plug 'tktwr/vim-bmk-menu'
Plug 'tktwr/vim-ide-style'
~~~

## bashrc

~~~
source ~/.vim/plugged/vim-ide-style/etc/bashrc
~~~

## Maps

~~~
nnoremap <silent> <Space>    <C-W>:CpmOpen<CR>
tnoremap <silent> <C-Space>  <C-W>:CpmOpen<CR>
~~~

# Custom User Settings

## External Programs
~~~
let g:bmk_open_url_prog = "chrome.sh"
let g:bmk_open_dir_prog = "explorer.sh"
let g:bmk_open_file_prog = "vscode.sh"
~~~

## Bookmark Files
~~~
let g:cpm_files = [
  \ "$MY_BMK/cmd.txt",
  \ "$MY_BMK/bmk.txt",
  \ ]
let g:cpm_titles = {
  \ 'terminal' : ['cmd.term', 'cmd.git'],
  \ 'buffer'   : ['cmd.buf & cmd.sys', 'links'],
  \ 'ft:fern'  : ['bmk.dir'],
  \ }
~~~

- '$MY_BMK' is an environment variable for bookmark files
- '&' concatenates menus

## Examples of Bookmark Files

### cmd.txt
~~~
[cmd.buf] ---------------------------- | ----------------------------------------
- I IDE                                | :VisIDE
- < SideBar                            | :VisSideBarToggle
- D Fern                               | :VisFernDrawer %:p:h
- N Editor                             | :new
- T Term                               | :VisTerm
- _ Cd                                 | :VisSendCdE2T
- H Help                               | :VisHelp
[cmd.sys] ---------------------------- | ----------------------------------------
-   VisCheckEnv                        | :VisCheckEnv
-   VisWinInfo                         | :VisWinInfo
- R CpmReload                          | :CpmReload
[cmd.term] --------------------------- | ----------------------------------------
-   IDE                    (I)         | > I<CR>
-   Fern                   (D)         | > D<CR>
-   Editor                 (N)         | > N<CR>
-   Term                   (T)         | > T<CR>
    ---------------------------------- | ----------------------------------------
- 1 ,resize 10                         | > ,resize 10<CR>
- 2 ,resize 20                         | > ,resize 20<CR>
- 3 ,resize 30                         | > ,resize 30<CR>
- 4 ,resize 40                         | > ,resize 40<CR>
[cmd.git] ---------------------------- | ----------------------------------------
-   git status                         | > git status<CR>
-   git log                            | > git log --graph --oneline -6<CR>

# vim:set ft=bmk syntax=txt nowrap:
~~~

### bmk.txt
~~~
[bmk.dir] ---------------------------- | ----------------------------------------
-   C:/                                | C:/
-   C:/Program Files/                  | C:/Program Files/
-   Desktop/                           | $HOME/Desktop/
-   Downloads/                         | $HOME/Downloads/
[links] ------------------------------ | ----------------------------------------
-   vim-bmk-menu                       | https://github.com/tktwr/vim-bmk-menu

# vim:set ft=bmk syntax=txt nowrap:
~~~

# Reference

## Bookmark File Format

### Menu Item
~~~
[title] ------------------------------ | ----------------------------------------
- K menu_item                          | menu_value
    ---------------------------------- | ----------------------------------------
~~~

- K: shortcut key

### Menu Value

| Pattern | Type           |
| ---     | ---            |
| http    | http           |
| https   | http           |
| .html   | html           |
| .pdf    | pdf            |
| //      | network folder |
| :       | vim command    |
| >       | term command   |
|         | directory      |
|         | file           |
|         | vim normal     |

