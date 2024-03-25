loop reps {
	send "{" TCLRKey " down}"
	Walk(11 * size)
	send "{" TCLRKey " up}{" TCFBKey " down}"
	Walk(1)
	send "{" TCFBKey " up}{" AFCLRKey " down}"
	Walk(11 * size)
	send "{" AFCLRKey " up}{" TCFBKey " down}"
	Walk(1)
	send "{" TCFBKey " up}"
}
;away from center
loop reps {
	send "{" TCLRKey " down}"
	Walk(11 * size)
	send "{" TCLRKey " up}{" AFCFBKey " down}"
	Walk(1)
	send "{" AFCFBKey " up}{" AFCLRKey " down}"
	Walk(11 * size)
	send "{" AFCLRKey " up}{" AFCFBKey " down}"
	Walk(1)
	send "{" AFCFBKey " up}"
}
