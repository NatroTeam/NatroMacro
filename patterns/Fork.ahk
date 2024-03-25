CForkGap:=0.75 ;flowers between lines
CForkDiagonal := CForkGap*sqrt(2)
CForkLength := (40-CForkGap*16-CForkDiagonal*4)/6
if(facingcorner) {
	send "{" FwdKey " down}"
	Walk(1.5, 10)
	send "{" FwdKey " up}"
}
send "{" TCLRKey " down}{" AFCFBKey " down}"
Walk(CForkDiagonal*2)
send "{" AFCFBKey " up}"
Walk(((reps-1)*4+2)*CForkGap)
send "{" TCFBKey " down}"
Walk(CForkDiagonal*2)
send "{" TCLRKey " up}"
loop reps {
	Walk(CForkLength * size, 99)
	send "{" TCFBKey " up}{" AFCLRKey " down}"
	Walk(CForkGap*2)
	send "{" AFCLRKey " up}{" AFCFBKey " down}"
	Walk(CForkLength * size, 99)
	send "{" AFCFBKey " up}{" AFCLRKey " down}"
	Walk(CForkGap*2)
	send "{" AFCLRKey " up}{" TCFBKey " down}"
}
Walk(CForkLength * size, 99)
send "{" TCFBKey " up}{" AFCLRKey " down}"
Walk(CForkGap*2)
send "{" AFCLRKey " up}{" AFCFBKey " down}"
Walk(CForkLength * size, 99)
send "{" AFCFBKey " up}"
