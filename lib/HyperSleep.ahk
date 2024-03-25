HyperSleep(ms)
{
	static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
	DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
	current := 0, finish := begin + ms * freq / 1000
	while (current < finish)
	{
		if ((finish - current) > 30000)
		{
			DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
			DllCall("Sleep", "UInt", 1)
			DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
		}
		DllCall("QueryPerformanceCounter", "Int64*", &current)
	}
}