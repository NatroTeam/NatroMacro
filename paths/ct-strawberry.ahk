paths["strawberry"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(700)
send {space 2}
HyperSleep(1700)
send {" RightKey " up}{" BackKey " up}{space}{" RotRight " 2}
Sleep, 2000
)"