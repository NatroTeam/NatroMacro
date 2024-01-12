paths["bamboo"] := "
(LTrim Join`r`n
" nm_Walk(16, LeftKey) "
" nm_Walk(5, RightKey) "
send {" RotRight " 2}
" nm_Walk(75, RightKey) "
" nm_Walk(64, FwdKey) "
" nm_Walk(7, FwdKey, RightKey) "
" nm_Walk(36, FwdKey) "
" nm_Walk(3, BackKey) "

switch % " HiveSlot "
{
case 3:
" nm_Walk(0.25, BackKey) " ; 4.2, BackKey

default:
" nm_Walk(23, RightKey) "
" nm_Walk(3.5, FwdKey) " ; 2
}
)"
;path 230212 zaappiix