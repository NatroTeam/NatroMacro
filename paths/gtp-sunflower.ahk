switch HiveSlot
{
	case 2:
		paths["sunflower"] := "
		(LTrim Join`r`n
		" nm_Walk(34, BackKey, RightKey) "
		send {" RotRight " 1} 
		" nm_Walk(8, RightKey, FwdKey) "
		" nm_Walk(10, FwdKey, LeftKey) "
		" nm_Walk(9, BackKey) "
		send {" RotRight " 1} 
		)"

	case 3:
		paths["sunflower"] := "
		(LTrim Join`r`n
		" nm_Walk(8, FwdKey) "
		send {" RotRight " 1} 
		" nm_Walk(40, RightKey) "
		" nm_Walk(10, FwdKey, RightKey) "
		" nm_Walk(6, FwdKey, LeftKey) "		
		" nm_Walk(9, BackKey) "
		send {" RotRight " 1} 
		)"

	case 4:
		paths["sunflower"] := "
		(LTrim Join`r`n
		;gotoramp
		" nm_Walk(14, BackKey) "
		send {" RotRight " 1} 
		" nm_Walk(28, RightKey) "
		" nm_Walk(15, FwdKey) "
		" nm_Walk(9, BackKey) "
		send {" RotRight " 1} 
		)"

	case 5:
		paths["sunflower"] := "
		(LTrim Join`r`n
		;gotoramp
		" nm_Walk(14, BackKey) "
		send {" RotRight " 1} 
		" nm_Walk(25, RightKey) "
		" nm_Walk(15, FwdKey) "
		" nm_Walk(9, BackKey) "
		send {" RotRight " 1} 
		)"

	case 6:
		paths["sunflower"] := "
		(LTrim Join`r`n
		;gotoramp
		" nm_Walk(14, BackKey) "
		send {" RotRight " 1} 
		" nm_Walk(25, RightKey) "
		" nm_Walk(15, FwdKey) "
		" nm_Walk(9, BackKey) "
		send {" RotRight " 1} 
		)"

	default:
		paths["sunflower"] := "
		(LTrim Join`r`n
		;gotoramp
		" nm_Walk(14, BackKey) "
		send {" RotRight " 1} 
		" nm_Walk(25, RightKey) "
		" nm_Walk(15, FwdKey) "
		" nm_Walk(9, BackKey) "
		send {" RotRight " 1} 
		)"
}