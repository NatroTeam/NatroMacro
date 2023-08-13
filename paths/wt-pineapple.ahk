paths["pineapple"] := "
(LTrim Join`r`n
;gotoramp
" nm_Walk(67.5, BackKey, LeftKey) "
send {" RotRight " 4}
" nm_Walk(45, FwdKey) "
send {" RotRight " 2}
" nm_Walk(58.5, FwdKey) "
" nm_Walk(18, RightKey) "
send, {" FwdKey " down}
HyperSleep(200)
send {space down}
HyperSleep(100)
send, {space up}
HyperSleep(800)
send {" FwdKey " up}{" RotLeft " 2}
" nm_Walk(63, FwdKey) "
)"