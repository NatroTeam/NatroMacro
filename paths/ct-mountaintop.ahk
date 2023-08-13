paths["mountain top"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}{" BackKey " down}
HyperSleep(1525)
send {space 2}
HyperSleep(1100)
send {" LeftKey " up}
HyperSleep(350)
send {" BackKey " up}{space}
Sleep, 1500
)"