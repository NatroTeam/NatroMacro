loop reps {
	send "{" TCFBKey " down}{" TCLRKey " down}"
	Walk(5 * size + A_Index)
	send "{" TCLRKey " up}{" AFCLRKey " down}"
	Walk(5 * size + A_Index)
	send "{" TCFBKey " up}{" AFCFBKey " down}"
	Walk(5 * size + A_Index)
	send "{" AFCLRKey " up}{" TCLRKey " down}"
	Walk(5 * size + A_Index)
	send "{" TCLRKey " up}{" AFCFBKey " up}"
}
