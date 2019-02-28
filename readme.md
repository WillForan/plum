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
# bar
echo '^ca(1,plum notify)notify^ca()' | dzen2 -p 

# menu
read XP YP <<< $(getcurpos); echo -e "\nplum notify\nplum" | dzen2 -y "$YP" -x "$XP" -l 7 -tw 125 -ta l -w 125 -m -p -e 'onstart=uncollapse;button1=menuexec;leaveslave=exit;button3=exit'
```

### depends
* `xdotool`
* `xclip`
* shell rc configuration like `PS1="\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007..."` 
* key/chord/gesture launcher (e.g. `sxhkd`, `xbindkeys`, `easystroke`, `libinput-gesutre`)

#### Titles

current working directory is often determined by the title of the focused window. Here are some snippets to help set that.

vim: 

```
set title
autocmd BufEnter * let &titlestring = $USER . "@".hostname() . ":" . expand("%:p:h") .' ' . expand("%F")  . ' [vim]'
```

zsh:

```
 function precmd () {
   window_title="\033]0;$USER@$HOSTNAME:${PWD}\007"
   echo -ne "$window_title"
 }
 # before overwritting, check 
 #  type -f precmd
 # and
 # type -f $(print -l ${(ok)functions})| less +/set_title
 # which for me pointed to grml_control_xterm_title

 grml_control_xterm_title () {case $TERM in (xterm*|rxvt*) set_title "${(%):-"%n@%m:%~"}" "$1" ;;esac; }

```

bash:

```
  export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
  # see 
  #  env | grep COM
  # before redefining
  #  eval $(fasd --init auto) 
  # may have already set the title and done other useful things
```

### Editors
see `vimit` 
 - fails for remote ssh + vim
 - is sketchy for suspended vim
 - netbeans socket interface not yet explored yet

#### emacs
`emacsclient` would be much easier. Plus tramp provides easy access to remote files. But one crazy term buffer or notmuch query will lock up all buffers. Independent processes are a feature.

## TODO
- additional contexts in config. eg: `context workspace i3-msg -t get_workspace| jq ...`

## References
- dzen as a menu: https://bbs.archlinux.org/viewtopic.php?id=47833
- mouse position code: https://github.com/Conservatory/quark/blob/master/python-browser-8/getcurpos.c (Robert Manea via Karl Fogel)

## Other thoughts
* use as a urxvt plugin with help from [`keyboard-select`](https://github.com/muennich/urxvt-perls)
* use inside tmux selected text
* use guile xbindkeys interface to simulate mouse chordind to interact with secondary buffer for acme like moues chording

