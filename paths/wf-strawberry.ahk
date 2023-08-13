paths["strawberry"] := "
(LTrim Join`r`n
Send {"RotLeft " 2}
" nm_Walk(12, BackKey) "
" nm_Walk(15, BackKey, LeftKey) "
" nm_Walk(18, LeftKey) "
" nm_Walk(10, FwdKey) "
" nm_Walk(2, FwdKey, RightKey) "
" nm_Walk(59, FwdKey) "
" nm_Walk(8, LeftKey) "
" nm_Walk(2, FwdKey) "
" nm_Walk(5, RightKey) "
" nm_Walk(3, LeftKey) "
" nm_Walk(46, FwdKey) "

switch % " HiveSlot "
{
case 3:
" nm_Walk(4.2, BackKey) "
HyperSleep(50)

default:
" nm_Walk(23, RightKey) "
" nm_Walk(2, FwdKey) "
}
)"
;zaappiix 230203