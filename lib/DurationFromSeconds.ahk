/*****************************************************************************************
* @description: Simple GetDurationFormatEx parser
* https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-getdurationformatex
* @author SP
*****************************************************************************************/

DurationFromSeconds(secs, format:="hh:mm:ss", capacity:=64)
{
	dur := Buffer(capacity), DllCall("GetDurationFormatEx"
		, "Ptr", 0
		, "UInt", 0
		, "Ptr", 0
		, "Int64", secs*10000000
		, "Str", format
		, "Ptr", dur.Ptr
		, "Int", 32)
    return StrGet(dur)
}
hmsFromSeconds(secs) => DurationFromSeconds(secs, ((secs >= 3600) ? "h'h' m" : "") ((secs >= 60) ? "m'm' s" : "") "s's'")
