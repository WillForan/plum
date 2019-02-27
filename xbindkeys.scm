;; https://askubuntu.com/questions/832411/can-i-use-complex-mouse-button-combinations-with-xbindkeys
;; https://www.linuxquestions.org/questions/linux-desktop-74/%5Bxbindkeys%5D-advanced-mouse-binds-4175428297/

; state flag, otherwise we only get one press

;; the binding list
(define (setup-bindings)
    "all bindings ?maybe?"
    (xbindkey-function '("b:3") b3-down-chord-maybe)
)

(define (reset-bindings)
    "reset first binding"
    (ungrab-all-keys)
    (remove-all-keys)
    ; if we pretended to hit a modifier, undo that too
    ; (run-command "xdotool keyup ctrl keyup alt keyup shift keyup super&")
    (display "reset") (newline)
)
(define (up-again)
    "grab keys and watch for bindings"
    (setup-bindings)
    (grab-all-keys)
    (display "watching for keys") (newline)
)

(define (b3-down-chord-maybe)
    "b3 or b3-b1 chord"
    (display "b3 down") (newline)

    ; stop watching b:3
    (reset-bindings)
    
    ;; b:3 then b:1 (left click held, right pushed)
    (xbindkey-function '("b:1")
        (lambda ()
            (display "b1 down") (newline)

            (reset-bindings)
            (up-again)
            (run-command "plum_menu &")
        )
    )

    ;; First Key Up = Released without chord
    (xbindkey-function '(release "b:3") 
        (lambda ()
            (display "b3 up") (newline)
            (reset-bindings)
            (run-command "xte 'mouseclick 3'")
            (display "simulate b:3") (newline)

            ; sleep for .4 b/c simulated button up is comming
            ; and dont want to continue to trigger on it
            ; in an endless loop
            (usleep 4000) 
            (up-again)
        )
    )

)

; actually run
(setup-bindings) 
