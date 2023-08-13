patterns["lines"] := "
(LTrim Join`r`n
loop " reps " {
	send {" TCFBKey " down}
	Walk(" 11 * size ")
	send {" TCLRKey " down}
	send {" TCFBKey " up}
	Walk(" 1 ")
	send {" AFCFBKey " down}
	send {" TCLRKey " up}
	Walk(" 11 * size ")
	send {" TCLRKey " down}
	send {" AFCFBKey " up}
	Walk(" 1 ")
	send {" TCLRKey " up}
}
;away from center
loop " reps " {
	send {" TCFBKey " down}
	Walk(" 11 * size ")
	send {" AFCLRKey " down}
	send {" TCFBKey " up}
	Walk(" 1 ")
	send {" AFCFBKey " down}
	send {" AFCLRKey " up}
	Walk(" 11 * size ")
	send {" AFCLRKey " down}
	send {" AFCFBKey " up}
	Walk(" 1 ")
	send {" AFCLRKey " up}
}
)"