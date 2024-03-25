loop reps {
	send "{" TCFBKey " down}"
	Walk(11 * size)
	send "{" TCFBKey " up}{" TCLRKey " down}"
	Walk(1)
	send "{" TCLRKey " up}{" AFCFBKey " down}"
	Walk(11 * size)
	send "{" AFCFBKey " up}{" TCLRKey " down}"
	Walk(1)
	send "{" TCLRKey " up}"
}
;away from center
loop reps {
	send "{" TCFBKey " down}"
	Walk(11 * size)
	send "{" TCFBKey " up}{" AFCLRKey " down}"
	Walk(1)
	send "{" AFCLRKey " up}{" AFCFBKey " down}"
	Walk(11 * size)
	send "{" AFCFBKey " up}{" AFCLRKey " down}"
	Walk(1)
	send "{" AFCLRKey " up}"
}
