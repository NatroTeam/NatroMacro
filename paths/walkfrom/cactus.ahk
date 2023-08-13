paths["cactus"] := "
(LTrim Join`r`n
" nm_Walk(9, LeftKey) "
" nm_Walk(22.5, BackKey) "
send {" BackKey " down}{" LeftKey " down}
DllCall(""Sleep"",UInt,2000)
send {space down}
DllCall(""Sleep"",UInt,200)
send {space up}
DllCall(""Sleep"",UInt,2000)
send {" BackKey " up}{" LeftKey " up}
" nm_Walk(36, FwdKey) "
" nm_Walk(4.5, FwdKey, RightKey) "
" nm_Walk(4.5, FwdKey, LeftKey) "
" nm_Walk(27, FwdKey) "
" nm_Walk(2.25, FwdKey, LeftKey) "
" nm_Walk(90, FwdKey) "
" nm_Walk(2.25, BackKey) "
" nm_Walk(22.5, RightKey) "
" nm_Walk(2.25, FwdKey) "
)"