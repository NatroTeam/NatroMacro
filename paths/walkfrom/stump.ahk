paths["stump"] := "
(LTrim Join`r`n
" nm_Walk(40.5, RightKey) "
send {" RotRight " 2}
" nm_Walk(22.5, RightKey) "
" nm_Walk(22.5, BackKey) "
" nm_Walk(13.5, RightKey) "
" nm_Walk(40.5, FwdKey) "
" nm_Walk(18, RightKey) "
send {" RightKey " down}
DllCall(""Sleep"",UInt,200)
send {space down}
DllCall(""Sleep"",UInt,200)
send {space up}
DllCall(""Sleep"",UInt,800)
send {" RightKey " up}
" nm_Walk(45, FwdKey) "
" nm_Walk(4.5, BackKey) "
" nm_Walk(67.5, RightKey) "
" nm_Walk(40.5, FwdKey) "
" nm_Walk(36, RightKey) "
" nm_Walk(27, FwdKey) "
" nm_Walk(2.25, BackKey) "
" nm_Walk(27, RightKey) "
" nm_Walk(2.25, FwdKey) "
)"