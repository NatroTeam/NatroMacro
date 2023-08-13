paths["pine tree"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
hypersleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
hypersleep(850)
send {space 2}
hypersleep(7500)
send {" RightKey " up}{" BackKey " up}
" nm_walk(16, FwdKey) "
" nm_walk(4, LeftKey) "
send {" RotRight " 2}
)"