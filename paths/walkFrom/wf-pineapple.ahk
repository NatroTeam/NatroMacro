paths["pineapple"] := "
(LTrim Join`r`n
" nm_Walk(18, FwdKey) "
" nm_Walk(31.5, RightKey) "
" nm_Walk(4, LeftKey) "
" nm_Walk(10, BackKey) "
" nm_Walk(4, RightKey) "
send {" RotLeft " 4}
" nm_Walk(60, FwdKey) "
" nm_Walk(5.5, BackKey) "
" nm_Walk(10, RightKey) "
send {space down}
Hypersleep(50)
send {space up}
" nm_walk(4, rightkey) "
Hypersleep(1000)
send {e}
Hypersleep(3000)
" nm_Walk(34, FwdKey, RightKey) "
)"