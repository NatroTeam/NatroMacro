paths["cactus"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(950)
send {space 2}
HyperSleep(1700)
send {" RightKey " up}{" BackKey " up}
HyperSleep(1000)
send {space}
Sleep, 2000
)"