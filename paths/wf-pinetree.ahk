If ((HiveBees < 25) || (MoveMethod = "Walk")) {
	nm_Walk(31, FwdKey)
	nm_Walk(75, RightKey)
	send "{" RotLeft " 4}"
	Sleep(50)
	nm_Walk(20, FwdKey)
	nm_Walk(3, FwdKey, LeftKey)
	nm_Walk(18, FwdKey)
	nm_Walk(6, FwdKey, RightKey)
	nm_Walk(10, RightKey)
	nm_Walk(2, LeftKey)
	send "{" FwdKey " down}"
	Walk(6)
	send "{" SC_Space " down}"
	HyperSleep(200)
	send "{" SC_Space " up}"
	Walk(108)
	send "{" FwdKey " up}"

	switch HiveSlot
		{
		case 3:
		nm_Walk(2.7, BackKey) ;center on hive pad 3

		default:
		nm_Walk(1.5, BackKey) ;walk backwards to avoid thicker hives
		nm_Walk(35, RightKey) ;walk to ramp
		nm_Walk(2.7, BackKey) ;center with hive pads
		}
	}
else {
	nm_Walk(30, FwdKey)
	nm_Walk(25, LeftKey)
	nm_Walk(2, FwdKey)
	nm_Walk(30, BackKey)
	nm_Walk(23, BackKey, RightKey)
	nm_Walk(3, BackKey)
	nm_Walk(5, RightKey)
	nm_Walk(13, BackKey)
	send "{" SC_Space " down}"
	nm_Walk(5, BackKey)
	HyperSleep(200)
	send "{" SC_Space " up}"
	nm_Walk(3.5, RightKey)
	nm_Walk(5, FwdKey)
	nm_Walk(7, BackKey)

	; cannon
	SetKeyDelay 150+A_KeyDelay
	send "{" SC_LShift "}"
	loop 4
		send("{" RotRight "}"), Sleep(50)
	SetKeyDelay A_KeyDelay
	sleep(100)
	send("{" SC_E " down}"), HyperSleep(10)
	send("{" SC_E " up}"), HyperSleep(10)

	; glider
	loop 2
		send("{" SC_Space " down}"), HyperSleep(200), send("{" SC_Space " up}"), HyperSleep(200)
	Sleep(3800)
	send("{" SC_Space " down}"), hypersleep(100)
	send("{" SC_Space " up}"), sleep(500)

	send "{" SC_LShift "}"
	; hive
	nm_Walk(3.3, BackKey)
	nm_Walk(35, RightKey)
	nm_Walk(5, FwdKey)
	nm_Walk(4, BackKey)
}

;added MoveMethod condition to no-glider option misc 181123
;slightly altered tile measurements and optimised glider deployment SP 230405
;path with and without glider zaappiix 230212
; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update - deleted on new path
; [2024-01-15/rpertusio] Aligns with default SpawnLocation, saves walking if player chose Hive 3 - deleted on new path

; fast cannon path by Lorddrak
; ty dully for keydelay idea