#!/usr/bin/env bash
# -*- sh-shell: bash -*-
e(){
    # launch emacs with gui and fork if have display
    # otherwise use -t for terminal
    # e -t => force terminal mode
    #   'emacsclient -t -t' is okay
    # first pass created without seeing
    # https://www.emacswiki.org/emacs/EmacsPipe
    # new frame, no wait
    local args="-t"
    [[ -n "$DISPLAY" && ! "$@" =~ ^-t ]] && args="-c -n" 
    set -x
    emacsclient -a '' $args "$@"
}
## TODO: jump to window with current file if exists
# in e.g. init.el
# (setq-default frame-title-format '("%f [emacs %m]"))
# (setq-default icon-title-format frame-title-format)

[[ $(basename "$0") == "e" ]] && e "$@"
