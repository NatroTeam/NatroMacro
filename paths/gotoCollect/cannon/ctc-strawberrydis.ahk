paths["strawberrydis"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e}
HyperSleep(50)
send {" FwdKey " down}{" RightKey " down}
HyperSleep(500)
send {space 2}
HyperSleep(2080)
send {" FwdKey " up}
HyperSleep(1050)
send {" RightKey " up}{space}{" RotRight " 2}
Sleep, 1000
)"