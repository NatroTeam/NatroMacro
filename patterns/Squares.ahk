loop reps {
	send "{" TCFBKey " down}"
	Walk(5 * size + A_Index)
	send "{" TCFBKey " up}{" TCLRKey " down}"
	Walk(5 * size + A_Index)
	send "{" TCLRKey " up}{" AFCFBKey " down}"
	Walk(5 * size + A_Index)
	send "{" AFCFBKey " up}{" AFCLRKey " down}"
	Walk(5 * size + A_Index)
	send "{" AFCLRKey " up}"
}
