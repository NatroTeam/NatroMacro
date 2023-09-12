paths["riley"] :="
(LTrim Join`r`n
;gotoramp
send {space down}
HyperSleep(300)
Send {space up}
" nm_Walk(36, RightKey) "
send {space down}
HyperSleep(300)
send {space up}
" nm_Walk(6, RightKey) "
HyperSleep(500)
send {" RotRight " 2}
send {space down}
HyperSleep(100)
send {space up}
" nm_Walk(3, FwdKey) "
HyperSleep(1000)
send {space down}{" RightKey " down}
HyperSleep(100)
send {space up}
HyperSleep(300)
send {space}{" RightKey " up}
HyperSleep(1000)
" nm_Walk(26, RightKey) "
" nm_Walk(5, FwdKey) "
" nm_walk(1, BackKey) "
send {space down}
Hypersleep(100)
send {space up}
" nm_Walk(8, FwdKey) "
sleep, 1500
)"