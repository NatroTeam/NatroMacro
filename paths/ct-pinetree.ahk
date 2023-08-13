paths["pine tree"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(925)
send {space 2}
HyperSleep(4500)
send {" BackKey " up}
HyperSleep(500)
send {" RightKey " up}{space}{" RotLeft " 4}
Sleep, 2000
)"