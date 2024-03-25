nm_Walk(20.25, RightKey)
send "{" Backkey " down}"
Walk(22.5)
send "{space down}"
HyperSleep(50)
send "{space up}"
Walk(31.5)
send "{" BackKey " up}"
nm_Walk(33.75, LeftKey)
nm_Walk(13.5, FwdKey)
nm_Walk(1.5, BackKey) ;walk backwards to avoid thicker hives
nm_Walk(10, RightKey) ;walk to ramp
nm_Walk(2.7, BackKey) ;center with hive pads

; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
