# Plum
Do something with selected text using a context aware regular expression based command runner.

`plum` is an adulterate plan9 [`plumber(4)`](https://9fans.github.io/plan9port/man/man4/plumber.html) for X11, with other apologies to [godothecorrectthing](https://github.com/andrewchambers/godothecorrectthing).

It works by matching and extracting against the clipboard (default to primary) text, current window title, focused application name, stdin, and/or input arguments.
You can add more fields.

Configuration is similar to but not compatible with [`plumb(7)`](https://9fans.github.io/plan9port/man/man7/plumb.html).

## Example use and configureation

A simple rule it looks like
```
# extract the first web url and open it
text matches (https?://[^\s()]+)
start xdg-open "$1"
```

A more useful rule
```
# open file at line from error message 'file.pl line 20'
text matches (\S+) line (\d+)
add file=$1 line=$2 
# isfile makes use of cwd and expands globs to try to find a file
arg isfile $file
start vimit "$file" +$line
```



## Setup

1. extract `plum` into your path.
2. setup hotkeys
3. configure shell to set cwd in title (`Depends` paragraph)
4. play with `~/.conf/plum.conf`

### example launchers

#### `~/.xbindkeys`
```
"plum"
    Mod4 + g

```

#### `~/.config/libinput-gestures.conf`
```
gesture: swipe up 4	plum
```

#### `dzen2`
```
echo '^ca(1,plum notify)notify^ca()' | dzen2 -p 
```

### depends
* `xdotool`
* `xclip`
* shell rc configuration like `PS1="\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007..."` 
* key/chord/gesture launcher (e.g. `sxhkd`, `xbindkeys`, `easystroke`, `libinput-gesutre`)

### Editors
see `vimit` 
 - fails for remote ssh + vim
 - is sketchy for suspended vim
 - netbeans socket interface not yet explored yet

#### emacs
`emacsclient` would be much easier. Plus tramp provides easy access to remote files. But one crazy term buffer or notmuch query will lock up all buffers. Independent processes are a feature.

## TODO
- additional contexts in config. eg: `context workspace i3-msg -t get_workspace| jq ...`

## Other thoughts
* use as a urxvt plugin with help from [`keyboard-select`](https://github.com/muennich/urxvt-perls)
* use inside tmux selected text
* use guile xbindkeys interface to simulate mouse chordind to interact with secondary buffer for acme like moues chording

