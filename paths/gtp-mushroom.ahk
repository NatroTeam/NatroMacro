		paths["mushroom"] := "
		(LTrim Join`r`n
		;gotoramp
		" nm_Walk(31, LeftKey, BackKey) "
		send {" BackKey " down}{space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,300)
		send {space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,900)
		send {" BackKey " up}{" RotRight " 2}{" RightKey " down}
		Walk(50)
		send {" RightKey " up}
		" nm_Walk(16, FwdKey) "
		" nm_Walk(10, BackKey, LeftKey) "
		)"