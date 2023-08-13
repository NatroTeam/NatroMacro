paths["pine tree"] := "
(LTrim Join`r`n
" nm_Walk(45, FwdKey) "
" nm_Walk(72, RightKey) "
" nm_Walk(63, BackKey) "
send {" RotLeft " 4}
" nm_Walk(9, RightKey) "
" nm_Walk(4.5, FwdKey) "
DllCall(""Sleep"",UInt,250)
send {space down}
DllCall(""Sleep"",UInt,50)
send {space up}
DllCall(""Sleep"",UInt,350)
send {space}
send {" FwdKey " down}
DllCall(""Sleep"",UInt,6100)
send {" FwdKey " up}
DllCall(""Sleep"",UInt,250)
)"