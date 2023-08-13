paths["spider"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" BackKey " down}
HyperSleep(1050)
send {space 2}
HyperSleep(300)
send {" BackKey " up}{space}{" RotLeft " 4}
Sleep, 1500
)"