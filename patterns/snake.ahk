patterns["snake"] := "
(LTrim Join`r`n
loop " reps " {
	send {" TCLRKey " down}
	Walk(" 11 * size ")
	send {" TCFBKey " down}
	send {" TCLRKey " up}
	Walk(" 1 ")
	send {" AFCLRKey " down}
	send {" TCFBKey " up}
	Walk(" 11 * size ")
	send {" TCFBKey " down}
	send {" AFCLRKey " up}
	Walk(" 1 ")
	send {" TCFBKey " up}
}
;away from center
loop " reps " {
	send {" TCLRKey " down}
	Walk(" 11 * size ")
	send {" AFCFBKey " down}
	send {" TCLRKey " up}
	Walk(" 1 ")
	send {" AFCLRKey " down}
	send {" AFCFBKey " up}
	Walk(" 11 * size ")
	send {" AFCFBKey " down}
	send {" AFCLRKey " up}
	Walk(" 1 ")
	send {" AFCFBKey " up}
}
)"