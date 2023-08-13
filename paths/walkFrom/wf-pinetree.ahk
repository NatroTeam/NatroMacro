paths["pine tree"] := "
(LTrim Join`r`n
" nm_Walk(35, FwdKey) "
" nm_Walk(75, RightKey) "
" nm_Walk(50, BackKey) "
send {" RotLeft " 4}
HyperSleep(100)
send {space down}
HyperSleep(50)
send {space up}
HyperSleep(350)
send {space}
HyperSleep(4200)
send {" FwdKey " down}{" RightKey " down}
HyperSleep(500)
send {" FwdKey " up}{" RightKey " up}
HyperSleep(1500)
" nm_Walk(3, FwdKey) "
" nm_Walk(14, FwdKey, RightKey) "
)"