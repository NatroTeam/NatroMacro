paths["antpass"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e}
HyperSleep(50)
send {" FwdKey " down}{" LeftKey " down}
HyperSleep(1100)
send {space 2}
HyperSleep(1500)
send {" LeftKey " up}
HyperSleep(4300)
send {" LeftKey " down}
HyperSleep(1400)
send {" FwdKey " up}{" LeftKey " up}
send {space}
HyperSleep(1400)
" nm_Walk(5, BackKey, LeftKey) "
)"