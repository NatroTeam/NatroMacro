/********************************************
* @Author SP
* @Description Class to interact with Discord
*********************************************/


class discord
{
	static baseURL := "https://discord.com/api/v10/"

	static SendEmbed(message, color:=3223350, content:="", pBitmap:=0, channel:="", replyID:=0)
	{
		payload_json :=
		(
		'
		{
			"content": "' content '",
			"embeds": [{
				"description": "' message '",
				"color": "' color '"
				' (pBitmap ? (',"image": {"url": "attachment://ss.png"}') : '') '
			}]
			' (replyID ? (',"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}') : '') '
		}
		'
		)

		if pBitmap
			this.CreateFormData(&postdata, &contentType, [Map("name","payload_json","content-type","application/json","content",payload_json), Map("name","files[0]","filename","ss.png","content-type","image/png","pBitmap",pBitmap)])
		else
			postdata := payload_json, contentType := "application/json"

		return this.SendMessageAPI(postdata, contentType, channel)
	}

	static SendFile(filepath, replyID:=0)
	{
		static MimeTypes := Map("PNG", "image/png"
			, "JPEG", "image/jpeg"
			, "JPG", "image/jpeg"
			, "BMP", "image/bmp"
			, "GIF", "image/gif"
			, "WEBP", "image/webp"
			, "TXT", "text/plain"
			, "INI", "text/plain")

		if (attr := FileExist(filepath))
		{
			SplitPath filepath := RTrim(filepath, "\/"), &file:=""
			if (file && InStr(attr, "D"))
			{
				; attempt to zip folder to temp
				try
				{
					RunWait 'powershell.exe -WindowStyle Hidden -Command Compress-Archive -Path "' filepath '\*" -DestinationPath "$env:TEMP\' file '.zip" -CompressionLevel Fastest -Force', , "Hide"
					if !FileExist(filepath := A_Temp "\" file ".zip")
						throw
				}
				catch
				{
					this.SendEmbed('The folder ``' StrReplace(StrReplace(filepath, "\", "\\"), '"', '\"') '`` could not be zipped!`nThis function is only supported on Windows 10 or higher.', 16711731, , , , replyID)
					return -3
				}
			}
			size := FileGetSize(filepath)
			if (size > 10485760)
			{
				this.SendEmbed('``' StrReplace(StrReplace(filepath, "\", "\\"), '"', '\"') '`` is above the Discord file size limit of 10MiB!', 16711731, , , , replyID)
				return -1
			}
		}
		else
		{
			this.SendEmbed('``' StrReplace(StrReplace(filepath, "\", "\\"), '"', '\"') '`` does not exist or could not be read!', 16711731, , , , replyID)
			return -2
		}

		SplitPath filepath, &file, , &ext
		ext := StrUpper(ext)
		params := []
		(replyID > 0) && params.Push(Map("name","payload_json","content-type","application/json","content",'{"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}}'))
		params.Push(Map("name","files[0]","filename",file,"content-type",MimeTypes.Has(ext) ? MimeTypes[ext] : "application/octet-stream","file",filepath))
		this.CreateFormData(&postdata, &contentType, params)
		this.SendMessageAPI(postdata, contentType)

		; delete any temp file created
		if (SubStr(filepath, 1, StrLen(A_Temp)) = A_Temp)
			try FileDelete filepath
	}

	static SendImage(pBitmap, imgname:="image.png", replyID:=0)
	{
		params := []
		(replyID > 0) && params.Push(Map("name","payload_json","content-type","application/json","content",'{"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}}'))
		params.Push(Map("name","files[0]","filename",imgname,"content-type","image/png","pBitmap",pBitmap))
		this.CreateFormData(&postdata, &contentType, params)
		this.SendMessageAPI(postdata, contentType)
	}

	static SendMessageAPI(postdata, contentType:="application/json", channel:="", url:="")
	{
		global webhook, bottoken, discordMode, MainChannelCheck, MainChannelID

		if (!channel && (discordMode = 1))
		{
			if (MainChannelCheck = 1)
				channel := MainChannelID
			else
				return -2
		}

		if !url
			url := (discordMode = 0) ? (webhook "?wait=true") : (this.BaseURL "/channels/" channel "/messages")

		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("POST", url, 1)
			if (discordMode = 1)
			{
				wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
				wr.SetRequestHeader("Authorization", "Bot " bottoken)
			}
			wr.SetRequestHeader("Content-Type", contentType)
			wr.SetTimeouts(0, 60000, 120000, 30000)
			wr.Send(postdata)
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static GetCommands(channel)
	{
		global discordMode, commandPrefix

		if (discordMode = 0)
			return -1

		Loop (n := (messages := this.GetRecentMessages(channel)).Length)
		{
			i := n - A_Index + 1
			(SubStr(content := Trim(messages[i]["content"]), 1, StrLen(commandPrefix)) = commandPrefix) && command_buffer.Push({content:content, id:messages[i]["id"], url:messages[i]["attachments"].Has(1) ? messages[i]["attachments"][1]["url"] : "", user_id: messages[i]["author"]["id"]})
		}
	}

	static GetChannel(channelid)
	{
		global discordMode
		if (discordMode == 0)
			return -1

		wr := ComObject("WinHttp.WinHttpRequest.5.1")
		wr.Option[9] := 2720
		wr.Open("GET", Discord.baseURL . "channels/" channelid)
		wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
		wr.SetRequestHeader("Authorization", "Bot " . bottoken)
		wr.Send()
		wr.WaitForResponse()
		return wr.ResponseText
	}

	static GetMember(guild_id, user_id)
	{
		global discordMode
		if (discordMode == 0)
			return -1

		wr := ComObject("WinHttp.WinHttpRequest.5.1")
		wr.Option[9] := 2720
		wr.Open("GET", Discord.baseURL . "guilds/" . guild_id . "/members/" . user_id)
		wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
		wr.SetRequestHeader("Authorization", "Bot " . bottoken)
		wr.Send()
		wr.WaitForResponse()
		return wr.ResponseText
	}


	static GetRecentMessages(channel)
	{
		global discordMode
		static lastmsg := Map()

		if (discordMode = 0)
			return -1

		try
			(messages := JSON.parse(this.GetMessageAPI(lastmsg.Has(channel) ? ("?after=" lastmsg[channel]) : "?limit=1", channel))).Length
		catch
			return []

		if (messages.Has(1))
			lastmsg[channel] := messages[1]["id"]

		return messages
	}

	static GetMessageAPI(params:="", channel:="")
	{
		global bottoken, discordMode, MainChannelCheck, MainChannelID

		if (discordMode = 0)
			return -1

		if !channel
		{
			if (MainChannelCheck = 1)
				channel := MainChannelID
			else
				return -2
		}

		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("GET", this.BaseURL "/channels/" channel "/messages" params, 1)
			wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
			wr.SetRequestHeader("Authorization", "Bot " bottoken)
			wr.SetRequestHeader("Content-Type", "application/json")
			wr.Send()
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static EditMessageAPI(id, postdata, contentType:="application/json", channel:="")
	{
		if (!channel && (discordMode = 1))
		{
			if (MainChannelCheck = 1)
				channel := MainChannelID
			else
				return -2
		}

		url := (discordMode = 0) ? (webhook "/messages/" id) : (this.BaseURL "/channels/" channel "/messages/" id)

		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("PATCH", url, 1)
			if (discordMode = 1)
			{
				wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
				wr.SetRequestHeader("Authorization", "Bot " bottoken)
			}
			wr.SetRequestHeader("Content-Type", contentType)
			wr.SetTimeouts(0, 60000, 120000, 30000)
			wr.Send(postdata)
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static CreateFormData(&retData, &contentType, fields)
	{
		static chars := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"

		chars := Sort(chars, "D| Random")
		boundary := SubStr(StrReplace(chars, "|"), 1, 12)
		hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream:=0, "UInt")

		for field in fields
		{
			str :=
			(
			'

			------------------------------' boundary '
			Content-Disposition: form-data; name="' field["name"] '"' (field.Has("filename") ? ('; filename="' field["filename"] '"') : "") '
			Content-Type: ' field["content-type"] '

			' (field.Has("content") ? (field["content"] "`r`n") : "")
			)

			utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
			DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")

			if field.Has("pBitmap")
			{
				try
				{
					pFileStream := Gdip_SaveBitmapToStream(field["pBitmap"])
					DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
					DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
					DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
					ObjRelease(pFileStream)
				}
			}

			if field.Has("file")
			{
				DllCall("shlwapi\SHCreateStreamOnFileEx", "WStr", field["file"], "Int", 0, "UInt", 0x80, "Int", 0, "Ptr", 0, "PtrP", &pFileStream:=0)
				DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
				DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
				ObjRelease(pFileStream)
			}
		}

		str :=
		(
		'

		------------------------------' boundary '--
		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")
		ObjRelease(pStream)

		pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
		size := DllCall("GlobalSize", "Ptr", pData, "UPtr")

		retData := ComObjArray(0x11, size)
		pvData := NumGet(ComObjValue(retData), 8 + A_PtrSize, "Ptr")
		DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)

		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("GlobalFree", "Ptr", hData, "Ptr")
		contentType := "multipart/form-data; boundary=----------------------------" boundary
	}
}
