switch HiveSlot
{
	case 2:
		paths["dandelion"] := "
		(LTrim Join`r`n
		;gotoramp
		" nm_Walk(40, BackKey, LeftKey) "
		" nm_Walk(10, LeftKey) "
		send {" RotLeft " 2}
		)"

	case 3:
		paths["dandelion"] := "
		(LTrim Join`r`n
		" nm_Walk(30, BackKey, LeftKey) "
		" nm_Walk(3, BackKey, RightKey) "
		" nm_Walk(2, RightKey) "
		send {" RotLeft " 2}
		)"

	case 4:
		paths["dandelion"] := "
		(LTrim Join`r`n
		" nm_Walk(8.3, LeftKey) "
		" nm_Walk(23, BackKey) "
		send {" RotLeft " 2}
		)"

	case 5:
		paths["dandelion"] := "
		(LTrim Join`r`n
		" nm_Walk(23, BackKey) "
		send {" RotLeft " 2}
		)"

	case 6:
		paths["dandelion"] := "
		(LTrim Join`r`n
		" nm_Walk(4, RightKey) "
		" nm_Walk(23, BackKey) "
		" nm_Walk(4, RightKey) "
		send {" RotLeft " 2} 
		)"

	default:
		paths["dandelion"] := "
		(LTrim Join`r`n
		;gotoramp
		" nm_Walk(40, BackKey, LeftKey) "
		" nm_Walk(10, LeftKey) "
		send {" RotLeft " 2}
		)"
}