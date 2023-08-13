patterns["squares"] := "
(LTrim Join`r`n
loop " reps " {
	send {" TCFBKey " down}
	Walk(" 5 * size " + A_Index)
	send {" TCLRKey " down}
	send {" TCFBKey " up}
	Walk(" 5 * size " + A_Index)
	send {" AFCFBKey " down}
	send {" TCLRKey " up}
	Walk(" 5 * size " + A_Index)
	send {" AFCLRKey " down}
	send {" AFCFBKey " up}
	Walk(" 5 * size " + A_Index)
	send {" AFCLRKey " up}
}
)"