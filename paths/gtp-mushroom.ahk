switch HiveSlot
{
	case 2:
		paths["mushroom"] := "
		(LTrim Join`r`n
		" nm_Walk(12, LeftKey, BackKey) "
		send {" BackKey " down}{space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,300)
		send {space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,900)
		send {" BackKey " up}{" RotRight " 2}{" RightKey " down}
		Walk(53)
		send {" RightKey " up}
		" nm_Walk(4, LeftKey) "
		" nm_Walk(4, FwdKey, LeftKey) "
		)"

	case 3:
		paths["mushroom"] := "
		(LTrim Join`r`n
		send {" BackKey " down}{space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,300)
		send {space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,900)
		send {" BackKey " up}{" RotRight " 2}{" RightKey " down}
		Walk(56)
		send {" RightKey " up}
		" nm_Walk(4, LeftKey) "
		" nm_Walk(4, FwdKey, LeftKey) "
		)"

	case 4:
		paths["mushroom"] := "
		(LTrim Join`r`n
		" nm_Walk(11, RightKey, BackKey) "
		send {" BackKey " down}{space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,300)
		send {space down}
		DllCall(""Sleep"",UInt,300)
		send {space up}
		DllCall(""Sleep"",UInt,900)
		send {" BackKey " up}{" RotRight " 2}{" RightKey " down}
		Walk(53)
		send {" RightKey " up}
		" nm_Walk(4, LeftKey) "
		" nm_Walk(4, FwdKey, LeftKey) "
		)"

	case 5:
		paths["mushroom"] := "
		(LTrim Join`r`n
		" nm_Walk(22.5, RightKey, BackKey) "
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
		" nm_Walk(4, LeftKey) "
		" nm_Walk(4, FwdKey, LeftKey) "
		)"

	case 6:
		paths["mushroom"] := "
		(LTrim Join`r`n
		" nm_Walk(7.5, RightKey) "
		" nm_Walk(23, RightKey, BackKey) "
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
		" nm_Walk(4, LeftKey) "
		" nm_Walk(4, FwdKey, LeftKey) "
		)"

	default:
		paths["mushroom"] := "
		(LTrim Join`r`n
		" nm_Walk(24, LeftKey, BackKey) "
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
		" nm_Walk(4, LeftKey) "
		" nm_Walk(4, FwdKey, LeftKey) "
		)"
}