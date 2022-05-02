# vim-bmk-menu

vim-bmk-menu is a user defined popup menu specified in bookmark files.

## Install

vim-bmk-menu is supposed to be used with
[vim-ide-style](https://github.com/tktwr/vim-ide-style).

For vim-plug, install the vim-bmk-menu plugin as follows.
~~~
Plug 'tktwr/vim-bmk-menu'
Plug 'tktwr/vim-ide-style'
~~~

## bashrc

~~~
export MY_VIM_BMK="$MY_VIM/plugged/vim-bmk-menu"
export MY_VIM_IDE="$MY_VIM/plugged/vim-ide-style"
export PATH="$MY_VIM_IDE/bin:$MY_VIM_BMK/bin:$PATH"
source $MY_VIM_IDE/etc/bashrc
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
- E IDE                                | :VisIDE
- I WinInitSize                        | :VisWinInitSize
- < SideBar                            | :VisSideBarToggle
- D Fern                               | :VisFernDrawer %:p:h
- N Editor                             | :new
- T Term                               | :VisTerm
- C VisSendCdE2T                       | :VisSendCdE2T
- H Help                               | :VisHelp
[cmd.sys] ---------------------------- | ----------------------------------------
-   VisCheckEnv                        | :VisCheckEnv
-   VisWinInfo                         | :VisWinInfo
- R CpmReload                          | :CpmReload
[cmd.term] --------------------------- | ----------------------------------------
-   WinInitSize            (I)         | > I<CR>
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

