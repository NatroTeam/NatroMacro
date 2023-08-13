paths["antpass"] := "
(LTrim Join`r`n
" nm_Walk(50, LeftKey) "
send {" FwdKey " down}
HyperSleep(50)
send {space down}
HyperSleep(400)
send {" FwdKey " up}{space up}
HyperSleep(600)
send {" FwdKey " down}{space down}
HyperSleep(200)
send {space up}
HyperSleep(600)
send {" FwdKey " up}
" nm_Walk(0.5, FwdKey, RightKey) "
" nm_Walk(31.5, FwdKey) "
" nm_Walk(45, LeftKey) "
" nm_Walk(6, RightKey) "
)"