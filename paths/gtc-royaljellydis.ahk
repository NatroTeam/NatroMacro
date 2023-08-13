paths["royaljellydis"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}
HyperSleep(750)
send {space 2}
HyperSleep(1900)
send {" FwdKey " down}
HyperSleep(1000)
send {" LeftKey " up}
HyperSleep(3000)
send {" FwdKey " up}
" nm_Walk(4, FwdKey) "
)"