paths["candles"] := "
(LTrim Join`r`n
;gotoramp
Send {space down}
HyperSleep(300)
Send {space up}
" nm_Walk(36, RightKey) "
send {space down}
HyperSleep(300)
send {space up}
" nm_Walk(6, RightKey) "
Sleep 500
send {" RotRight " 2}
send {space down}
HyperSleep(100)
send {space up}
" nm_Walk(3, FwdKey) "
Sleep 1000
send {space down}{" RightKey " down}
HyperSleep(100)
send {space up}
HyperSleep(300)
send {space}{" RightKey " up}
HyperSleep(1000)
" nm_Walk(4, RightKey) "
" nm_Walk(14, FwdKey) "
Sleep 500
)"