# Plum
Execute an acction with selected text using a regular expression based and context aware command runner. 

`plum` is an adulterate plan9 [`plumber(4)`](https://9fans.github.io/plan9port/man/man4/plumber.html) for X11, with other apologies to [godothecorrectthing](https://github.com/andrewchambers/godothecorrectthing).

`plum` uses the clipboard (default to primary) text, current window title, focused application name, stdin, and/or input arguments to match rule and extract variables and then execute a given command.

Configuration is similar to but not compatible with [`plumb(7)`](https://9fans.github.io/plan9port/man/man7/plumb.html).

## Supplements
 * `plum_menu` rofi based selector for `plum argv` pattern actions.
 * `e` - emacsclient wrapper
 * `vimit` - vim wrapper. switch to term with vim@file or open new terminal with vim@file. support linenum and search
 * `plum_acmebar`(tcl/tk) and `plum_pybar` (py/tk) attempts at a always-on-top editable command bar a la acme (via plum argv patterns)

## Example plum config/rules

A simple rule looks like
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
# vimit is an included find-and-focus or execute vim wrapper
start vimit "$file" +$line
```

## Setup

1. install `xdotool` and `xclip`
1. get/clone `plum` and add it to your path.
2. configure shell to set cwd in title (see [#X11Titles](#x11titles))
3. play with `~/.conf/plum.conf` (see [#Config](#config))
4. setup hotkey/launcher (see [#Launchers](#launchers)) 

If you are too trusting of internet code and haven't done anything special in your shell rc file, try `source <(curl 'https://raw.githubusercontent.com/WillForan/plum/master/user_install.sh`). But don't do that. Maybe just use [`user_install.sh`](user_install.sh) as a guide.


### Config
The configuration has settings and rulesets. They must be separated by a single newline. See [plum.conf](plum.conf).

#### Parse CWD
Currently, the only setting is to how to get `$cwd` from a `$title` of a `$program`.

If desired, the command must be at the top of the config file. 

the Format is 
```
parse cwd app_regexp cwd_regexp cwd_matches
```

for example
```
parse cwd urxvt|term \w+@\S+?:\s?([~/]\S*?)"?(\s|$) $1
```

says if the focus window's `ps` listed binary matches `urxvt` or `term`, and the tile looks like `\w+@\S+?:\s?([~/]\S*?)"?(\s|$)`, set the cwd to what is in the first captured match. 

That is, the urxvt title `user@host:/path/to/cwd` is the cwd `/path/to/cwd`

#### Rulesets
After settings, plum searches rulesets. They are sets of rules for matching text, extracting variables, and executing commands
* `patternid` - what to call this pattern rule. Used in debuging. see [`plum_debug_section`](plum_debug_section).
* `from` - from where to pull the `text` variable. sources are: `primary`, `clipboard`, `argv`, `stdin`
* `var matches regexp` - match `$var` against a `$regex`. vars include `text`,`title`, `app`, and sometimes `cwd`, `file`, and `dir`.
* `add` - add variables that can be used by `match`
* `arg` - test argument (currently only `isfile` and `isdir`), create/overwrite `file` or `dir` variable
* `start` - run a command
* `!` provides negation variants `!isfile`,`!isdir`, `!matches`

Though not strictly true, the functional minimum for a rule set is `matches` + `start`

```
text matches (\w+)
start xmessage -center $1
```

#### Config Details

### X11Titles

`isfile` and `isdir` config options take advantage of the current working directory to find relative file names (e.g. `./plum.conf`). The current working directory is determined by the title of the focused window. Here are some snippets to help set that.


in `~/.bashrc`:

```
  export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
  # see 
  #  env | grep COM
  # before redefining
  #  eval $(fasd --init auto) 
  # may have already set the title and done other useful things
```

in `~/.zshrc`

```
 function precmd () {
   window_title="\033]0;$USER@$HOSTNAME:${PWD}\007"
   echo -ne "$window_title"
 }
 # before overwritting, check 
 #  type -f precmd
 # and
 # type -f $(print -l ${(ok)functions})| less +/set_title
 # for me grml_control_xterm_title was removing cwd when running a program
 # I added it back like:
 grml_control_xterm_title () {case $TERM in (xterm*|rxvt*) set_title "${(%):-"%n@%m:%~"}" "$1" ;;esac; }

```

in `~/.vimrc`

```
set title
autocmd BufEnter * let &titlestring = $USER . "@".hostname() . ":" . expand("%:p:h") .' ' . expand("%F")  . ' [vim]'
```

in `~/.emacs`
```
(setq-default frame-title-format (concat (system-name) "@" (user-login-name) ":%f [emacs %m]"))
(setq-default icon-title-format frame-title-format)
```

### Launchers

`plum` isn't all that useful if you don't have a way to summon it after selecting some text. I have a few suggestions. Consider
 * `libinput-gestures` or `easystroke` to call with trackpad gestures
 * `xbindkeys` to enable plum with a mouse chord (see [`right-left-chord.scm`](right-left-chord.scm) and [`plum_menu`](plum_menu))
 * `xbindkeys` or [`sxhcs`](https://github.com/baskerville/sxhkd) to trigger plum with the keyboard.
 * `dzen2` to create buttons to push -- dzen2 doesn't report it's bar as an active title so cwd can be fetched from wherever you selected text

#### Launcher Examples

##### `~/.xbindkeys` keyboard
```
"plum"
    Mod4 + g

```

##### `~/.config/libinput-gestures.conf`
```
gesture: swipe up 4	plum
```

##### `dzen2`
```
# bar
echo '^ca(1,plum notify)notify^ca()' | dzen2 -p 

# menu
read XP YP <<< $(getcurpos); echo -e "\nplum notify\nplum" | dzen2 -y "$YP" -x "$XP" -l 7 -tw 125 -ta l -w 125 -m -p -e 'onstart=uncollapse;button1=menuexec;leaveslave=exit;button3=exit'
```


## Editors
see `vimit` 
 - fails for remote ssh + vim
 - is sketchy for suspended vim
 - netbeans socket interface not yet explored yet

#### Emacs
`emacsclient` would be much easier. Plus tramp provides easy access to remote files. But one crazy term buffer or notmuch query will lock up all buffers. Independent processes are a feature many `vim` instances.

## Hacking
### Notes
* debuging: `export PLUM_DEBUG=9`
* tests:    `find -iname '*t' | xargs -n1 perl`

### TODO
- additional contexts in config. eg: `context workspace i3-msg -t get_workspace| jq ...`

## References
- dzen as a menu: https://bbs.archlinux.org/viewtopic.php?id=47833
- mouse position code: https://github.com/Conservatory/quark/blob/master/python-browser-8/getcurpos.c (Robert Manea via Karl Fogel)

## Other thoughts
* use as a urxvt plugin with help from [`keyboard-select`](https://github.com/muennich/urxvt-perls)
* use inside tmux selected text

