paths["stump"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}
HyperSleep(1800)
send {space 2}
HyperSleep(2750)
send {" LeftKey " up}{" RotLeft " 2}{" FwdKey " down}{" LeftKey " down}
HyperSleep(900)
send {" LeftKey " up}
HyperSleep(1500)
send {" FwdKey " up}{space}
Sleep, 1000
)"