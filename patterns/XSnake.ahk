loop reps {
	send "{" TCLRKey " down}"
	Walk(4 * size)
	send "{" TCLRKey " up}{" TCFBKey " down}"
	Walk(2 * size)
	send "{" TCFBKey " up}{" AFCLRKey " down}"
	Walk(8 * size)
	send "{" AFCLRKey " up}{" TCFBKey " down}"
	Walk(2 * size)
	send "{" TCFBKey " up}{" TCLRKey " down}"
	Walk(8 * size)
	send "{" TCLRKey " up}{" AFCLRKey " down}{" AFCFBKey " down}"
	Walk(Sqrt( ( ( 8 * size ) ** 2 ) + ( ( 8 * size ) ** 2 )))
	send "{" AFCLRKey " up}{" AFCFBKey " up}{" TCLRKey " down}"
	Walk(8 * size)
	send "{" TCLRKey " up}{" TCFBKey " down}"
	Walk(2 * size)
	send "{" TCFBKey " up}{" AFCLRKey " down}"
	Walk(8 * size)
	send "{" AFCLRKey " up}{" TCFBKey " down}"
	Walk(6.7 * size)
	send "{" TCFBKey " up}{" TCLRKey " down}"
	Walk(8 * size)
	send "{" TCLRKey " up}{" AFCFBKey " down}"
	Walk(2 * size)		
	send "{" AFCFBKey " up}{" AFCLRKey " down}"
	Walk(8 * size)
	send "{" AFCLRKey " up}{" AFCFBKey " down}"
	Walk(2 * size)		
	send "{" AFCFBKey " up}{" TCLRKey " down}"
	Walk(8 * size)
	send "{" TCLRKey " up}{" AFCFBKey " down}"
	Walk(2 * size)		
	send "{" AFCFBKey " up}{" AFCLRKey " down}"
	Walk(8 * size)
	send "{" AFCLRKey " up}{" AFCFBKey " down}"
	Walk(3 * size)		
	send "{" AFCFBKey " up}{" TCLRKey " down}"
	Walk(8 * size)
	send "{" TCLRKey " up}{" TCFBKey " down}{" AFCLRKey " down}"
	Walk(Sqrt( ( ( 4 * size ) ** 2 ) + ( ( 4 * size ) ** 2 )))
	send "{" TCFBKey " up}{" AFCLRKey " up}"
}