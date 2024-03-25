spacingDelay:=274 ;183
send "{" TCLRKey " down}"
Walk(spacingDelay*9/2000*(reps*2+1))
send "{" TCLRKey " up}{" AFCFBKey " down}"
Walk(5 * size)
send "{" AFCFBKey " up}"
loop reps {
	send "{" AFCLRKey " down}"
	Walk(spacingDelay*9/2000)
	send "{" AFCLRKey " up}{" TCFBKey " down}"
	Walk(5 * size)
	send "{" TCFBKey " up}{" AFCLRKey " down}"
	Walk(spacingDelay*9/2000)
	send "{" AFCLRKey " up}{" AFCFBKey " down}"
	Walk((1094+25*facingcorner)*9/2000*size)
	send "{" AFCFBKey " up}"
}
send "{" TCLRKey " down}"
Walk(spacingDelay*9/2000*(reps*2+0.5))
send "{" TCLRKey " up}{" TCFBKey " down}"
Walk(5 * size)
send "{" TCFBKey " up}"
loop reps {
	send "{" AFCLRKey " down}"
	Walk(spacingDelay*9/2000)
	send "{" AFCLRKey " up}{" AFCFBKey " down}"
	Walk((1094+25*facingcorner)*9/2000*size)
	send "{" AFCFBKey " up}{" AFCLRKey " down}"
	Walk(spacingDelay*9/2000*1.5)
	send "{" AFCLRKey " up}{" TCFBKey " down}"
	Walk(5 * size)
	send "{" TCFBKey " up}"
}
