paths["pine tree"] := "
(LTrim Join`r`n
if (" HiveBees " < 25) {
	" nm_Walk(33, FwdKey) "
	" nm_Walk(13, FwdKey, RightKey) "
	" nm_Walk(78, RightKey) "
	" nm_Walk(42, BackKey) "
	" nm_Walk(6, BackKey, LeftKey) "
	" nm_Walk(3, LeftKey) "
	" nm_Walk(4, BackKey) "
	send {" RotLeft " 4}{space down}
	HyperSleep(200)
	send {space up}
	" nm_Walk(108, FwdKey) "
}
else {
	" nm_Walk(35, FwdKey) "
	" nm_Walk(75, RightKey) "
	" nm_Walk(42, BackKey) "
	" nm_Walk(6, BackKey, LeftKey) "
	" nm_Walk(3, LeftKey) "
	" nm_Walk(4, BackKey) "
	send {" RotLeft " 4}{space down}
	HyperSleep(150)
	send {space up}{" FwdKey " down}
	HyperSleep(200)
	send {space}
	HyperSleep(3000)
	send {" FwdKey " up}
	HyperSleep(2600)
	" nm_Walk(13, FwdKey) "
}

switch % " HiveSlot "
{
case 3:
" nm_Walk(4.2, BackKey) "

default:
" nm_Walk(23, RightKey) "
" nm_Walk(2, FwdKey) "
}
)"
;path with and without glider zaappiix 230212