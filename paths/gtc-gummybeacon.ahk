paths["gummybeacon"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}{" FwdKey " down}
HyperSleep(1070)
send {space 2}
HyperSleep(2200)
send {" LeftKey " up}
HyperSleep(2200)
send {space}{" FwdKey " up}
Sleep, 1200
)"