# Plum

Run comands based on regular expressions rules matching and extracting clipboard text, current window title, and application name.


`plum` is an adulterate plan9 [`plumber(4)`](https://9fans.github.io/plan9port/man/man4/plumber.html) for X11, with other apologies to [godothecorrectthing](https://github.com/andrewchambers/godothecorrectthing).

Configuration is similar to but not compatible with [`plumb(7)`](https://9fans.github.io/plan9port/man/man7/plumb.html).

## TODO
* cwd parser
* cwd in file/dir

## Example Usage
* mouse select a url anywhere, hit the magic key, and the url opens in firefox
* select `error at ./plum line 168, near "my cmd ="`, hit the magic key, and open an editor on `./plum` with `my cmd` highlighted.
* select ``


## How
### depends
* `xdotool`
* `xclip`
* shell rc configuration like `PS1="\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007..."` 
* key/chord/gesture launcher (e.g. `sxhkd`, `xbindkeys`, `easystroke`, `libinput-gesutre`)

### Editors
see `vimit`
 - fails for remote ssh + vim
 - fails for suspended vim
 - netbeans socket interface not yet explored here

#### emacs
`emacsclient` would be much easier. Plus tramp provides easy access to remote files. But one crazy term buffer or notmuch query will lock up all buffers. 

## Other thoughts
* use as a urxvt plugin with help from [`keyboard-select`](https://github.com/muennich/urxvt-perls)
* use inside tmux selected text

