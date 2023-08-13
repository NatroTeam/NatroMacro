patterns["diamonds"] := "
(LTrim Join`r`n
loop " reps " {
	send {" TCFBKey " down}
	send {" TCLRKey " down}
	Walk(" 5 * size " + A_Index)
	send {" TCLRKey " up}
	send {" AFCLRKey " down}
	Walk(" 5 * size " + A_Index)
	send {" TCFBKey " up}
	send {" AFCFBKey " down}
	Walk(" 5 * size " + A_Index)
	send {" AFCLRKey " up}
	send {" TCLRKey " down}
	Walk(" 5 * size " + A_Index)
	send {" TCLRKey " up}
	send {" AFCFBKey " up}
}
)"