paths["stump"] := "
(LTrim Join`r`n
" nm_Walk(40.5, RightKey) "
send {" RotRight " 2}
" nm_Walk(22.5, RightKey) "
" nm_Walk(22.5, BackKey) "
" nm_Walk(13, RightKey) "
" nm_Walk(40.5, FwdKey) "
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