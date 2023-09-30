If (HiveBees >= 25) && (MoveMethod = "cannon")
{
paths["pineapple"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}
Sleep, 2500
send {" RotRight " 3}
" nm_Walk(7, BackKey) "
" nm_Walk(10, BackKey, RightKey) "
" nm_Walk(10, RightKey) "
" nm_Walk(13, RightKey, FwdKey) "
" nm_Walk(14, BackKey, RightKey) "
send {" FwdKey " down}{" LeftKey " down}
Walk(14)
send {" LeftKey " up}
" nm_Walk(10, RightKey) "
send {" FwdKey " up}
" nm_Walk(7, BackKey) "
send {" RotRight " 1}
HyperSleep(100)
)"
}
else {
paths["pineapple"] := "
(LTrim Join`r`n
;gotoramp
" nm_Walk(67.5, BackKey, LeftKey) "
send {" RotRight " 4}
" nm_Walk(30, FwdKey) "
" nm_Walk(20, FwdKey, RightKey) "
send {" RotRight " 2}
" nm_Walk(43.5, FwdKey) "
" nm_Walk(18, RightKey) "
" nm_Walk(6, FwdKey) "
send {" RotLeft " 2}
" nm_Walk(66, FwdKey) "
" nm_Walk(19, FwdKey, LeftKey) "
" nm_Walk(7, BackKey, RightKey) "
)"
}
;path 230212 zaappiix
;path 230729 noobyguy: If (HiveBees < 25) && (MoveMethod = "cannon") & walk path
