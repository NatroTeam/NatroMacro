#NoEnv
#SingleInstance force
#MaxThreads 255
#Include %A_ScriptDir%\..\lib\Gdip_All.ahk
OnMessage(0x5554, "nm_setStatus", 255)

;initialization
Critical, On
SetWorkingDir %A_ScriptDir%
IniRead, Webhook, ..\settings\nm_config.ini, Status, Webhook
IniRead, WebhookCheck, ..\settings\nm_config.ini, Status, WebhookCheck
IniRead, ssCheck, ..\settings\nm_config.ini, Status, ssCheck
IniRead, discordUID, ..\settings\nm_config.ini, Status, discordUID
IniRead, ssDebugging, ..\settings\nm_config.ini, Status, ssDebugging
IniRead, WebhookEasterEgg, ..\settings\nm_config.ini, Status, WebhookEasterEgg
FileRead, log, ..\settings\status_log.txt
statuslog := StrSplit(log, "`r`n")
pToken := Gdip_Startup()
Critical, Off
SetBatchLines -1

nm_status(stateString)
{
	global statuslog
	state := SubStr(stateString, 1, InStr(stateString, ": ")-1), objective := SubStr(stateString, InStr(stateString, ": ")+2)
	
	;manage status_log
	statuslog.Push("[" A_Hour ":" A_Min ":" A_Sec "] " stateString)
	statuslog.RemoveAt(1,(statuslog.MaxIndex()>20) ? statuslog.MaxIndex()-20 : 0)
	statuslogtext:=""
	for k,v in statuslog
		statuslogtext .= ((A_Index>1) ? "`r`n" : "") v
		
    FileDelete, ..\settings\status_log.txt
	FileAppend, %statuslogtext%, ..\settings\status_log.txt
	FileAppend `[%A_MM%/%A_DD%`]`[%A_Hour%:%A_Min%:%A_Sec%`] %stateString%`n, ..\settings\debug_log.txt
    
	;;;;;;;;
	;webhook
	;;;;;;;;
	global webhook, webhookCheck, ssCheck, discordUID, ssDebugging, WebhookEasterEgg
	static lastCritical:=0, colorIndex:= 0
	
	if (WebhookCheck && RegExMatch(webhook, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$")) {
		; set colour based on state string
		if WebhookEasterEgg
		{
			color := (colorIndex = 0) ? 16711680 ; red
			: (colorIndex = 1) ? 16744192 ; orange
			: (colorIndex = 2) ? 16776960 ; yellow
			: (colorIndex = 3) ? 65280 ; green
			: (colorIndex = 4) ? 255 ; blue
			: (colorIndex = 5) ? 4915330 ; indigo
			: 9699539 ; violet
			colorIndex := Mod(colorIndex+1, 7)
		}
		else
		{
			color := ((state = "Disconnected") || (state = "You Died") || (state = "Failed") || (state = "Error") || (state = "Aborting") || (state = "Missing") || InStr(objective, "Phantom")) ? 15085139 ; red - error
			: (InStr(objective, "Tunnel Bear") || InStr(objective, "King Beetle") || InStr(objective, "Vicious Bee") || InStr(objective, "Snail") || InStr(objective, "Crab") || InStr(objective, "Mondo") || InStr(objective, "Commando")) ? 7036559 ; purple - boss / attacking
			: (InStr(objective, "Planter") || (state = "Placing") || (state = "Collecting")) ? 48355 ; blue - planters
			: ((state = "Interupted")) ? 14408468 ; yellow - alert
			: ((state = "Gathering")) ? 9755247 ; light green - gathering
			: ((state = "Converting")) ? 8871681 ; yellow-brown - converting
			: ((state = "Boosted") || (state = "Looting") || (state = "Claimed") || (state = "Completed") || (state = "Collected") || InStr(stateString,"confirmed") || InStr(stateString,"found")) ? 48128 ; green - success
			: ((state = "Starting")) ? 16366336 ; orange - quests
			: ((state = "Startup") || (state = "GUI") || (state = "Detected") || (state = "Closing") || (state = "Begin") || (state = "End")) ? 15658739 ; white - startup / utility
			: 3223350
		}

		; check if event needs screenshot
		critical_event := ((state = "Error") || ((nowUnix() - lastCritical > 300) && ((state = "Disconnected") || (InStr(stateString, "Resetting: Character") && (SubStr(objective, InStr(objective, " ")+1) > 2)) || InStr(stateString, "Phantom")))) ? 1 : 0
		if critical_event
			lastCritical := nowUnix()
		content := (discordUID && critical_event) ? "<@" discordUID ">" : ""
		debug_event := (ssDebugging && ((state = "Placing") || (state = "Collecting") || (state = "Failed"))) ? 1 : 0
		ss_event := InStr(stateString, "Amulet") ? 1 : 0
		
		; create postdata and send to discord
		message := "[" A_Hour ":" A_Min ":" A_Sec "] " StrReplace(StrReplace(StrReplace(StrReplace(stateString, "\", "\\"), "`n", "\n"), Chr(9), "  "), "`r", "")
		if ((critical_event && ssCheck) || debug_event || ss_event)
		{
			SysGet, pmonN, MonitorPrimary
			pBM := Gdip_BitmapFromScreen(pmonN)
			Gdip_SaveBitmapToFile(pBM, "ss.png")
			Gdip_DisposeImage(pBM)
			
			path := "ss.png"
			
			payload_json =
			(
			{
				"content": "%content%",
				"embeds": [{
					"description": "%message%",
					"color": "%color%",
					"image": {"url": "attachment://ss.png"}
				}]
			}
			)
			
			try
			{
				objParam := {payload_json: payload_json, file: [path]}
				CreateFormData(postdata, hdr_ContentType, objParam)
				
				wr := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
				wr.Option(9) := 2048
				wr.Open("POST", webhook)
				wr.SetRequestHeader("User-Agent", "AHK")
				wr.SetRequestHeader("Content-Type", hdr_ContentType)
				wr.Send(postdata)
			}
			
			FileDelete, ss.png
		}
		else
		{
			postdata =
			(
			{
				"content": "%content%",
				"embeds": [{
					"description": "%message%",
					"color": "%color%"
				}]
			}
			)
		
			; post to webhook
			try
			{
				wr := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
				wr.Option(9) := 2048
				wr.Open("POST", webhook)
				wr.SetRequestHeader("User-Agent", "AHK")
				wr.SetRequestHeader("Content-Type", "application/json")
				wr.Send(postdata)
			}
		}
	}
}

nm_setStatus() {
	Critical
    ControlGetText, stateString, static4, Natro Macro
	stateString ? nm_status(stateString)
	return 0
}

nowUnix(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}

; CreateFormData() by tmplinshi modified by SKAN
; for sending images to webhook
CreateFormData(ByRef retData, ByRef retHeader, objParam) {
	New CreateFormData(retData, retHeader, objParam)
}
Class CreateFormData {

	__New(ByRef retData, ByRef retHeader, objParam) {

		Local CRLF := "`r`n", i, k, v, str, pvData
		; Create a random Boundary
		Local Boundary := this.RandomBoundary()
		Local BoundaryLine := "------------------------------" . Boundary

    this.Len := 0 ; GMEM_ZEROINIT|GMEM_FIXED = 0x40
    this.Ptr := DllCall( "GlobalAlloc", "UInt",0x40, "UInt",1, "Ptr"  )          ; allocate global memory

		; Loop input paramters
		For k, v in objParam
		{
			If IsObject(v) {
				For i, FileName in v
				{
					str := BoundaryLine . CRLF
					     . "Content-Disposition: form-data; name=""" . k . """; filename=""" . FileName . """" . CRLF
					     . "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF
          this.StrPutUTF8( str )
          this.LoadFromFile( Filename )
          this.StrPutUTF8( CRLF )
				}
			} Else {
				str := BoundaryLine . CRLF
				     . "Content-Disposition: form-data; name=""" . k """" . CRLF . CRLF
				     . v . CRLF
        this.StrPutUTF8( str )
			}
		}

		this.StrPutUTF8( BoundaryLine . "--" . CRLF )

    ; Create a bytearray and copy data in to it.
    retData := ComObjArray( 0x11, this.Len ) ; Create SAFEARRAY = VT_ARRAY|VT_UI1
    pvData  := NumGet( ComObjValue( retData ) + 8 + A_PtrSize )
    DllCall( "RtlMoveMemory", "Ptr",pvData, "Ptr",this.Ptr, "Ptr",this.Len )

    this.Ptr := DllCall( "GlobalFree", "Ptr",this.Ptr, "Ptr" )                   ; free global memory 

    retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
	}

  StrPutUTF8( str ) {
    Local ReqSz := StrPut( str, "utf-8" ) - 1
    this.Len += ReqSz                                  ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42
    this.Ptr := DllCall( "GlobalReAlloc", "Ptr",this.Ptr, "UInt",this.len + 1, "UInt", 0x42 )   
    StrPut( str, this.Ptr + this.len - ReqSz, ReqSz, "utf-8" )
  }
  
  LoadFromFile( Filename ) {
    Local objFile := FileOpen( FileName, "r" )
    this.Len += objFile.Length                     ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42 
    this.Ptr := DllCall( "GlobalReAlloc", "Ptr",this.Ptr, "UInt",this.len, "UInt", 0x42 )
    objFile.RawRead( this.Ptr + this.Len - objFile.length, objFile.length )
    objFile.Close()       
  }

	RandomBoundary() {
		str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		Sort, str, D| Random
		str := StrReplace(str, "|")
		Return SubStr(str, 1, 12)
	}

	MimeType(FileName) {
		n := FileOpen(FileName, "r").ReadUInt()
		Return (n        = 0x474E5089) ? "image/png"
		     : (n        = 0x38464947) ? "image/gif"
		     : (n&0xFFFF = 0x4D42    ) ? "image/bmp"
		     : (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
		     : (n&0xFFFF = 0x4949    ) ? "image/tiff"
		     : (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
		     : "application/octet-stream"
	}

}