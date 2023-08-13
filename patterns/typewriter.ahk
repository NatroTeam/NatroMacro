patterns["typewriter"] := "
(LTrim Join`r`n
spacingDelay:=274 ;183
send {" TCLRKey " down}
Walk(spacingDelay/222*(" reps "*2+1.25))
send {" AFCFBKey " down}
send {" TCLRKey " up}
Walk(" 5 * size ")
send {" AFCFBKey " up}
loop " reps " {
	send {" AFCLRKey " down}
	Walk(spacingDelay/222)
	send {" TCFBKey " down}
	send {" AFCLRKey " up}
	Walk(" 5 * size ")
	send {" AFCLRKey " down}
	send {" TCFBKey " up}
	Walk(spacingDelay/222)
	send {" AFCLRKey " up}
	send {" AFCFBKey " down}
	Walk((1094+25*" facingcorner ")/222*" size ")
	send {" AFCFBKey " up}
}
send {" TCLRKey " down}
Walk(spacingDelay/222*(" reps "*2+1))
send {" TCFBKey " down}
send {" TCLRKey " up}
Walk(" 5 * size ")
send {" TCFBKey " up}
loop " reps " {
	send {" AFCLRKey " down}
	Walk(spacingDelay/222)
	send {" AFCFBKey " down}
	send {" AFCLRKey " up}
	Walk((1094+25*" facingcorner ")/222*" size ")
	send {" AFCLRKey " down}
	send {" AFCFBKey " up}
	Walk(spacingDelay/222)
	send {" TCFBKey " down}
	send {" AFCLRKey " up}
	Walk(" 5 * size ")
	send {" TCFBKey " up}
}
)"