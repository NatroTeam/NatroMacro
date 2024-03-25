loop reps {
	send "{" TCLRKey " down}" ; Left 1.5
	Walk(1.25 * size)
	send "{" TCLRKey " up}{" TCFBKey " down}" ;Left forward 78
	Walk(7 * size, 10)
	send "{" TCFBKey " up}{" TCLRKey " down}" ; Forward Left 1.5
	Walk(1.25 * size)
	send "{" TCLRKey " up}{" AFCFBKey " down}" ;Left Back 6.66
	Walk(6.66 * size, 10)
	send "{" AFCFBKey " up}{" TCLRKey " down}" ;Back Left 1.5
	Walk(1.25 * size)
	send "{" TCLRKey " up}{" TCFBKey " down}" ;Left forward 78
	Walk(7 * size, 10)
	send "{" TCFBKey " up}{" TCLRKey " down}" ; Forward Left 1.5
	Walk(2 * size)
	send "{" TCLRKey " up}{" AFCFBKey " down}" ;Left Back 6.66
	Walk(6.5 * size, 10)
	send "{" AFCFBKey " up}"
}
loop reps {
	send "{" AFCLRKey " down}" ; Right 1.5
	Walk(1.25 * size)
	send "{" AFCLRKey " up}{" TCFBKey " down}" ; Right Forward 7
	Walk(7 * size, 10)
	send "{" TCFBKey " up}{" AFCLRKey " down}" ; Forward Right 1.5
	Walk(1 * size)
	send "{" AFCLRKey " up}{" AFCFBKey " down}" ;Right Back 6.66
	Walk(6.66 * size, 10)
	send "{" AFCFBKey " up}{" AFCLRKey " down}" ;Back Right 1.5
	Walk(1.25 * size)
	send "{" AFCLRKey " up}{" TCFBKey " down}" ; Right Forward 6.66
	Walk(7 * size, 10)
	send "{" TCFBKey " up}{" AFCLRKey " down}" ; Forward Right 1.5
	Walk(1.25 * size)
	send "{" AFCLRKey " up}{" AFCFBKey " down}" ;Right Back 6.66
	Walk(6.5 * size, 10)
	send "{" AFCFBKey " up}"
}
