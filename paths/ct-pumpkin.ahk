paths["pumpkin"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(950)
send {space 2}
HyperSleep(2700)
send {" RightKey " up}
HyperSleep(500)
send {" BackKey " up}
HyperSleep(600)
send {space}{" RotLeft " 4}
Sleep, 1500
)"