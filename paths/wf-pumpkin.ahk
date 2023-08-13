paths["pumpkin"] := "
(LTrim Join`r`n
" nm_Walk(9, RightKey) "
send {" RotLeft " 4}
" nm_Walk(9, BackKey) "
send {" BackKey " down}
send {" LeftKey " down}
HyperSleep(2000)
send {space down}
HyperSleep(200)
send {space up}
HyperSleep(2000)
send {" BackKey " up}
send {" LeftKey " up}
" nm_Walk(36, FwdKey) "
" nm_Walk(4.5, FwdKey, RightKey) "
" nm_Walk(4.5, FwdKey, LeftKey) "
" nm_Walk(27, FwdKey) "
" nm_Walk(2.25, FwdKey, LeftKey) "
" nm_Walk(85.5, FwdKey) "
" nm_Walk(2.25, BackKey) "
" nm_Walk(22.5, RightKey) "
" nm_Walk(2.25, FwdKey) "
)"