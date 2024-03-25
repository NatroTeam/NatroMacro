; v1.61
; NOTE: Some functions have been modified/added!
; 		To see which functions these are, you can compare with the
;		original file at https://github.com/buliasz/AHKv2-Gdip
;
;#####################################################################################
;#####################################################################################
; STATUS ENUMERATION
; Return values for functions specified to have status enumerated return type
;#####################################################################################
;
; Ok =						= 0
; GenericError				= 1
; InvalidParameter			= 2
; OutOfMemory				= 3
; ObjectBusy				= 4
; InsufficientBuffer		= 5
; NotImplemented			= 6
; Win32Error				= 7
; WrongState				= 8
; Aborted					= 9
; FileNotFound				= 10
; ValueOverflow				= 11
; AccessDenied				= 12
; UnknownImageFormat		= 13
; FontFamilyNotFound		= 14
; FontStyleNotFound			= 15
; NotTrueTypeFont			= 16
; UnsupportedGdiplusVersion	= 17
; GdiplusNotInitialized		= 18
; PropertyNotFound			= 19
; PropertyNotSupported		= 20
; ProfileNotFound			= 21
;
;#####################################################################################
;#####################################################################################
; FUNCTIONS
;#####################################################################################
;
; UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
; BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
; StretchBlt(dDC, dx, dy, dw, dh, sDC, sx, sy, sw, sh, Raster:="")
; SetImage(hwnd, hBitmap)
; Gdip_BitmapFromScreen(Screen:=0, Raster:="")
; CreateRectF(&RectF, x, y, w, h)
; CreateSizeF(&SizeF, w, h)
; CreateDIBSection
;
;#####################################################################################

; Function:					UpdateLayeredWindow
; Description:				Updates a layered window with the handle to the DC of a gdi bitmap
;
; hwnd						Handle of the layered window to update
; hdc						Handle to the DC of the GDI bitmap to update the window with
; Layeredx					x position to place the window
; Layeredy					y position to place the window
; Layeredw					Width of the window
; Layeredh					Height of the window
; Alpha						Default = 255 : The transparency (0-255) to set the window transparency
;
; return					if the function succeeds, the return value is nonzero
;
; notes						if x or y omitted, then layered window will use its current coordinates
;							if w or h omitted then current width and height will be used

UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
{
	if ((x != "") && (y != "")) {
		pt := Buffer(8)
		NumPut("UInt", x, "UInt", y, pt)
	}

	if (w = "") || (h = "") {
		WinGetRect(hwnd,,, &w, &h)
	}

	return DllCall("UpdateLayeredWindow"
		, "UPtr", hwnd
		, "UPtr", 0
		, "UPtr", ((x = "") && (y = "")) ? 0 : pt.Ptr
		, "Int64*", w|h<<32
		, "UPtr", hdc
		, "Int64*", 0
		, "UInt", 0
		, "UInt*", Alpha<<16|1<<24
		, "UInt", 2)
}

;#####################################################################################

; Function				BitBlt
; Description			The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle
;						of pixels from the specified source device context into a destination device context.
;
; dDC					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of the area to copy
; dh					height of the area to copy
; sDC					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; Raster				raster operation code
;
; return				if the function succeeds, the return value is nonzero
;
; notes					if no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
;
; BLACKNESS				= 0x00000042
; NOTSRCERASE			= 0x001100A6
; NOTSRCCOPY			= 0x00330008
; SRCERASE				= 0x00440328
; DSTINVERT				= 0x00550009
; PATINVERT				= 0x005A0049
; SRCINVERT				= 0x00660046
; SRCAND				= 0x008800C6
; MERGEPAINT			= 0x00BB0226
; MERGECOPY				= 0x00C000CA
; SRCCOPY				= 0x00CC0020
; SRCPAINT				= 0x00EE0086
; PATCOPY				= 0x00F00021
; PATPAINT				= 0x00FB0A09
; WHITENESS				= 0x00FF0062
; CAPTUREBLT			= 0x40000000
; NOMIRRORBITMAP		= 0x80000000

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
{
	return DllCall("gdi32\BitBlt"
					, "UPtr", dDC
					, "Int", dx
					, "Int", dy
					, "Int", dw
					, "Int", dh
					, "UPtr", sDC
					, "Int", sx
					, "Int", sy
					, "UInt", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				StretchBlt
; Description			The StretchBlt function copies a bitmap from a source rectangle into a destination rectangle,
;						stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
;						The system stretches or compresses the bitmap according to the stretching mode currently set in the destination device context.
;
; ddc					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination rectangle
; dh					height of destination rectangle
; sdc					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Raster				raster operation code
;
; return				if the function succeeds, the return value is nonzero
;
; notes					if no raster operation is specified, then SRCCOPY is used. It uses the same raster operations as BitBlt

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster:="")
{
	return DllCall("gdi32\StretchBlt"
					, "UPtr", ddc
					, "Int", dx
					, "Int", dy
					, "Int", dw
					, "Int", dh
					, "UPtr", sdc
					, "Int", sx
					, "Int", sy
					, "Int", sw
					, "Int", sh
					, "UInt", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				SetStretchBltMode
; Description			The SetStretchBltMode function sets the bitmap stretching mode in the specified device context
;
; hdc					handle to the DC
; iStretchMode			The stretching mode, describing how the target will be stretched
;
; return				if the function succeeds, the return value is the previous stretching mode. If it fails it will return 0
;
; STRETCH_ANDSCANS 		= 0x01
; STRETCH_ORSCANS 		= 0x02
; STRETCH_DELETESCANS 	= 0x03
; STRETCH_HALFTONE 		= 0x04

SetStretchBltMode(hdc, iStretchMode:=4)
{
	return DllCall("gdi32\SetStretchBltMode"
					, "UPtr", hdc
					, "Int", iStretchMode)
}

;#####################################################################################

; Function				SetImage
; Description			Associates a new image with a static control
;
; hwnd					handle of the control to update
; hBitmap				a gdi bitmap to associate the static control with
;
; return				if the function succeeds, the return value is nonzero

SetImage(hwnd, hBitmap)
{
	_E := DllCall( "SendMessage", "UPtr", hwnd, "UInt", 0x172, "UInt", 0x0, "UPtr", hBitmap )
	DeleteObject(_E)
	return _E
}

;#####################################################################################

; Function				SetSysColorToControl
; Description			Sets a solid colour to a control
;
; hwnd					handle of the control to update
; SysColor				A system colour to set to the control
;
; return				if the function succeeds, the return value is zero
;
; notes					A control must have the 0xE style set to it so it is recognised as a bitmap
;						By default SysColor=15 is used which is COLOR_3DFACE. This is the standard background for a control
;
; COLOR_3DDKSHADOW				= 21
; COLOR_3DFACE					= 15
; COLOR_3DHIGHLIGHT				= 20
; COLOR_3DHILIGHT				= 20
; COLOR_3DLIGHT					= 22
; COLOR_3DSHADOW				= 16
; COLOR_ACTIVEBORDER			= 10
; COLOR_ACTIVECAPTION			= 2
; COLOR_APPWORKSPACE			= 12
; COLOR_BACKGROUND				= 1
; COLOR_BTNFACE					= 15
; COLOR_BTNHIGHLIGHT			= 20
; COLOR_BTNHILIGHT				= 20
; COLOR_BTNSHADOW				= 16
; COLOR_BTNTEXT					= 18
; COLOR_CAPTIONTEXT				= 9
; COLOR_DESKTOP					= 1
; COLOR_GRADIENTACTIVECAPTION	= 27
; COLOR_GRADIENTINACTIVECAPTION	= 28
; COLOR_GRAYTEXT				= 17
; COLOR_HIGHLIGHT				= 13
; COLOR_HIGHLIGHTTEXT			= 14
; COLOR_HOTLIGHT				= 26
; COLOR_INACTIVEBORDER			= 11
; COLOR_INACTIVECAPTION			= 3
; COLOR_INACTIVECAPTIONTEXT		= 19
; COLOR_INFOBK					= 24
; COLOR_INFOTEXT				= 23
; COLOR_MENU					= 4
; COLOR_MENUHILIGHT				= 29
; COLOR_MENUBAR					= 30
; COLOR_MENUTEXT				= 7
; COLOR_SCROLLBAR				= 0
; COLOR_WINDOW					= 5
; COLOR_WINDOWFRAME				= 6
; COLOR_WINDOWTEXT				= 8

SetSysColorToControl(hwnd, SysColor:=15)
{
	WinGetRect(hwnd,,, &w, &h)
	bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
	pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
	pBitmap := Gdip_CreateBitmap(w, h), G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	Gdip_DeleteBrush(pBrushClear)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	return 0
}

;#####################################################################################

; Function				Gdip_BitmapFromScreen
; Description			Gets a gdi+ bitmap from the screen
;
; Screen				0 = All screens
;						Any numerical value = Just that screen
;						x|y|w|h = Take specific coordinates with a width and height
; Raster				raster operation code
;
; return					if the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1:		one or more of x,y,w,h not passed properly
;
; notes					if no raster operation is specified, then SRCCOPY is used to the returned bitmap

Gdip_BitmapFromScreen(Screen:=0, Raster:="")
{
	hhdc := 0
	if (Screen = 0) {
		_x := DllCall( "GetSystemMetrics", "Int", 76 )
		_y := DllCall( "GetSystemMetrics", "Int", 77 )
		_w := DllCall( "GetSystemMetrics", "Int", 78 )
		_h := DllCall( "GetSystemMetrics", "Int", 79 )
	}
	else if (SubStr(Screen, 1, 5) = "hwnd:") {
		Screen := SubStr(Screen, 6)
		if !WinExist("ahk_id " Screen) {
			return -2
		}
		WinGetRect(Screen,,, &_w, &_h)
		_x := _y := 0
		hhdc := GetDCEx(Screen, 3)
	}
	else if IsInteger(Screen) {
		M := GetMonitorInfo(Screen)
		_x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
	}
	else {
		S := StrSplit(Screen, "|")
		_x := S[1], _y := S[2], _w := S[3], _h := S[4]
	}

	if (_x = "") || (_y = "") || (_w = "") || (_h = "") {
		return -1
	}

	chdc := CreateCompatibleDC()
	hbm := CreateDIBSection(_w, _h, chdc)
	obm := SelectObject(chdc, hbm)
	hhdc := hhdc ? hhdc : GetDC()
	BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
	ReleaseDC(hhdc)

	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)

	SelectObject(chdc, obm)
	DeleteObject(hbm)
	DeleteDC(hhdc)
	DeleteDC(chdc)
	return pBitmap
}

;#####################################################################################

; Function				Gdip_BitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap from it
;
; hwnd					handle to the window to get a bitmap from
;
; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area

Gdip_BitmapFromHWND(hwnd)
{
	WinGetRect(hwnd,,, &Width, &Height)
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}

;#####################################################################################

; Function				CreateRectF
; Description			Creates a RectF object, containing a the coordinates and dimensions of a rectangle
;
; RectF					Name to call the RectF object
; x						x-coordinate of the upper left corner of the rectangle
; y						y-coordinate of the upper left corner of the rectangle
; w						Width of the rectangle
; h						Height of the rectangle
;
; return				No return value

CreateRectF(&RectF, x, y, w, h)
{
	RectF := Buffer(16)
	NumPut(
		"Float", x,
		"Float", y,
		"Float", w || 0,
		"Float", h || 0,
		RectF)
}

;#####################################################################################

; Function				CreateRect
; Description			Creates a Rect object, containing a the coordinates and dimensions of a rectangle
;
; RectF		 			Name to call the RectF object
; x						x-coordinate of the upper left corner of the rectangle
; y						y-coordinate of the upper left corner of the rectangle
; w						Width of the rectangle
; h						Height of the rectangle
;
; return				No return value
CreateRect(&Rect, x, y, w, h)
{
	Rect := Buffer(16)
	NumPut("UInt", x, "UInt", y, "UInt", w, "UInt", h, Rect)
}
;#####################################################################################

; Function				CreateSizeF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF					Name to call the SizeF object
; w						w-value for the SizeF object
; h						h-value for the SizeF object
;
; return				No Return value

CreateSizeF(&SizeF, w, h)
{
	SizeF := Buffer(8)
	NumPut("Float", w, "Float", h, SizeF)
}
;#####################################################################################

; Function				CreatePointF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF					Name to call the SizeF object
; w						w-value for the SizeF object
; h						h-value for the SizeF object
;
; return				No Return value

CreatePointF(&PointF, x, y)
{
	PointF := Buffer(8)
	NumPut("Float", x, "Float", y, PointF)
}
;#####################################################################################

; Function				CreateDIBSection
; Description			The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
;
; w						width of the bitmap to create
; h						height of the bitmap to create
; hdc					a handle to the device context to use the palette from
; bpp					bits per pixel (32 = ARGB)
; ppvBits				A pointer to a variable that receives a pointer to the location of the DIB bit values
;
; return				returns a DIB. A gdi bitmap
;
; notes					ppvBits will receive the location of the pixels in the DIB

CreateDIBSection(w, h, hdc:="", bpp:=32, &ppvBits:=0)
{
	hdc2 := hdc ? hdc : GetDC()
	bi := Buffer(40, 0)

	NumPut("UInt", 40, "UInt", w, "UInt", h, "ushort", 1, "ushort", bpp, "UInt", 0, bi)

	hbm := DllCall("CreateDIBSection"
					, "UPtr", hdc2
					, "UPtr", bi.Ptr
					, "UInt", 0
					, "UPtr*", &ppvBits
					, "UPtr", 0
					, "UInt", 0, "UPtr")

	if (!hdc) {
		ReleaseDC(hdc2)
	}
	return hbm
}

;#####################################################################################

; Function				PrintWindow
; Description			The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
;
; hwnd					A handle to the window that will be copied
; hdc					A handle to the device context
; Flags					Drawing options
;
; return				if the function succeeds, it returns a nonzero value
;
; PW_CLIENTONLY			= 1

PrintWindow(hwnd, hdc, Flags:=0)
{
	return DllCall("PrintWindow", "UPtr", hwnd, "UPtr", hdc, "UInt", Flags)
}

;#####################################################################################

; Function				DestroyIcon
; Description			Destroys an icon and frees any memory the icon occupied
;
; hIcon					Handle to the icon to be destroyed. The icon must not be in use
;
; return				if the function succeeds, the return value is nonzero

DestroyIcon(hIcon)
{
	return DllCall("DestroyIcon", "UPtr", hIcon)
}

;#####################################################################################

; Function:				GetIconDimensions
; Description:			Retrieves a given icon/cursor's width and height
;
; hIcon					Pointer to an icon or cursor
; Width					ByRef variable. This variable is set to the icon's width
; Height				ByRef variable. This variable is set to the icon's height
;
; return				if the function succeeds, the return value is zero, otherwise:
;						-1 = Could not retrieve the icon's info. Check A_LastError for extended information
;						-2 = Could not delete the icon's bitmask bitmap
;						-3 = Could not delete the icon's color bitmap

GetIconDimensions(hIcon, &Width:=0, &Height:=0) {
	ICONINFO := Buffer(size := 16 + 2 * A_PtrSize, 0)

	if !DllCall("user32\GetIconInfo", "UPtr", hIcon, "UPtr", ICONINFO.Ptr) {
		return -1
	}

	hbmMask := NumGet(ICONINFO.Ptr, 16, "UPtr")
	hbmColor := NumGet(ICONINFO.Ptr, 16 + A_PtrSize, "UPtr")
	BITMAP := Buffer(size, 0)

	if DllCall("gdi32\GetObject", "UPtr", hbmColor, "Int", size, "UPtr", BITMAP.Ptr) {
		Width := NumGet(BITMAP.Ptr, 4, "Int")
		Height := NumGet(BITMAP.Ptr, 8, "Int")
	}

	if !DllCall("gdi32\DeleteObject", "UPtr", hbmMask) {
		return -2
	}

	if !DllCall("gdi32\DeleteObject", "UPtr", hbmColor) {
		return -3
	}

	return 0
}

;#####################################################################################

PaintDesktop(hdc)
{
	return DllCall("PaintDesktop", "UPtr", hdc)
}

;#####################################################################################

CreateCompatibleBitmap(hdc, w, h)
{
	return DllCall("gdi32\CreateCompatibleBitmap", "UPtr", hdc, "Int", w, "Int", h)
}

;#####################################################################################

; Function				CreateCompatibleDC
; Description			This function creates a memory device context (DC) compatible with the specified device
;
; hdc					Handle to an existing device context
;
; return				returns the handle to a device context or 0 on failure
;
; notes					if this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

CreateCompatibleDC(hdc:=0)
{
	return DllCall("CreateCompatibleDC", "UPtr", hdc)
}

;#####################################################################################

; Function				SelectObject
; Description			The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
;
; hdc					Handle to a DC
; hgdiobj				A handle to the object to be selected into the DC
;
; return				if the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
;
; notes					The specified object must have been created by using one of the following functions
;						Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
;						Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
;						Font - CreateFont, CreateFontIndirect
;						Pen - CreatePen, CreatePenIndirect
;						Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
;
; notes					if the selected object is a region and the function succeeds, the return value is one of the following value
;
; SIMPLEREGION			= 2 Region consists of a single rectangle
; COMPLEXREGION			= 3 Region consists of more than one rectangle
; NULLREGION			= 1 Region is empty

SelectObject(hdc, hgdiobj)
{
	return DllCall("SelectObject", "UPtr", hdc, "UPtr", hgdiobj)
}

;#####################################################################################

; Function				DeleteObject
; Description			This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
;						After the object is deleted, the specified handle is no longer valid
;
; hObject				Handle to a logical pen, brush, font, bitmap, region, or palette to delete
;
; return				Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

DeleteObject(hObject)
{
	return DllCall("DeleteObject", "UPtr", hObject)
}

;#####################################################################################

; Function				GetDC
; Description			This function retrieves a handle to a display device context (DC) for the client area of the specified window.
;						The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window.
;
; hwnd					Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen
;
; return				The handle the device context for the specified window's client area indicates success. NULL indicates failure

GetDC(hwnd:=0)
{
	return DllCall("GetDC", "UPtr", hwnd)
}

;#####################################################################################

; DCX_CACHE = 0x2
; DCX_CLIPCHILDREN = 0x8
; DCX_CLIPSIBLINGS = 0x10
; DCX_EXCLUDERGN = 0x40
; DCX_EXCLUDEUPDATE = 0x100
; DCX_INTERSECTRGN = 0x80
; DCX_INTERSECTUPDATE = 0x200
; DCX_LOCKWINDOWUPDATE = 0x400
; DCX_NORECOMPUTE = 0x100000
; DCX_NORESETATTRS = 0x4
; DCX_PARENTCLIP = 0x20
; DCX_VALIDATE = 0x200000
; DCX_WINDOW = 0x1

GetDCEx(hwnd, flags:=0, hrgnClip:=0)
{
	return DllCall("GetDCEx", "UPtr", hwnd, "UPtr", hrgnClip, "Int", flags)
}

;#####################################################################################

; Function				ReleaseDC
; Description			This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
;
; hdc					Handle to the device context to be released
; hwnd					Handle to the window whose device context is to be released
;
; return				1 = released
;						0 = not released
;
; notes					The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
;						An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function.

ReleaseDC(hdc, hwnd:=0)
{
	return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}

;#####################################################################################

; Function				DeleteDC
; Description			The DeleteDC function deletes the specified device context (DC)
;
; hdc					A handle to the device context
;
; return				if the function succeeds, the return value is nonzero
;
; notes					An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

DeleteDC(hdc)
{
	return DllCall("DeleteDC", "UPtr", hdc)
}
;#####################################################################################

; Function				Gdip_LibraryVersion
; Description			Get the current library version
;
; return				the library version
;
; notes					This is useful for non compiled programs to ensure that a person doesn't run an old version when testing your scripts

Gdip_LibraryVersion()
{
	return 1.45
}

;#####################################################################################

; Function				Gdip_LibrarySubVersion
; Description			Get the current library sub version
;
; return				the library sub version
;
; notes					This is the sub-version currently maintained by Rseding91
; 					Updated by guest3456 preliminary AHK v2 support
Gdip_LibrarySubVersion()
{
	return 1.54
}

;#####################################################################################

; Function:				Gdip_BitmapFromBRA
; Description: 			Gets a pointer to a gdi+ bitmap from a BRA file
;
; BRAFromMemIn			The variable for a BRA file read to memory
; File					The name of the file, or its number that you would like (This depends on alternate parameter)
; Alternate				Changes whether the File parameter is the file name or its number
;
; return					if the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1 = The BRA variable is empty
;						-2 = The BRA has an incorrect header
;						-3 = The BRA has information missing
;						-4 = Could not find file inside the BRA

Gdip_BitmapFromBRA(BRAFromMemIn, File, Alternate := 0) {
	if (!BRAFromMemIn) {
		return -1
	}

	Headers := StrSplit(StrGet(BRAFromMemIn.Ptr, 256, "CP0"), "`n")
	Header := StrSplit(Headers[1], "|")
	HeaderLength := Header.Length

	if (HeaderLength != 4) || (Header[2] != "BRA!") {
		return -2
	}

	_Info := StrSplit(Headers[2], "|")
	_InfoLength := _Info.Length

	if (_InfoLength != 3) {
		return -3
	}

	OffsetTOC := StrPut(Headers[1], "CP0") + StrPut(Headers[2], "CP0") ;  + 2
	OffsetData := _Info[2]
	SearchIndex := Alternate ? 1 : 2
	TOC := StrGet(BRAFromMemIn.Ptr + OffsetTOC, OffsetData - OffsetTOC - 1, "CP0")
	RX1 := "mi`n)^"
	Offset := Size := 0

	if RegExMatch(TOC, RX1 . (Alternate ? File "\|.+?" : "\d+\|" . File) . "\|(\d+)\|(\d+)$", &FileInfo:="") {
		Offset := OffsetData + FileInfo[1]
		Size := FileInfo[2]
	}

	if (Size = 0) {
		return -4
	}

	hData := DllCall("GlobalAlloc", "UInt", 2, "UInt", Size, "UPtr")
	pData := DllCall("GlobalLock", "Ptr", hData, "UPtr")
	DllCall("RtlMoveMemory", "Ptr", pData, "Ptr", BRAFromMemIn.Ptr + Offset, "Ptr", Size)
	DllCall("GlobalUnlock", "Ptr", hData)
	DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", 1, "Ptr*", &pStream:=0)
	DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", pStream, "Ptr*", &pBitmap:=0)
	ObjRelease(pStream)

	return pBitmap
}

;#####################################################################################

; Function:				Gdip_BitmapFromBase64
; Description:			Creates a bitmap from a Base64 encoded string
;
; Base64				Base64 encoded string.
;
; return				if the function succeeds, the return value is a pointer to a bitmap, otherwise:
;						-1 = Could not calculate the length of the required buffer
;						-2 = Could not decode the Base64 encoded string
;						-3 = Could not create a memory stream

Gdip_BitmapFromBase64(Base64)
{
	; calculate the length of the buffer needed
	if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", 0, "UInt*", &DecLen:=0, "UPtr", 0, "UPtr", 0)) {
		return -1
	}

	Dec := Buffer(DecLen, 0)

	; decode the Base64 encoded string
	if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", Dec.Ptr, "UInt*", &DecLen, "UPtr", 0, "UPtr", 0)) {
		return -2
	}

	; create a memory stream
	if !(pStream := DllCall("shlwapi\SHCreateMemStream", "UPtr", Dec.Ptr, "UInt", DecLen, "UPtr")) {
		return -3
	}

	DllCall("gdiplus\GdipCreateBitmapFromStreamICM", "UPtr", pStream, "Ptr*", &pBitmap:=0)
	ObjRelease(pStream)

	return pBitmap
}

;#####################################################################################

; Function:				Gdip_EncodeBitmapTo64string
; Description:			Encode a bitmap to a Base64 encoded string
;
; pBitmap				Pointer to a bitmap
; sOutput				The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
; Quality				if saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;
; return				if the function succeeds, the return value is a Base64 encoded string of the pBitmap

Gdip_EncodeBitmapTo64string(pBitmap, extension := "png", quality := "") {

    ; Fill a buffer with the available image codec info.
    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &count:=0, "uint*", &size:=0)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", count, "uint", size, "ptr", ci := Buffer(size))

    ; struct ImageCodecInfo - http://www.jose.it-berater.org/gdiplus/reference/structures/imagecodecinfo.htm
    loop {
        if (A_Index > count)
        throw Error("Could not find a matching encoder for the specified file format.")

        idx := (48+7*A_PtrSize)*(A_Index-1)
    } until InStr(StrGet(NumGet(ci, idx+32+3*A_PtrSize, "ptr"), "UTF-16"), extension) ; FilenameExtension

    ; Get the pointer to the clsid of the matching encoder.
    pCodec := ci.ptr + idx ; ClassID

    ; JPEG default quality is 75. Otherwise set a quality value from [0-100].
    if (quality ~= "^-?\d+$") and ("image/jpeg" = StrGet(NumGet(ci, idx+32+4*A_PtrSize, "ptr"), "UTF-16")) { ; MimeType
        ; Use a separate buffer to store the quality as ValueTypeLong (4).
        v := Buffer(4)
		NumPut("uint", quality, v)

        ; struct EncoderParameter - http://www.jose.it-berater.org/gdiplus/reference/structures/encoderparameter.htm
        ; enum ValueType - https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.encoderparametervaluetype
        ; clsid Image Encoder Constants - http://www.jose.it-berater.org/gdiplus/reference/constants/gdipimageencoderconstants.htm
        ep := Buffer(24+2*A_PtrSize)                  ; sizeof(EncoderParameter) = ptr + n*(28, 32)
        NumPut(  "uptr",     1, ep,            0)  ; Count
        DllCall("ole32\CLSIDFromString", "wstr", "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}", "ptr", ep.ptr+A_PtrSize, "HRESULT")
        NumPut(  "uint",     1, ep, 16+A_PtrSize)  ; Number of Values
        NumPut(  "uint",     4, ep, 20+A_PtrSize)  ; Type
        NumPut(   "ptr", v.ptr, ep, 24+A_PtrSize)  ; Value
    }

    ; Create a Stream.
    DllCall("ole32\CreateStreamOnHGlobal", "ptr", 0, "int", True, "ptr*", &pStream:=0, "HRESULT")
    DllCall("gdiplus\GdipSaveImageToStream", "ptr", pBitmap, "ptr", pStream, "ptr", pCodec, "ptr", IsSet(ep) ? ep : 0)

    ; Get a pointer to binary data.
    DllCall("ole32\GetHGlobalFromStream", "ptr", pStream, "ptr*", &hbin:=0, "HRESULT")
    bin := DllCall("GlobalLock", "ptr", hbin, "ptr")
    size := DllCall("GlobalSize", "uint", bin, "uptr")

    ; Calculate the length of the base64 string.
    flags := 0x40000001 ; CRYPT_STRING_NOCRLF | CRYPT_STRING_BASE64
    length := 4 * Ceil(size/3) + 1 ; An extra byte of padding is required.
    str := Buffer(length)

    ; Using CryptBinaryToStringA saves about 2MB in memory.
    DllCall("crypt32\CryptBinaryToStringA", "ptr", bin, "uint", size, "uint", flags, "ptr", str, "uint*", &length)

    ; Release binary data and stream.
    DllCall("GlobalUnlock", "ptr", hbin)
    ObjRelease(pStream)

    ; Return encoded string length minus 1.
    return StrGet(str, length, "CP0")
}

;#####################################################################################

; Function				Gdip_DrawRectangle
; Description			This function uses a pen to draw the outline of a rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
	return DllCall("gdiplus\GdipDrawRectangle", "UPtr", pGraphics, "UPtr", pPen, "Float", x, "Float", y, "Float", w, "Float", h)
}

;#####################################################################################

; Function				Gdip_DrawRoundedRectangle
; Description			This function uses a pen to draw the outline of a rounded rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
{
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	_E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
	Gdip_ResetClip(pGraphics)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_ResetClip(pGraphics)
	return _E
}

;#####################################################################################
; function by just me found on:
; https://www.autohotkey.com/boards/viewtopic.php?t=46250
; modified by Marius Șucan
;
; Function           Gdip_DrawRoundedRectanglePath
; Description        This function uses a pen to draw a rounded rectangle in the Graphics of a bitmap
;
; pGraphics          Pointer to the Graphics of a bitmap
; pPen               Pointer to a pPen
; x                  x-coordinate of the top left of the rounded rectangle
; y                  y-coordinate of the top left of the rounded rectangle
; w                  width of the rectanlge
; h                  height of the rectangle
; r                  radius of the rounded corners
;
; return             status enumeration. 0 = success

Gdip_DrawRoundedRectanglePath(pGraphics, pPen, X, Y, W, H, R) {
	pPath := Gdip_CreatePath()
	Gdip_AddPathRoundedRectangle(pPath, X, Y, W, H, R)
	E := Gdip_DrawPath(pGraphics, pPen, pPath)
	Gdip_DeletePath(pPath)
	Return E
 }

;#####################################################################################

; Function				Gdip_DrawEllipse
; Description			This function uses a pen to draw the outline of an ellipse into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle the ellipse will be drawn into
; y						y-coordinate of the top left of the rectangle the ellipse will be drawn into
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
	return DllCall("gdiplus\GdipDrawEllipse", "UPtr", pGraphics, "UPtr", pPen, "Float", x, "Float", y, "Float", w, "Float", h)
}

;#####################################################################################

; Function				Gdip_DrawBezier
; Description			This function uses a pen to draw the outline of a bezier (a weighted curve) into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the bezier
; y1					y-coordinate of the start of the bezier
; x2					x-coordinate of the first arc of the bezier
; y2					y-coordinate of the first arc of the bezier
; x3					x-coordinate of the second arc of the bezier
; y3					y-coordinate of the second arc of the bezier
; x4					x-coordinate of the end of the bezier
; y4					y-coordinate of the end of the bezier
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
{
	return DllCall("gdiplus\GdipDrawBezier"
					, "UPtr", pgraphics
					, "UPtr", pPen
					, "Float", x1
					, "Float", y1
					, "Float", x2
					, "Float", y2
					, "Float", x3
					, "Float", y3
					, "Float", x4
					, "Float", y4)
}

;#####################################################################################

; Function				Gdip_DrawArc
; Description			This function uses a pen to draw the outline of an arc into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the arc
; y						y-coordinate of the start of the arc
; w						width of the arc
; h						height of the arc
; StartAngle			specifies the angle between the x-axis and the starting point of the arc
; SweepAngle			specifies the angle between the starting and ending points of the arc
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	return DllCall("gdiplus\GdipDrawArc"
					, "UPtr", pGraphics
					, "UPtr", pPen
					, "Float", x
					, "Float", y
					, "Float", w
					, "Float", h
					, "Float", StartAngle
					, "Float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawPie
; Description			This function uses a pen to draw the outline of a pie into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the pie
; y						y-coordinate of the start of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	return DllCall("gdiplus\GdipDrawPie", "UPtr", pGraphics, "UPtr", pPen, "Float", x, "Float", y, "Float", w, "Float", h, "Float", StartAngle, "Float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawLine
; Description			This function uses a pen to draw a line into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the line
; y1					y-coordinate of the start of the line
; x2					x-coordinate of the end of the line
; y2					y-coordinate of the end of the line
;
; return				status enumeration. 0 = success

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
	return DllCall("gdiplus\GdipDrawLine"
					, "UPtr", pGraphics
					, "UPtr", pPen
					, "Float", x1
					, "Float", y1
					, "Float", x2
					, "Float", y2)
}

;#####################################################################################

; Function				Gdip_DrawLines
; Description			This function uses a pen to draw a series of joined lines into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; Points				the coordinates of all the points passed as an array [[x1,y1],[x2,y2],[x3,y3].....
;
; return				status enumeration. 0 = success

Gdip_DrawLines(pGraphics, pPen, Points)
{
	PointsLength := points.Length
	PointF := Buffer(8*pointsLength)
	for Point in Points {
		NumPut("Float", Point[1], PointF, 8*(A_Index-1))
		NumPut("Float", Point[2], PointF, (8*(A_Index-1))+4)
	}
	return DllCall("gdiplus\GdipDrawLines", "UPtr", pGraphics, "UPtr", pPen, "UPtr", PointF.Ptr, "Int", PointsLength)
}

;#####################################################################################

; Function				Gdip_DrawCurve
; Description			This function draws an open spline on a pGraphics object using a pPen object.
;						A cardinal spline is a curve that passes through each point in the array.
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; Points				the coordinates of all the points passed as an array [[x1,y1],[x2,y2],[x3,y3].....
; Tension				Non-negative real number that controls the length of the curve and how the curve bends
;
; return				status enumeration. 0 = success

Gdip_DrawCurve(pGraphics, pPen, Points, Tension:="") {
	PointsLength := points.Length
	PointF := Buffer(8*pointsLength)
	for Point in Points {
		NumPut("Float", Point[1], PointF, 8*(A_Index-1))
		NumPut("Float", Point[2], PointF, (8*(A_Index-1))+4)
	}
	return IsNumber(Tension) ? DllCall("gdiplus\GdipDrawCurve2", "UPtr", pGraphics, "UPtr", pPen, "UPtr", PointF.Ptr, "UInt", PointsLength, "float", Tension)
		: DllCall("gdiplus\GdipDrawCurve", "UPtr", pGraphics, "UPtr", pPen, "UPtr", PointF.Ptr, "Int", PointsLength)
}

;#####################################################################################

; Function				Gdip_FillRectangle
; Description			This function uses a brush to fill a rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success

Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
	return DllCall("gdiplus\GdipFillRectangle"
					, "UPtr", pGraphics
					, "UPtr", pBrush
					, "Float", x
					, "Float", y
					, "Float", w
					, "Float", h)
}

;#####################################################################################

; Function				Gdip_FillRoundedRectangle
; Description			This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success

Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
{
	Region := Gdip_GetClipRegion(pGraphics)
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	_E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_DeleteRegion(Region)
	return _E
}

;#####################################################################################
; function by just me found on:
; https://www.autohotkey.com/boards/viewtopic.php?t=46250
; Function           Gdip_FillRoundedRectanglePath
; Description        This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
;
; pGraphics          Pointer to the Graphics of a bitmap
; pBrush             Pointer to a brush
; x                  x-coordinate of the top left of the rounded rectangle
; y                  y-coordinate of the top left of the rounded rectangle
; w                  width of the rectanlge
; h                  height of the rectangle
; r                  radius of the rounded corners
;
; return             status enumeration. 0 = success

Gdip_FillRoundedRectanglePath(pGraphics, pBrush, X, Y, W, H, R) {
	pPath := Gdip_CreatePath()
	Gdip_AddPathRoundedRectangle(pPath, X, Y, W, H, R)
	E := Gdip_FillPath(pGraphics, pBrush, pPath)
	Gdip_DeletePath(pPath)
	Return E
}

;#####################################################################################

; Function				Gdip_FillPolygon
; Description			This function uses a brush to fill a polygon in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Points				the coordinates of all the points passed as an array [[x1,y1],[x2,y2],[x3,y3].....
;
; return				status enumeration. 0 = success
;
; notes					Alternate will fill the polygon as a whole, wheras winding will fill each new "segment"
; Alternate 			= 0
; Winding 				= 1

Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode:=0)
{
	PointsLength := Points.Length
	PointF := Buffer(8*PointsLength)
	For Point in Points
	{
		NumPut("Float", Point[1], PointF, 8*(A_Index-1))
		NumPut("Float", Point[2], PointF, (8*(A_Index-1))+4)
	}
	return DllCall("gdiplus\GdipFillPolygon", "UPtr", pGraphics, "UPtr", pBrush, "UPtr", PointF.Ptr, "Int", PointsLength, "Int", FillMode)
}

;#####################################################################################

; Function				Gdip_FillPie
; Description			This function uses a brush to fill a pie in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the pie
; y						y-coordinate of the top left of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success

Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
{
	return DllCall("gdiplus\GdipFillPie"
					, "UPtr", pGraphics
					, "UPtr", pBrush
					, "Float", x
					, "Float", y
					, "Float", w
					, "Float", h
					, "Float", StartAngle
					, "Float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_FillEllipse
; Description			This function uses a brush to fill an ellipse in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the ellipse
; y						y-coordinate of the top left of the ellipse
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success

Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
	return DllCall("gdiplus\GdipFillEllipse", "UPtr", pGraphics, "UPtr", pBrush, "Float", x, "Float", y, "Float", w, "Float", h)
}

;#####################################################################################

; Function				Gdip_FillRegion
; Description			This function uses a brush to fill a region in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Region
;
; return				status enumeration. 0 = success
;
; notes					You can create a region Gdip_CreateRegion() and then add to this

Gdip_FillRegion(pGraphics, pBrush, Region)
{
	return DllCall("gdiplus\GdipFillRegion", "UPtr", pGraphics, "UPtr", pBrush, "UPtr", Region)
}

;#####################################################################################

; Function				Gdip_FillPath
; Description			This function uses a brush to fill a path in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Path
;
; return				status enumeration. 0 = success

Gdip_FillPath(pGraphics, pBrush, pPath)
{
	return DllCall("gdiplus\GdipFillPath", "UPtr", pGraphics, "UPtr", pBrush, "UPtr", pPath)
}

;#####################################################################################

; Function				Gdip_DrawImagePointsRect
; Description			This function draws a bitmap into the Graphics of another bitmap and skews it
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; Points				Points passed as x1,y1|x2,y2|x3,y3 (3 points: top left, top right, bottom left) describing the drawing of the bitmap
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter

Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx:="", sy:="", sw:="", sh:="", Matrix:=1)
{
	Points := StrSplit(Points, "|")
	PointsLength := Points.Length
	PointF := Buffer(8*PointsLength)
	For eachPoint, Point in Points
	{
		Coord := StrSplit(Point, ",")
		NumPut("Float", Coord[1], PointF, 8*(A_Index-1))
		NumPut("Float", Coord[2], PointF, (8*(A_Index-1))+4)
	}

	if !IsNumber(Matrix)
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
	else
		ImageAttr := 0

	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		sx := 0, sy := 0
		sw := Gdip_GetImageWidth(pBitmap)
		sh := Gdip_GetImageHeight(pBitmap)
	}

	_E := DllCall("gdiplus\GdipDrawImagePointsRect"
				, "UPtr", pGraphics
				, "UPtr", pBitmap
				, "UPtr", PointF.Ptr
				, "Int", PointsLength
				, "Float", sx
				, "Float", sy
				, "Float", sw
				, "Float", sh
				, "Int", 2
				, "UPtr", ImageAttr
				, "UPtr", 0
				, "UPtr", 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return _E
}

;#####################################################################################

; Function				Gdip_DrawImage
; Description			This function draws a bitmap into the Graphics of another bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination image
; dh					height of destination image
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source image
; sh					height of source image
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Gdip_DrawImage performs faster
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter. For example:
;						MatrixBright=
;						(
;						1.5		|0		|0		|0		|0
;						0		|1.5	|0		|0		|0
;						0		|0		|1.5	|0		|0
;						0		|0		|0		|1		|0
;						0.05	|0.05	|0.05	|0		|1
;						)
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|1|1|1|0|1

Gdip_DrawImage(pGraphics, pBitmap, dx:="", dy:="", dw:="", dh:="", sx:="", sy:="", sw:="", sh:="", Matrix:=1)
{
	if !IsNumber(Matrix)
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
	else
		ImageAttr := 0

	if (sx = "")
		sx := 0
	if (sy = "")
		sy := 0
	if (sw = "")
		sw := Gdip_GetImageWidth(pBitmap)
	if (sh = "")
		sh := Gdip_GetImageHeight(pBitmap)

	if (dx = "")
		dx := 0
	if (dy = "")
		dy := 0
	if (dw = "")
		dw := Gdip_GetImageWidth(pBitmap)
	if (dh = "")
		dh := Gdip_GetImageHeight(pBitmap)

	_E := DllCall("gdiplus\GdipDrawImageRectRect"
				, "UPtr", pGraphics
				, "UPtr", pBitmap
				, "Float", dx
				, "Float", dy
				, "Float", dw
				, "Float", dh
				, "Float", sx
				, "Float", sy
				, "Float", sw
				, "Float", sh
				, "Int", 2
				, "UPtr", ImageAttr
				, "UPtr", 0
				, "UPtr", 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return _E
}

;#####################################################################################

; Function				Gdip_SetImageAttributesColorMatrix
; Description			This function creates an image matrix ready for drawing
;
; Matrix				a matrix used to alter image attributes when drawing
;						passed with any delimeter
;
; return				returns an image matrix on sucess or 0 if it fails
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|1|1|1|0|1

Gdip_SetImageAttributesColorMatrix(Matrix)
{
	ColourMatrix := Buffer(100, 0)
	Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
	Matrix := StrSplit(Matrix, "|")

	loop 25 {
		M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
		NumPut("Float", M, ColourMatrix, (A_Index-1)*4)
	}

	DllCall("gdiplus\GdipCreateImageAttributes", "UPtr*", &ImageAttr:=0)
	DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "UPtr", ImageAttr, "Int", 1, "Int", 1, "UPtr", ColourMatrix.Ptr, "UPtr", 0, "Int", 0)

	return ImageAttr
}

;#####################################################################################

; Function				Gdip_GraphicsFromImage
; Description			This function gets the graphics for a bitmap used for drawing functions
;
; pBitmap				Pointer to a bitmap to get the pointer to its graphics
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					a bitmap can be drawn into the graphics of another bitmap

Gdip_GraphicsFromImage(pBitmap)
{
	DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", &pGraphics:=0)
	return pGraphics
}

;#####################################################################################

; Function				Gdip_GraphicsFromHDC
; Description			This function gets the graphics from the handle to a device context
;
; hdc					This is the handle to the device context
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					You can draw a bitmap into the graphics of another bitmap

Gdip_GraphicsFromHDC(hdc)
{
	DllCall("gdiplus\GdipCreateFromHDC", "UPtr", hdc, "UPtr*", &pGraphics:=0)
	return pGraphics
}

;#####################################################################################

; Function				Gdip_GetDC
; Description			This function gets the device context of the passed Graphics
;
; hdc					This is the handle to the device context
;
; return				returns the device context for the graphics of a bitmap

Gdip_GetDC(pGraphics)
{
	DllCall("gdiplus\GdipGetDC", "UPtr", pGraphics, "UPtr*", &hdc:=0)
	return hdc
}

;#####################################################################################

; Function				Gdip_ReleaseDC
; Description			This function releases a device context from use for further use
;
; pGraphics				Pointer to the graphics of a bitmap
; hdc					This is the handle to the device context
;
; return				status enumeration. 0 = success

Gdip_ReleaseDC(pGraphics, hdc)
{
	return DllCall("gdiplus\GdipReleaseDC", "UPtr", pGraphics, "UPtr", hdc)
}

;#####################################################################################

; Function				Gdip_GraphicsClear
; Description			Clears the graphics of a bitmap ready for further drawing
;
; pGraphics				Pointer to the graphics of a bitmap
; ARGB					The colour to clear the graphics to
;
; return				status enumeration. 0 = success
;
; notes					By default this will make the background invisible
;						Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics

Gdip_GraphicsClear(pGraphics, ARGB:=0x00ffffff)
{
	return DllCall("gdiplus\GdipGraphicsClear", "UPtr", pGraphics, "Int", ARGB)
}

;#####################################################################################

; Function				Gdip_BlurBitmap
; Description			Gives a pointer to a blurred bitmap from a pointer to a bitmap
;
; pBitmap				Pointer to a bitmap to be blurred
; Blur					The Amount to blur a bitmap by from 1 (least blur) to 100 (most blur)
;
; return				if the function succeeds, the return value is a pointer to the new blurred bitmap
;						-1 = The blur parameter is outside the range 1-100
;
; notes					This function will not dispose of the original bitmap

Gdip_BlurBitmap(pBitmap, Blur)
{
	if (Blur > 100 || Blur < 1) {
		return -1
	}

	sWidth := Gdip_GetImageWidth(pBitmap), sHeight := Gdip_GetImageHeight(pBitmap)
	dWidth := sWidth//Blur, dHeight := sHeight//Blur

	pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight)
	G1 := Gdip_GraphicsFromImage(pBitmap1)
	Gdip_SetInterpolationMode(G1, 7)
	Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)

	Gdip_DeleteGraphics(G1)

	pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight)
	G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_SetInterpolationMode(G2, 7)
	Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)

	Gdip_DeleteGraphics(G2)
	Gdip_DisposeImage(pBitmap1)

	return pBitmap2
}

;#####################################################################################

; Function:				Gdip_SaveBitmapToFile
; Description:			Saves a bitmap to a file in any supported format onto disk
;
; pBitmap				Pointer to a bitmap
; sOutput				The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
; Quality				if saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;
; return				if the function succeeds, the return value is zero, otherwise:
;						-1 = Extension supplied is not a supported file format
;						-2 = Could not get a list of encoders on system
;						-3 = Could not find matching encoder for specified file format
;						-4 = Could not get WideChar name of output file
;						-5 = Could not save file to disk
;
; notes					This function will use the extension supplied from the sOutput parameter to determine the output format

Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality:=75)
{
	_p := 0

	SplitPath sOutput,,, &extension:=""
	if (!RegExMatch(extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")) {
		return -1
	}
	extension := "." extension

	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount:=0, "uint*", &nSize:=0)
	ci := Buffer(nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UPtr", ci.Ptr)
	if !(nCount && nSize) {
		return -2
	}

	loop nCount {
		address := NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "UPtr")
		sString := StrGet(address, "UTF-16")
		if !InStr(sString, "*" extension)
			continue

		pCodec := ci.Ptr+idx
		break
	}

	if !pCodec {
		return -3
	}

	; from @iseahound ImagePut.select_codec
	if (quality ~= "^-?\d+$") and ("image/jpeg" = StrGet(NumGet(ci, idx+32+4*A_PtrSize, "ptr"), "UTF-16")) { ; MimeType
		; Use a separate buffer to store the quality as ValueTypeLong (4).
		v := Buffer(4), NumPut("uint", quality, v)

		; struct EncoderParameter - http://www.jose.it-berater.org/gdiplus/reference/structures/encoderparameter.htm
		; enum ValueType - https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.encoderparametervaluetype
		; clsid Image Encoder Constants - http://www.jose.it-berater.org/gdiplus/reference/constants/gdipimageencoderconstants.htm
		ep := Buffer(24+2*A_PtrSize)                  ; sizeof(EncoderParameter) = ptr + n*(28, 32)
			NumPut(  "uptr",     1, ep,            0)  ; Count
			DllCall("ole32\CLSIDFromString", "wstr", "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}", "ptr", ep.ptr+A_PtrSize, "hresult")
			NumPut(  "uint",     1, ep, 16+A_PtrSize)  ; Number of Values
			NumPut(  "uint",     4, ep, 20+A_PtrSize)  ; Type
			NumPut(   "ptr", v.ptr, ep, 24+A_PtrSize)  ; Value
	}

	_E := DllCall("gdiplus\GdipSaveImageToFile", "UPtr", pBitmap, "UPtr", StrPtr(sOutput), "UPtr", pCodec, "UInt", _p ? _p : 0)

	return _E ? -5 : 0
}

;#####################################################################################

; Function:        Gdip_SaveBitmapToStream
; Description:     Saves the provided pBitmap to a newly created memory stream.
;
; pBitmap          The handle of a GDI+ image object
; ext              The format or encoder to use. Supported extensions and formats: BMP, DIB, RLE, JPG, JPEG, JPE, JFIF, GIF, TIF, TIFF, PNG
; Quality          If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100
;
; return           If the function succeeds, the handle to the memory stream is returned. otherwise:
;                  -1 = Extension supplied is not a supported image file encoder
;                  -2 = Could not get a list of encoders on system
;                  -3 = Could not find matching encoder for specified file format
;                  -6 = Could not save image to stream

Gdip_SaveBitmapToStream(pBitmap, Extension:="PNG", Quality:=90)
{
	_p := 0

	if (!RegExMatch(extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")) {
		return -1
	}
	extension := "." extension

	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount:=0, "uint*", &nSize:=0)
	ci := Buffer(nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UPtr", ci.Ptr)
	if !(nCount && nSize) {
		return -2
	}

	loop nCount {
		address := NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "UPtr")
		sString := StrGet(address, "UTF-16")
		if !InStr(sString, "*" extension)
			continue

		pCodec := ci.Ptr+idx
		break
	}

	if !pCodec {
		return -3
	}

	; from @iseahound ImagePut.select_codec
	if (quality ~= "^-?\d+$") and ("image/jpeg" = StrGet(NumGet(ci, idx+32+4*A_PtrSize, "ptr"), "UTF-16")) { ; MimeType
		; Use a separate buffer to store the quality as ValueTypeLong (4).
		v := Buffer(4), NumPut("uint", quality, v)

		; struct EncoderParameter - http://www.jose.it-berater.org/gdiplus/reference/structures/encoderparameter.htm
		; enum ValueType - https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.encoderparametervaluetype
		; clsid Image Encoder Constants - http://www.jose.it-berater.org/gdiplus/reference/constants/gdipimageencoderconstants.htm
		ep := Buffer(24+2*A_PtrSize)                  ; sizeof(EncoderParameter) = ptr + n*(28, 32)
			NumPut(  "uptr",     1, ep,            0)  ; Count
			DllCall("ole32\CLSIDFromString", "wstr", "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}", "ptr", ep.ptr+A_PtrSize, "hresult")
			NumPut(  "uint",     1, ep, 16+A_PtrSize)  ; Number of Values
			NumPut(  "uint",     4, ep, 20+A_PtrSize)  ; Type
			NumPut(   "ptr", v.ptr, ep, 24+A_PtrSize)  ; Value
	}

	DllCall("ole32\CreateStreamOnHGlobal", "Ptr",0, "Int",true, "ptr*",&pStream:=0)
	DllCall("gdiplus\GdipSaveImageToStream", "Ptr",pBitmap, "Ptr",pStream, "Ptr",pCodec, "uint", _p ? _p : 0)
	return pStream
}

;#####################################################################################

; Function				Gdip_GetPixel
; Description			Gets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				Returns the ARGB value of the pixel

Gdip_GetPixel(pBitmap, x, y)
{
	DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "Int", x, "Int", y, "uint*", &ARGB:=0)
	return ARGB
}

;#####################################################################################

; Function				Gdip_SetPixel
; Description			Sets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				status enumeration. 0 = success

Gdip_SetPixel(pBitmap, x, y, ARGB)
{
	return DllCall("gdiplus\GdipBitmapSetPixel", "UPtr", pBitmap, "Int", x, "Int", y, "Int", ARGB)
}

;#####################################################################################

; Function				Gdip_GetImageWidth
; Description			Gives the width of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the width in pixels of the supplied bitmap

Gdip_GetImageWidth(pBitmap)
{
	DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", &Width:=0)
	return Width
}

;#####################################################################################

; Function				Gdip_GetImageHeight
; Description			Gives the height of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the height in pixels of the supplied bitmap

Gdip_GetImageHeight(pBitmap)
{
	DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", &Height:=0)
	return Height
}

;#####################################################################################

; Function				Gdip_GetDimensions
; Description			Gives the width and height of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetImageDimensions(pBitmap, &Width, &Height)
{
	DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", &Width:=0)
	DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", &Height:=0)
}

;#####################################################################################

Gdip_GetDimensions(pBitmap, &Width, &Height)
{
	Gdip_GetImageDimensions(pBitmap, &Width, &Height)
}

;#####################################################################################

Gdip_GetImagePixelFormat(pBitmap)
{
	DllCall("gdiplus\GdipGetImagePixelFormat", "UPtr", pBitmap, "UPtr*", &_Format:=0)
	return _Format
}

;#####################################################################################

; Function				Gdip_GetDpiX
; Description			Gives the horizontal dots per inch of the graphics of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetDpiX(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiX", "UPtr", pGraphics, "float*", &dpix:=0)
	return Round(dpix)
}

;#####################################################################################

Gdip_GetDpiY(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiY", "UPtr", pGraphics, "float*", &dpiy:=0)
	return Round(dpiy)
}

;#####################################################################################

Gdip_GetImageHorizontalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageHorizontalResolution", "UPtr", pBitmap, "float*", &dpix:=0)
	return Round(dpix)
}

;#####################################################################################

Gdip_GetImageVerticalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageVerticalResolution", "UPtr", pBitmap, "float*", &dpiy:=0)
	return Round(dpiy)
}

;#####################################################################################

Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
{
	return DllCall("gdiplus\GdipBitmapSetResolution", "UPtr", pBitmap, "Float", dpix, "Float", dpiy)
}

;#####################################################################################

Gdip_CreateBitmapFromFile(sFile, IconNumber:=1, IconSize:="")
{
	SplitPath sFile,,, &extension:=""
	if RegExMatch(extension, "^(?i:exe|dll)$") {
		Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
		BufSize := 16 + (2*(A_PtrSize ? A_PtrSize : 4))

		buf := Buffer(BufSize, 0)
		hIcon := 0

		for eachSize, Size in StrSplit( Sizes, "|" ) {
			DllCall("PrivateExtractIcons", "str", sFile, "Int", IconNumber-1, "Int", Size, "Int", Size, "UPtr*", &hIcon, "UPtr*", 0, "UInt", 1, "UInt", 0)

			if (!hIcon) {
				continue
			}

			if !DllCall("GetIconInfo", "UPtr", hIcon, "UPtr", buf.Ptr) {
				DestroyIcon(hIcon)
				continue
			}

			hbmMask  := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4))
			hbmColor := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4) + (A_PtrSize ? A_PtrSize : 4))
			if !(hbmColor && DllCall("GetObject", "UPtr", hbmColor, "Int", BufSize, "UPtr", buf.Ptr))
			{
				DestroyIcon(hIcon)
				continue
			}
			break
		}

		if (!hIcon) {
			return -1
		}

		Width := NumGet(buf, 4, "Int"), Height := NumGet(buf, 8, "Int")
		hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
		if !DllCall("DrawIconEx", "UPtr", hdc, "Int", 0, "Int", 0, "UPtr", hIcon, "UInt", Width, "UInt", Height, "UInt", 0, "UPtr", 0, "UInt", 3) {
			DestroyIcon(hIcon)
			return -2
		}

		dib := Buffer(104)
		DllCall("GetObject", "UPtr", hbm, "Int", A_PtrSize = 8 ? 104 : 84, "UPtr", dib.Ptr) ; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
		Stride := NumGet(dib, 12, "Int"), Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0)) ; padding
		DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", Width, "Int", Height, "Int", Stride, "Int", 0x26200A, "UPtr", Bits, "UPtr*", &pBitmapOld:=0)
		pBitmap := Gdip_CreateBitmap(Width, Height)
		_G := Gdip_GraphicsFromImage(pBitmap)
		, Gdip_DrawImage(_G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
		SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
		Gdip_DeleteGraphics(_G), Gdip_DisposeImage(pBitmapOld)
		DestroyIcon(hIcon)

	} else {
		DllCall("gdiplus\GdipCreateBitmapFromFile", "UPtr", StrPtr(sFile), "UPtr*", &pBitmap:=0)
	}

	return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette:=0)
{
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap:=0)
	return pBitmap
}

;#####################################################################################

Gdip_CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff)
{
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", pBitmap, "UPtr*", &hbm:=0, "Int", Background)
	return hbm
}

;#####################################################################################

Gdip_CreateARGBBitmapFromHBITMAP(&hBitmap) {
	; struct BITMAP - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmap
	dib := Buffer(76+2*(A_PtrSize=8?4:0)+2*A_PtrSize)
	DllCall("GetObject"
				,    "ptr", hBitmap
				,    "Int", dib.Size
				,    "ptr", dib.Ptr) ; sizeof(DIBSECTION) = 84, 104
		, width  := NumGet(dib, 4, "UInt")
		, height := NumGet(dib, 8, "UInt")
		, bpp    := NumGet(dib, 18, "ushort")

	; Fallback to built-in method if pixels are not 32-bit ARGB.
	if (bpp != 32) { ; This built-in version is 120% faster but ignores transparency.
		DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hBitmap, "ptr", 0, "ptr*", &pBitmap:=0)
		return pBitmap
	}

	; Create a handle to a device context and associate the image.
	hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")             ; Creates a memory DC compatible with the current screen.
	obm := DllCall("SelectObject", "ptr", hdc, "ptr", hBitmap, "ptr") ; Put the (hBitmap) image onto the device context.

	; Create a device independent bitmap with negative height. All DIBs use the screen pixel format (pARGB).
	; Use hbm to buffer the image such that top-down and bottom-up images are mapped to this top-down buffer.
	cdc := DllCall("CreateCompatibleDC", "ptr", hdc, "ptr")
	bi := Buffer(40, 0)               ; sizeof(bi) = 40
	NumPut(
		"UInt", 	40, 	; Size
		"UInt", 	width,	; Width
		"Int", 		height, ; Height - Negative so (0, 0) is top-left.
		"ushort",	1, 		; Planes
		"ushort",	32, 	; BitCount / BitsPerPixel
		bi)
	hbm := DllCall("CreateDIBSection", "ptr", cdc, "ptr", bi.Ptr, "UInt", 0
				, "ptr*", &pBits:=0  ; pBits is the pointer to (top-down) pixel values.
				, "ptr", 0, "UInt", 0, "ptr")
	ob2 := DllCall("SelectObject", "ptr", cdc, "ptr", hbm, "ptr")

	; This is the 32-bit ARGB pBitmap (different from an hBitmap) that will receive the final converted pixels.
	DllCall("gdiplus\GdipCreateBitmapFromScan0"
				, "Int", width, "Int", height, "Int", 0, "Int", 0x26200A, "ptr", 0, "ptr*", &pBitmap:=0)

	; Create a Scan0 buffer pointing to pBits. The buffer has pixel format pARGB.
	Rect := Buffer(16, 0)              ; sizeof(Rect) = 16
	NumPut(
		"UInt",   width,	; Width
		"UInt",  height,	; Height
		Rect, 8)

	BitmapData := Buffer(16+2*A_PtrSize, 0)     ; sizeof(BitmapData) = 24, 32
	NumPut(
		"UInt", width, 		; Width
		"UInt", height, 	; Height
		"Int",  4 * width,	; Stride
		"Int",  0xE200B, 	; PixelFormat
		"ptr",  pBits, 	 	; Scan0
		BitmapData)

	; Use LockBits to create a writable buffer that converts pARGB to ARGB.
	DllCall("gdiplus\GdipBitmapLockBits"
				,    "ptr", pBitmap
				,    "ptr", Rect.Ptr
				,   "UInt", 6            ; ImageLockMode.UserInputBuffer | ImageLockMode.WriteOnly
				,    "Int", 0xE200B      ; Format32bppPArgb
				,    "ptr", BitmapData.Ptr) ; Contains the pointer (pBits) to the hbm.

	; Copies the image (hBitmap) to a top-down bitmap. Removes bottom-up-ness if present.
	DllCall("gdi32\BitBlt"
				, "ptr", cdc, "Int", 0, "Int", 0, "Int", width, "Int", height
				, "ptr", hdc, "Int", 0, "Int", 0, "UInt", 0x00CC0020) ; SRCCOPY

	; Convert the pARGB pixels copied into the device independent bitmap (hbm) to ARGB.
	DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", BitmapData.Ptr)

	; Cleanup the buffer and device contexts.
	DllCall("SelectObject", "ptr", cdc, "ptr", ob2)
	DllCall("DeleteObject", "ptr", hbm)
	DllCall("DeleteDC",     "ptr", cdc)
	DllCall("SelectObject", "ptr", hdc, "ptr", obm)
	DllCall("DeleteDC",     "ptr", hdc)

	return pBitmap
}

;#####################################################################################

Gdip_CreateARGBHBITMAPFromBitmap(&pBitmap) {
	; This version is about 25% faster than Gdip_CreateHBITMAPFromBitmap().
	; Get Bitmap width and height.
	DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", &width:=0)
	DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", &height:=0)

	; Convert the source pBitmap into a hBitmap manually.
	; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
	hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
	bi := Buffer(40, 0)               ; sizeof(bi) = 40
	NumPut(
		"UInt",     40,  		; Size
		"UInt",    	width,  	; Width
		"Int",  	-height,	; Height - Negative so (0, 0) is top-left.
		"ushort",   1, 			; Planes
		"ushort",   32,  		; BitCount / BitsPerPixel
		bi)
	hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", bi.Ptr, "UInt", 0, "ptr*", &pBits:=0, "ptr", 0, "UInt", 0, "ptr")
	obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

	; Transfer data from source pBitmap to an hBitmap manually.
	Rect := Buffer(16, 0)              ; sizeof(Rect) = 16
	NumPut(
		"UInt",   width,	; Width
		"UInt",  height, 	; Height
		Rect, 8)
	BitmapData := Buffer(16+2*A_PtrSize, 0)     ; sizeof(BitmapData) = 24, 32
	NumPut(
		"UInt",     width, 	; Width
		"UInt",    height, 	; Height
		"Int",  4 * width, 	; Stride
		"Int",    0xE200B, 	; PixelFormat
		"ptr",      pBits, 	; Scan0
		BitmapData)
	DllCall("gdiplus\GdipBitmapLockBits"
				,    "ptr", pBitmap
				,    "ptr", Rect.Ptr
				,   "UInt", 5            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadOnly
				,    "Int", 0xE200B      ; Format32bppPArgb
				,    "ptr", BitmapData.Ptr) ; Contains the pointer (pBits) to the hbm.
	DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", BitmapData.Ptr)

	; Cleanup the hBitmap and device contexts.
	DllCall("SelectObject", "ptr", hdc, "ptr", obm)
	DllCall("DeleteDC",     "ptr", hdc)

	return hbm
}

;#####################################################################################

Gdip_CreateBitmapFromHICON(hIcon)
{
	DllCall("gdiplus\GdipCreateBitmapFromHICON", "UPtr", hIcon, "UPtr*", &pBitmap:=0)
	return pBitmap
}

;#####################################################################################

Gdip_CreateHICONFromBitmap(pBitmap)
{
	DllCall("gdiplus\GdipCreateHICONFromBitmap", "UPtr", pBitmap, "UPtr*", &hIcon:=0)
	return hIcon
}

;#####################################################################################

Gdip_CreateBitmap(Width, Height, Format:=0x26200A)
{
	DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", Width, "Int", Height, "Int", 0, "Int", Format, "UPtr", 0, "UPtr*", &pBitmap:=0)
	return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromClipboard()
{
	if !DllCall("IsClipboardFormatAvailable", "UInt", 8) {
		return -2
	}

	if !DllCall("OpenClipboard", "UPtr", 0) {
		return -1
	}

	hBitmap := DllCall("GetClipboardData", "UInt", 2, "UPtr")

	if !DllCall("CloseClipboard") {
		return -5
	}

	if !hBitmap {
		return -3
	}

	pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
	if (!pBitmap) {
		return -4
	}

	DeleteObject(hBitmap)

	return pBitmap
}

;#####################################################################################

Gdip_SetBitmapToClipboard(pBitmap)
{
	off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	oi := Buffer(A_PtrSize = 8 ? 104 : 84, 0)
	DllCall("GetObject", "UPtr", hBitmap, "Int", oi.Size, "UPtr", oi.Ptr)
	hdib := DllCall("GlobalAlloc", "UInt", 2, "UPtr", 40+NumGet(oi, off1, "UInt"), "UPtr")
	pdib := DllCall("GlobalLock", "UPtr", hdib, "UPtr")
	DllCall("RtlMoveMemory", "UPtr", pdib, "UPtr", oi.Ptr+off2, "UPtr", 40)
	DllCall("RtlMoveMemory", "UPtr", pdib+40, "UPtr", NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), "UPtr"), "UPtr", NumGet(oi, off1, "UInt"))
	DllCall("GlobalUnlock", "UPtr", hdib)
	DllCall("DeleteObject", "UPtr", hBitmap)
	DllCall("OpenClipboard", "UPtr", 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "UInt", 8, "UPtr", hdib)
	DllCall("CloseClipboard")
}

;#####################################################################################

Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format:=0x26200A)
{
	DllCall("gdiplus\GdipCloneBitmapArea"
					, "Float", x
					, "Float", y
					, "Float", w
					, "Float", h
					, "Int", Format
					, "UPtr", pBitmap
					, "UPtr*", &pBitmapDest:=0)
	return pBitmapDest
}

;#####################################################################################
; Create resources
;#####################################################################################

Gdip_CreatePen(ARGB, w)
{
	DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "Float", w, "Int", 2, "UPtr*", &pPen:=0)
	return pPen
}

;#####################################################################################

Gdip_CreatePenFromBrush(pBrush, w)
{
	DllCall("gdiplus\GdipCreatePen2", "UPtr", pBrush, "Float", w, "Int", 2, "UPtr*", &pPen:=0)
	return pPen
}

;#####################################################################################

Gdip_BrushCreateSolid(ARGB:=0xff000000)
{
	DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, "UPtr*", &pBrush:=0)
	return pBrush
}

;#####################################################################################

; HatchStyleHorizontal = 0
; HatchStyleVertical = 1
; HatchStyleForwardDiagonal = 2
; HatchStyleBackwardDiagonal = 3
; HatchStyleCross = 4
; HatchStyleDiagonalCross = 5
; HatchStyle05Percent = 6
; HatchStyle10Percent = 7
; HatchStyle20Percent = 8
; HatchStyle25Percent = 9
; HatchStyle30Percent = 10
; HatchStyle40Percent = 11
; HatchStyle50Percent = 12
; HatchStyle60Percent = 13
; HatchStyle70Percent = 14
; HatchStyle75Percent = 15
; HatchStyle80Percent = 16
; HatchStyle90Percent = 17
; HatchStyleLightDownwardDiagonal = 18
; HatchStyleLightUpwardDiagonal = 19
; HatchStyleDarkDownwardDiagonal = 20
; HatchStyleDarkUpwardDiagonal = 21
; HatchStyleWideDownwardDiagonal = 22
; HatchStyleWideUpwardDiagonal = 23
; HatchStyleLightVertical = 24
; HatchStyleLightHorizontal = 25
; HatchStyleNarrowVertical = 26
; HatchStyleNarrowHorizontal = 27
; HatchStyleDarkVertical = 28
; HatchStyleDarkHorizontal = 29
; HatchStyleDashedDownwardDiagonal = 30
; HatchStyleDashedUpwardDiagonal = 31
; HatchStyleDashedHorizontal = 32
; HatchStyleDashedVertical = 33
; HatchStyleSmallConfetti = 34
; HatchStyleLargeConfetti = 35
; HatchStyleZigZag = 36
; HatchStyleWave = 37
; HatchStyleDiagonalBrick = 38
; HatchStyleHorizontalBrick = 39
; HatchStyleWeave = 40
; HatchStylePlaid = 41
; HatchStyleDivot = 42
; HatchStyleDottedGrid = 43
; HatchStyleDottedDiamond = 44
; HatchStyleShingle = 45
; HatchStyleTrellis = 46
; HatchStyleSphere = 47
; HatchStyleSmallGrid = 48
; HatchStyleSmallCheckerBoard = 49
; HatchStyleLargeCheckerBoard = 50
; HatchStyleOutlinedDiamond = 51
; HatchStyleSolidDiamond = 52
; HatchStyleTotal = 53
Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle:=0)
{
	DllCall("gdiplus\GdipCreateHatchBrush", "Int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, "UPtr*", &pBrush:=0)
	return pBrush
}

;#####################################################################################

Gdip_CreateTextureBrush(pBitmap, WrapMode:=1, x:=0, y:=0, w:="", h:="")
{
	if !(w && h) {
		DllCall("gdiplus\GdipCreateTexture", "UPtr", pBitmap, "Int", WrapMode, "UPtr*", &pBrush:=0)
	} else {
		DllCall("gdiplus\GdipCreateTexture2", "UPtr", pBitmap, "Int", WrapMode, "Float", x, "Float", y, "Float", w, "Float", h, "UPtr*", &pBrush:=0)
	}

	return pBrush
}

;#####################################################################################

; WrapModeTile = 0
; WrapModeTileFlipX = 1
; WrapModeTileFlipY = 2
; WrapModeTileFlipXY = 3
; WrapModeClamp = 4
Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode:=1)
{
	CreatePointF(&PointF1:="", x1, y1), CreatePointF(&PointF2:="", x2, y2)
	DllCall("gdiplus\GdipCreateLineBrush", "UPtr", PointF1.Ptr, "UPtr", PointF2.Ptr, "UInt", ARGB1, "UInt", ARGB2, "Int", WrapMode, "UPtr*", &LGpBrush:=0)
	return LGpBrush
}

;#####################################################################################

; LinearGradientModeHorizontal = 0
; LinearGradientModeVertical = 1
; LinearGradientModeForwardDiagonal = 2
; LinearGradientModeBackwardDiagonal = 3
Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode:=1, WrapMode:=1)
{
	CreateRectF(&RectF:="", x, y, w, h)
	DllCall("gdiplus\GdipCreateLineBrushFromRect", "UPtr", RectF.Ptr, "Int", ARGB1, "Int", ARGB2, "Int", LinearGradientMode, "Int", WrapMode, "UPtr*", &LGpBrush:=0)
	return LGpBrush
}

;#####################################################################################

Gdip_CloneBrush(pBrush)
{
	DllCall("gdiplus\GdipCloneBrush", "UPtr", pBrush, "UPtr*", &pBrushClone:=0)
	return pBrushClone
}

;#####################################################################################
; Delete resources
;#####################################################################################

Gdip_DeletePen(pPen)
{
	return DllCall("gdiplus\GdipDeletePen", "UPtr", pPen)
}

;#####################################################################################

Gdip_DeleteBrush(pBrush)
{
	return DllCall("gdiplus\GdipDeleteBrush", "UPtr", pBrush)
}

;#####################################################################################

Gdip_DisposeImage(pBitmap)
{
	return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

;#####################################################################################

Gdip_DeleteGraphics(pGraphics)
{
	return DllCall("gdiplus\GdipDeleteGraphics", "UPtr", pGraphics)
}

;#####################################################################################

Gdip_DisposeImageAttributes(ImageAttr)
{
	return DllCall("gdiplus\GdipDisposeImageAttributes", "UPtr", ImageAttr)
}

;#####################################################################################

Gdip_DeleteFont(hFont)
{
	return DllCall("gdiplus\GdipDeleteFont", "UPtr", hFont)
}

;#####################################################################################

Gdip_DeleteStringFormat(hFormat)
{
	return DllCall("gdiplus\GdipDeleteStringFormat", "UPtr", hFormat)
}

;#####################################################################################

Gdip_DeleteFontFamily(hFamily)
{
	return DllCall("gdiplus\GdipDeleteFontFamily", "UPtr", hFamily)
}

;#####################################################################################

Gdip_DeleteMatrix(Matrix)
{
	return DllCall("gdiplus\GdipDeleteMatrix", "UPtr", Matrix)
}

;#####################################################################################
; Text functions
;#####################################################################################

Gdip_TextToGraphics(pGraphics, Text, Options, Font:="Arial", Width:="", Height:="", Measure:=0)
{
	IWidth := Width
	IHeight := Height
	PassBrush := 0
	Text := String(Text)


	pattern_opts := "i)"
	RegExMatch(Options, pattern_opts "X([\-\d\.]+)(p*)", &xpos:="")
	RegExMatch(Options, pattern_opts "Y([\-\d\.]+)(p*)", &ypos:="")
	RegExMatch(Options, pattern_opts "W([\-\d\.]+)(p*)", &Width:="")
	RegExMatch(Options, pattern_opts "H([\-\d\.]+)(p*)", &Height:="")
	RegExMatch(Options, pattern_opts "C(?!(entre|enter))([a-f\d]+)", &Colour:="")
	RegExMatch(Options, pattern_opts "Top|Up|Bottom|Down|vCentre|vCenter", &vPos:="")
	RegExMatch(Options, pattern_opts "NoWrap", &NoWrap:="")
	RegExMatch(Options, pattern_opts "R(\d)", &Rendering:="")
	RegExMatch(Options, pattern_opts "S(\d+)(p*)", &Size:="")

	if Colour && IsInteger(Colour[2]) && !Gdip_DeleteBrush(Gdip_CloneBrush(Colour[2])) {
		PassBrush := 1, pBrush := Colour[2]
	}

	if !(IWidth && IHeight) && ((xpos && xpos[2]) || (ypos && ypos[2]) || (Width && Width[2]) || (Height && Height[2]) || (Size && Size[2])) {
		return -1
	}

	Style := 0
	Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	for eachStyle, valStyle in StrSplit( Styles, "|" ) {
		if RegExMatch(Options, "\b" valStyle)
			Style |= (valStyle != "StrikeOut") ? (A_Index-1) : 8
	}

	Align := 0
	Alignments := "Near|Left|Centre|Center|Far|Right"
	for eachAlignment, valAlignment in StrSplit( Alignments, "|" ) {
		if RegExMatch(Options, "\b" valAlignment) {
			Align |= A_Index*10//21	; 0|0|1|1|2|2
		}
	}

	xpos := (xpos && (xpos[1] != "")) ? xpos[2] ? IWidth*(xpos[1]/100) : xpos[1] : 0
	ypos := (ypos && (ypos[1] != "")) ? ypos[2] ? IHeight*(ypos[1]/100) : ypos[1] : 0
	Width := (Width && Width[1]) ? Width[2] ? IWidth*(Width[1]/100) : Width[1] : IWidth
	Height := (Height && Height[1]) ? Height[2] ? IHeight*(Height[1]/100) : Height[1] : IHeight

	if !PassBrush {
		Colour := "0x" (Colour && Colour[2] ? Colour[2] : "ff000000")
	}

	Rendering := (Rendering && (Rendering[1] >= 0) && (Rendering[1] <= 5)) ? Rendering[1] : 4
	Size := (Size && (Size[1] > 0)) ? Size[2] ? IHeight*(Size[1]/100) : Size[1] : 12

	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, Size, Style)
	FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
	hFormat := Gdip_StringFormatCreate(FormatStyle)
	pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)

	if !(hFamily && hFont && hFormat && pBrush && pGraphics) {
		return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
	}

	CreateRectF(&RC:="", xpos, ypos, Width, Height)
	Gdip_SetStringFormatAlign(hFormat, Align)
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, &RC)

	if vPos {
		ReturnRC := StrSplit(ReturnRC, "|")

		if (vPos[0] = "vCentre") || (vPos[0] = "vCenter")
			ypos += Floor(Height-ReturnRC[4])//2
		else if (vPos[0] = "Top") || (vPos[0] = "Up")
			ypos := 0
		else if (vPos[0] = "Bottom") || (vPos[0] = "Down")
			ypos := Height-ReturnRC[4]

		CreateRectF(&RC, xpos, ypos, Width, ReturnRC[4])
		ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, &RC)
	}

	if !Measure {
		Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, &RC)
	}

	if !PassBrush {
		Gdip_DeleteBrush(pBrush)
	}

	Gdip_DeleteStringFormat(hFormat)
	Gdip_DeleteFont(hFont)
	Gdip_DeleteFontFamily(hFamily)

	return ReturnRC
}

;#####################################################################################

Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, &RectF)
{
	return DllCall("gdiplus\GdipDrawString"
					, "UPtr", pGraphics
					, "UPtr", StrPtr(sString)
					, "Int", -1
					, "UPtr", hFont
					, "UPtr", RectF.Ptr
					, "UPtr", hFormat
					, "UPtr", pBrush)
}

;#####################################################################################

Gdip_MeasureString(pGraphics, sString, hFont, hFormat, &RectF)
{
	RC := Buffer(16)
	DllCall("gdiplus\GdipMeasureString"
					, "UPtr", pGraphics
					, "UPtr", StrPtr(sString)
					, "Int", -1
					, "UPtr", hFont
					, "UPtr", RectF.Ptr
					, "UPtr", hFormat
					, "UPtr", RC.Ptr
					, "uint*", &Chars:=0
					, "uint*", &Lines:=0)

	return RC.Ptr ? NumGet(RC, 0, "Float") "|" NumGet(RC, 4, "Float") "|" NumGet(RC, 8, "Float") "|" NumGet(RC, 12, "Float") "|" Chars "|" Lines : 0
}

; Near = 0
; Center = 1
; Far = 2
Gdip_SetStringFormatAlign(hFormat, Align)
{
	return DllCall("gdiplus\GdipSetStringFormatAlign", "UPtr", hFormat, "Int", Align)
}

; StringFormatFlagsDirectionRightToLeft    = 0x00000001
; StringFormatFlagsDirectionVertical       = 0x00000002
; StringFormatFlagsNoFitBlackBox           = 0x00000004
; StringFormatFlagsDisplayFormatControl    = 0x00000020
; StringFormatFlagsNoFontFallback          = 0x00000400
; StringFormatFlagsMeasureTrailingSpaces   = 0x00000800
; StringFormatFlagsNoWrap                  = 0x00001000
; StringFormatFlagsLineLimit               = 0x00002000
; StringFormatFlagsNoClip                  = 0x00004000
Gdip_StringFormatCreate(Format:=0, Lang:=0)
{
	DllCall("gdiplus\GdipCreateStringFormat", "Int", Format, "Int", Lang, "UPtr*", &hFormat:=0)
	return hFormat
}

; Regular = 0
; Bold = 1
; Italic = 2
; BoldItalic = 3
; Underline = 4
; Strikeout = 8
Gdip_FontCreate(hFamily, Size, Style:=0)
{
	DllCall("gdiplus\GdipCreateFont", "UPtr", hFamily, "Float", Size, "Int", Style, "Int", 0, "UPtr*", &hFont:=0)
	return hFont
}

Gdip_FontFamilyCreate(Font)
{
	DllCall("gdiplus\GdipCreateFontFamilyFromName"
					, "UPtr", StrPtr(Font)
					, "UInt", 0
					, "UPtr*", &hFamily:=0)

	return hFamily
}

;#####################################################################################
; Matrix functions
;#####################################################################################

Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
{
	DllCall("gdiplus\GdipCreateMatrix2", "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", x, "Float", y, "UPtr*", &Matrix:=0)
	return Matrix
}

Gdip_CreateMatrix()
{
	DllCall("gdiplus\GdipCreateMatrix", "UPtr*", &Matrix:=0)
	return Matrix
}

;#####################################################################################
; GraphicsPath functions
;#####################################################################################

; Alternate = 0
; Winding = 1
Gdip_CreatePath(BrushMode:=0)
{
	DllCall("gdiplus\GdipCreatePath", "Int", BrushMode, "UPtr*", &pPath:=0)
	return pPath
}

Gdip_AddPathEllipse(pPath, x, y, w, h)
{
	return DllCall("gdiplus\GdipAddPathEllipse", "UPtr", pPath, "Float", x, "Float", y, "Float", w, "Float", h)
}

Gdip_AddPathPolygon(pPath, Points)
{
	PointsLength := Points.Length
	PointF := Buffer(8*PointsLength)
	for Point in Points
	{
		NumPut("Float", Point[1], PointF, 8*(A_Index-1))
		NumPut("Float", Point[2], PointF, (8*(A_Index-1))+4)
	}

	return DllCall("gdiplus\GdipAddPathPolygon", "UPtr", pPath, "UPtr", PointF.Ptr, "Int", PointsLength)
}

Gdip_AddPathArc(pPath, x, y, w, h, StartAngle, SweepAngle) {
	return DllCall("gdiplus\GdipAddPathArc", "UPtr", pPath, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

Gdip_AddPathRoundedRectangle(pPath, x, y, w, h, r) {
	; extracted from: https://github.com/tariqporter/Gdip2/blob/master/lib/Object.ahk
	; and adapted by Marius Șucan

	; Create a rounded rectabgle
	D := (R * 2), W -= D, H -= D
	Gdip_AddPathArc(pPath, X, Y, D, D, 180, 90)
	Gdip_AddPathArc(pPath, X+W, Y, D, D, 270, 90)
	Gdip_AddPathArc(pPath, X+W, Y+H, D, D, 0, 90)
	Gdip_AddPathArc(pPath, X, Y+H, D, D, 90, 90)
	Gdip_ClosePathFigure(pPath)

	Return
}

Gdip_ClosePathFigure(pPath, all:=0) {
	; Closes the current figure of this path.
	If (all=1)
		return DllCall("gdiplus\GdipClosePathFigures", "UPtr", pPath)
	Else
		return DllCall("gdiplus\GdipClosePathFigure", "UPtr", pPath)
}

Gdip_DeletePath(pPath)
{
	return DllCall("gdiplus\GdipDeletePath", "UPtr", pPath)
}

;#####################################################################################
; Quality functions
;#####################################################################################

; SystemDefault = 0
; SingleBitPerPixelGridFit = 1
; SingleBitPerPixel = 2
; AntiAliasGridFit = 3
; AntiAlias = 4
Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
	return DllCall("gdiplus\GdipSetTextRenderingHint", "UPtr", pGraphics, "Int", RenderingHint)
}

; Default = 0
; LowQuality = 1
; HighQuality = 2
; Bilinear = 3
; Bicubic = 4
; NearestNeighbor = 5
; HighQualityBilinear = 6
; HighQualityBicubic = 7
Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
{
	return DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", pGraphics, "Int", InterpolationMode)
}

; Default = 0
; HighSpeed = 1
; HighQuality = 2
; None = 3
; AntiAlias = 4
Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
	return DllCall("gdiplus\GdipSetSmoothingMode", "UPtr", pGraphics, "Int", SmoothingMode)
}

; CompositingModeSourceOver = 0 (blended)
; CompositingModeSourceCopy = 1 (overwrite)
Gdip_SetCompositingMode(pGraphics, CompositingMode:=0)
{
	return DllCall("gdiplus\GdipSetCompositingMode", "UPtr", pGraphics, "Int", CompositingMode)
}

;#####################################################################################
; Extra functions
;#####################################################################################

Gdip_Startup()
{
	if (!DllCall("LoadLibrary", "str", "gdiplus", "UPtr")) {
		throw Error("Could not load GDI+ library")
	}

	si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
	NumPut("UInt", 1, si)
	DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.Ptr, "UPtr", 0)
	if (!pToken) {
		throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
	}

	return pToken
}

Gdip_Shutdown(pToken)
{
	DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
	hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
	if (!hModule) {
		throw Error("GDI+ library was unloaded before shutdown")
	}
	if (!DllCall("FreeLibrary", "UPtr", hModule)) {
		throw Error("Could not free GDI+ library")
	}

	return 0
}

; Prepend = 0; The new operation is applied before the old operation.
; Append = 1; The new operation is applied after the old operation.
Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder:=0)
{
	return DllCall("gdiplus\GdipRotateWorldTransform", "UPtr", pGraphics, "Float", Angle, "Int", MatrixOrder)
}

Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder:=0)
{
	return DllCall("gdiplus\GdipScaleWorldTransform", "UPtr", pGraphics, "Float", x, "Float", y, "Int", MatrixOrder)
}

Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder:=0)
{
	return DllCall("gdiplus\GdipTranslateWorldTransform", "UPtr", pGraphics, "Float", x, "Float", y, "Int", MatrixOrder)
}

Gdip_ResetWorldTransform(pGraphics)
{
	return DllCall("gdiplus\GdipResetWorldTransform", "UPtr", pGraphics)
}

Gdip_GetRotatedTranslation(Width, Height, Angle, &xTranslation, &yTranslation)
{
	pi := 3.14159, TAngle := Angle*(pi/180)

	Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
	if ((Bound >= 0) && (Bound <= 90)) {
		xTranslation := Height*Sin(TAngle), yTranslation := 0
	} else if ((Bound > 90) && (Bound <= 180)) {
		xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
	} else if ((Bound > 180) && (Bound <= 270)) {
		xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
	} else if ((Bound > 270) && (Bound <= 360)) {
		xTranslation := 0, yTranslation := -Width*Sin(TAngle)
	}
}

Gdip_GetRotatedDimensions(Width, Height, Angle, &RWidth, &RHeight)
{
	pi := 3.14159, TAngle := Angle*(pi/180)

	if !(Width && Height) {
		return -1
	}

	RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
	RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}

; RotateNoneFlipNone   = 0
; Rotate90FlipNone     = 1
; Rotate180FlipNone    = 2
; Rotate270FlipNone    = 3
; RotateNoneFlipX      = 4
; Rotate90FlipX        = 5
; Rotate180FlipX       = 6
; Rotate270FlipX       = 7
; RotateNoneFlipY      = Rotate180FlipX
; Rotate90FlipY        = Rotate270FlipX
; Rotate180FlipY       = RotateNoneFlipX
; Rotate270FlipY       = Rotate90FlipX
; RotateNoneFlipXY     = Rotate180FlipNone
; Rotate90FlipXY       = Rotate270FlipNone
; Rotate180FlipXY      = RotateNoneFlipNone
; Rotate270FlipXY      = Rotate90FlipNone

Gdip_ImageRotateFlip(pBitmap, RotateFlipType:=1)
{
	return DllCall("gdiplus\GdipImageRotateFlip", "UPtr", pBitmap, "Int", RotateFlipType)
}

; Replace = 0
; Intersect = 1
; Union = 2
; Xor = 3
; Exclude = 4
; Complement = 5
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode:=0)
{
	return DllCall("gdiplus\GdipSetClipRect",  "UPtr", pGraphics, "Float", x, "Float", y, "Float", w, "Float", h, "Int", CombineMode)
}

Gdip_SetClipPath(pGraphics, pPath, CombineMode:=0)
{
	return DllCall("gdiplus\GdipSetClipPath", "UPtr", pGraphics, "UPtr", pPath, "Int", CombineMode)
}

Gdip_ResetClip(pGraphics)
{
	return DllCall("gdiplus\GdipResetClip", "UPtr", pGraphics)
}

Gdip_GetClipRegion(pGraphics)
{
	Region := Gdip_CreateRegion()
	DllCall("gdiplus\GdipGetClip", "UPtr", pGraphics, "UInt", Region)
	return Region
}

Gdip_SetClipRegion(pGraphics, Region, CombineMode:=0)
{
	return DllCall("gdiplus\GdipSetClipRegion", "UPtr", pGraphics, "UPtr", Region, "Int", CombineMode)
}

Gdip_CreateRegion()
{
	DllCall("gdiplus\GdipCreateRegion", "UInt*", &Region:=0)
	return Region
}

Gdip_DeleteRegion(Region)
{
	return DllCall("gdiplus\GdipDeleteRegion", "UPtr", Region)
}

; The following functions are not in the original library, they have been added for compatibility.
; Their original code can be found at https://github.com/marius-sucan/AHK-GDIp-Library-Compilation
Gdip_BitmapConvertGray(pBitmap, hue:=0, vibrance:=-40, brightness:=1, contrast:=0, KeepPixelFormat:=0) {
	; hue, vibrance, contrast and brightness parameters
	; influence the resulted new grayscale pBitmap.
	;
	; KeepPixelFormat can receive a specific PixelFormat.
	; The function returns a pointer to a new pBitmap.

	Gdip_GetImageDimensions(pBitmap, &Width, &Height)
	PixelFormat := 0x26200A
	If (KeepPixelFormat=1)
		PixelFormat := Format("{1:#x}", Gdip_GetImagePixelFormat(pBitmap))
	If StrLen(KeepPixelFormat)>3
		PixelFormat := KeepPixelFormat
	Else If (KeepPixelFormat=-1)
		PixelFormat := 0xE200B

	newBitmap := Gdip_CreateBitmap(Width, Height, PixelFormat)
	G := Gdip_GraphicsFromImage(newBitmap)
	If (hue!=0 || vibrance!=0)
	{
		nBitmap := Gdip_CloneBitmap(pBitmap)
		pEffect := Gdip_CreateEffect(6, hue, vibrance, 0)
		Gdip_BitmapApplyEffect(nBitmap, pEffect)
		Gdip_DisposeEffect(pEffect)
	}

	matrix := GenerateColorMatrix(2, brightness, contrast)
	fBitmap := StrLen(nBitmap)>2 ? nBitmap : pBitmap
	Gdip_DrawImage(G, fBitmap, 0, 0, Width, Height, 0, 0, Width, Height, matrix)
	Gdip_DeleteGraphics(G)
	If (nBitmap=fBitmap)
		Gdip_DisposeImage(nBitmap)

	Return newBitmap
}

Gdip_CloneBitmap(pBitmap) {
	DllCall("gdiplus\GdipCloneImage", "UPtr", pBitmap, "UPtr*", &pBitmapDest:=0)
	return pBitmapDest
 }

 Gdip_BitmapApplyEffect(pBitmap, pEffect, x:="", y:="", w:="", h:="") {
	; X, Y   - coordinates for the rectangle where the effect is applied
	; W, H   - width and heigh for the rectangle where the effect is applied
	; If X, Y, W or H are omitted , the effect is applied on the entire pBitmap
	;
	; written by Marius Șucan
	; many thanks to Drugwash for the help provided
	If (InStr(pEffect, "err-") || !pEffect || !pBitmap)
		Return 2

	If (!x && !y && !w && !h)
		none := 1
	Else
		CreateRectF(&Rect, x, y, x + w, y + h)

	E := DllCall("gdiplus\GdipBitmapApplyEffect"
		, "UPtr", pBitmap
		, "UPtr", pEffect
		, "UPtr", (none=1) ? 0 : &Rect
		, "UPtr", 0     ; useAuxData
		, "UPtr", 0     ; auxData
		, "UPtr", 0)    ; auxDataSize
	Return E
}

COM_CLSIDfromString(&CLSID, String) {
	CLSID := Buffer(16)
    Return DllCall("ole32\CLSIDFromString", "WStr", String, "UPtr", CLSID.Ptr)
}

Gdip_CreateEffect(whichFX, paramA, paramB, paramC:=0) {
/*
	whichFX options:
	1 - Blur
			paramA - radius [0, 255]
			paramB - bool [0, 1]
	2 - Sharpen
			paramA - radius [0, 255]
			paramB - amount [0, 100]
	3 - ColorMatrix
			paramA - color matrix example:
					matrixBright := "1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1"
	4 - ! ColorLUT
	5 - BrightnessContrast
			paramA - brightness [-255, 255]
			paramB - contrast [-100, 100]
	6 - HueSaturationLightness
			paramA - hue [-180, 180]
			paramB - saturation [-100, 100]
			paramC - light [-100, 100]
	7 - LevelsAdjust
			paramA - highlights [0, 100]
			paramB - midtones [-100, 100]
			paramC - shadows [0, 100]
	8 - Tint
			paramA - hue [-180, 180]
			paramB - amount [0, 100]
	9 - ColorBalance
			paramA - Cyan / Red [-100, 100]
			paramB - Magenta / Green [-100, 100]
			paramC - Yellow / Blue [-100, 100]
	10 - ! RedEyeCorrection
	11 - ColorCurve
			paramA - Type of adjustments [0, 7]
					0 - AdjustExposure         [-255, 255]
					1 - AdjustDensity          [-255, 255]
					2 - AdjustContrast         [-100, 100]
					3 - AdjustHighlight        [-100, 100]
					4 - AdjustShadow           [-100, 100]
					5 - AdjustMidtone          [-100, 100]
					6 - AdjustWhiteSaturation  [0, 255]
					7 - AdjustBlackSaturation  [0, 255]

			paramB - Apply ColorCurve on channels [1, 4]
					1 - Red
					2 - Green
					3 - Blue
					4 - All channels

			paramC - An adjust value within range according to paramA

	Effects marked with "!" are not yet implemented.
	Through ParamA, ParamB and ParamC, the effects can be controlled.
	Function written by Marius Șucan. Many thanks to Drugwash for the help provided,
*/

	Static gdipImgFX := ["633C80A4-1843-482b-9EF2-BE2834C5FDD4", "63CBF3EE-C526-402c-8F71-62C540BF5142", "718F2615-7933-40e3-A511-5F68FE14DD74", "A7CE72A9-0F7F-40d7-B3CC-D0C02D5C3212", "D3A1DBE1-8EC4-4c17-9F4C-EA97AD1C343D", "8B2DD6C3-EB07-4d87-A5F0-7108E26A9C5F", "99C354EC-2A31-4f3a-8C34-17A803B33A25", "1077AF00-2848-4441-9489-44AD4C2D7A2C", "537E597D-251E-48da-9664-29CA496B70F8", "74D29D05-69A4-4266-9549-3CC52836B632", "DD6A0022-58E4-4a67-9D9B-D48EB881A53D"]
	pEffect := 0
	r1 := COM_CLSIDfromString(&eFXguid:=0, "{" gdipImgFX[whichFX] "}" )
	If r1
		Return "err-" r1

	If (A_PtrSize=4) ; 32 bits
	{
		r2 := DllCall("gdiplus\GdipCreateEffect"
			, "UInt", NumGet(eFXguid, 0, "UInt")
			, "UInt", NumGet(eFXguid, 4, "UInt")
			, "UInt", NumGet(eFXguid, 8, "UInt")
			, "UInt", NumGet(eFXguid, 12, "UInt")
			, "Ptr*", &pEffect)
	} Else
	{
		r2 := DllCall("gdiplus\GdipCreateEffect"
			, "UPtr", eFXguid.Ptr
			, "Ptr*", &pEffect)
	}
	If r2
		Return "err-" r2

	; r2 := GetStatus(A_LineNumber ":GdipCreateEffect", r2)
	;If (whichFX=3)  ; Color matrix
	;	CreateColourMatrix(paramA, FXparams)
	;Else
		FXparams := Buffer(12)

	If (whichFX=1)   ; Blur FX
	{
		If (paramA>255)
			paramA := 255
		FXsize := 8
		NumPut("Float", paramA, FXparams)   ; radius [0, 255]
		NumPut("Uchar", paramB, FXparams, 4)   ; bool 0, 1
	} Else If (whichFX=3)   ; Color matrix
	{
		FXsize := 100
	} Else If (whichFX=2)   ; Sharpen FX
	{
		FXsize := 8
		NumPut("Float", paramA, FXparams)   ; radius [0, 255]
		NumPut("Float", paramB, FXparams, 4)   ; amount [0, 100]
	} Else If (whichFX=5)   ; Brightness / Contrast
	{
		FXsize := 8
		NumPut("Int", paramA, FXparams)     ; brightness [-255, 255]
		NumPut("Int", paramB, FXparams, 4)     ; contrast [-100, 100]
	} Else If (whichFX=6)   ; Hue / Saturation / Lightness
	{
		FXsize := 12
		NumPut("Int", paramA, FXparams)     ; hue [-180, 180]
		NumPut("Int", paramB, FXparams, 4)     ; saturation [-100, 100]
		NumPut("Int", paramC, FXparams, 8)     ; light [-100, 100]
	} Else If (whichFX=7)   ; Levels adjust
	{
		FXsize := 12
		NumPut("Int", paramA, FXparams)     ; highlights [0, 100]
		NumPut("Int", paramB, FXparams, 4)     ; midtones [-100, 100]
		NumPut("Int", paramC, FXparams, 8)     ; shadows [0, 100]
	} Else If (whichFX=8)   ; Tint adjust
	{
		FXsize := 8
		NumPut("Int", paramA, FXparams)     ; hue [180, 180]
		NumPut("Int", paramB, FXparams, 4)     ; amount [0, 100]
	} Else If (whichFX=9)   ; Colors balance
	{
		FXsize := 12
		NumPut("Int", paramA, FXparams)     ; Cyan / Red [-100, 100]
		NumPut("Int", paramB, FXparams, 4)     ; Magenta / Green [-100, 100]
		NumPut("Int", paramC, FXparams, 8)     ; Yellow / Blue [-100, 100]
	} Else If (whichFX=11)   ; ColorCurve
	{
		FXsize := 12
		NumPut("Int", paramA, FXparams)     ; Type of adjustment [0, 7]
		NumPut("Int", paramB, FXparams, 4)     ; Channels to affect [1, 4]
		NumPut("Int", paramC, FXparams, 8)     ; Adjustment value [based on the type of adjustment]
	}

	; DllCall("gdiplus\GdipGetEffectParameterSize", "UPtr", pEffect, "uint*", FXsize)
	r3 := DllCall("gdiplus\GdipSetEffectParameters", "UPtr", pEffect, "UPtr", FXparams.Ptr, "UInt", FXsize)
	If r3
	{
		Gdip_DisposeEffect(pEffect)
		Return "err-" r3
	}
	; r3 := GetStatus(A_LineNumber ":GdipSetEffectParameters", r3)
	; ToolTip, % r1 " -- " r2 " -- " r3 " -- " r4,,, 2
	Return pEffect
}

Gdip_DisposeEffect(pEffect) {
	If (pEffect && !InStr(pEffect, "err"))
		r := DllCall("gdiplus\GdipDeleteEffect", "UPtr", pEffect)
	Return r
}

GenerateColorMatrix(modus, bright:=1, contrast:=0, saturation:=1, alph:=1, chnRdec:=0, chnGdec:=0, chnBdec:=0) {
; parameters ranges / intervals:
; bright:     [0.001 - 20.0]
; contrast:   [-20.0 - 1.00]
; saturation: [0.001 - 5.00]
; alph:       [0.001 - 5.00]
;
; modus options:
; 0 - personalized colors based on the bright, contrast [hue], saturation parameters
; 1 - personalized colors based on the bright, contrast, saturation parameters
; 2 - grayscale image
; 3 - grayscale R channel
; 4 - grayscale G channel
; 5 - grayscale B channel
; 6 - negative / invert image
; 7 - alpha channel as grayscale image
; 8 - sepia
;
; chnRdec, chnGdec, chnBdec only apply in modus=1
; these represent offsets for the RGB channels

; in modus=0 the parameters have other ranges:
; bright:     [-5.00 - 5.00]
; hue:        [-1.57 - 1.57]  ; pi/2 - contrast stands for hue in this mode
; saturation: [0.001 - 5.00]
; formulas for modus=0 were written by Smurth
; extracted from https://autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/page-86
;
; function written by Marius Șucan
; infos from http://www.graficaobscura.com/matrix/index.html
; NTSC // CCIR 601 luma RGB weights:
; r := 0.29970, g := 0.587130, b := 0.114180

	Static NTSCr := 0.308, NTSCg := 0.650, NTSCb := 0.095   ; personalized values
	matrix := ""

	If (modus=2)       ; grayscale
	{
		LGA := (bright<=1) ? bright/1.5 - 0.6666 : bright - 1
		Ra := NTSCr + LGA
		If (Ra<0)
			Ra := 0
		Ga := NTSCg + LGA
		If (Ga<0)
			Ga := 0
		Ba := NTSCb + LGA
		If (Ba<0)
			Ba := 0
		matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|" alph "|0|" contrast "|" contrast "|" contrast "|0|1"
	} Else If (modus=3)       ; grayscale R
	{
		Ga := 0, Ba := 0, GGA := 0
		Ra := bright
		matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|" alph "|0|" GGA+0.01 "|" GGA "|" GGA "|0|1"
	} Else If (modus=4)       ; grayscale G
	{
		Ra := 0, Ba := 0, GGA := 0
		Ga := bright
		matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|" alph "|0|" GGA "|" GGA+0.01 "|" GGA "|0|1"
	} Else If (modus=5)       ; grayscale B
	{
		Ra := 0, Ga := 0, GGA := 0
		Ba := bright
		matrix := Ra "|" Ra "|" Ra "|0|0|" Ga "|" Ga "|" Ga "|0|0|" Ba "|" Ba "|" Ba "|0|0|0|0|0|" alph "|0|" GGA "|" GGA "|" GGA+0.01 "|0|1"
	} Else If (modus=6)  ; negative / invert
	{
		matrix := "-1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|" alph "|0|1|1|1|0|1"
	} Else If (modus=1)   ; personalized saturation, contrast and brightness
	{
		bL := bright, aL := alph
		G := contrast, sL := saturation
		sLi := 1 - saturation
		bLa := bright - 1
		If (sL>1)
		{
			z := (bL<1) ? bL : 1
			sL := sL*z
			If (sL<0.98)
				sL := 0.98

			y := z*(1 - sL)
			mA := z*(y*NTSCr + sL + bLa + chnRdec)
			mB := z*(y*NTSCr)
			mC := z*(y*NTSCr)
			mD := z*(y*NTSCg)
			mE := z*(y*NTSCg + sL + bLa + chnGdec)
			mF := z*(y*NTSCg)
			mG := z*(y*NTSCb)
			mH := z*(y*NTSCb)
			mI := z*(y*NTSCb + sL + bLa + chnBdec)
			mtrx:= mA "|" mB "|" mC "|  0   |0"
			. "|" mD "|" mE "|" mF "|  0   |0"
			. "|" mG "|" mH "|" mI "|  0   |0"
			. "|  0   |  0   |  0   |" aL "|0"
			. "|" G  "|" G  "|" G  "|  0   |1"
		} Else
		{
			z := (bL<1) ? bL : 1
			tR := NTSCr - 0.5 + bL/2
			tG := NTSCg - 0.5 + bL/2
			tB := NTSCb - 0.5 + bL/2
			rB := z*(tR*sLi+bL*(1 - sLi) + chnRdec)
			gB := z*(tG*sLi+bL*(1 - sLi) + chnGdec)
			bB := z*(tB*sLi+bL*(1 - sLi) + chnBdec)     ; Formula used: A*w + B*(1 – w)
			rF := z*(NTSCr*sLi + (bL/2 - 0.5)*sLi)
			gF := z*(NTSCg*sLi + (bL/2 - 0.5)*sLi)
			bF := z*(NTSCb*sLi + (bL/2 - 0.5)*sLi)

			rB := rB*z+rF*(1 - z)
			gB := gB*z+gF*(1 - z)
			bB := bB*z+bF*(1 - z)     ; Formula used: A*w + B*(1 – w)
			If (rB<0)
				rB := 0
			If (gB<0)
				gB := 0
			If (bB<0)
				bB := 0
			If (rF<0)
				rF := 0

			If (gF<0)
				gF := 0

			If (bF<0)
				bF := 0

			; ToolTip, % rB " - " rF " --- " gB " - " gF
			mtrx:= rB "|" rF "|" rF "|  0   |0"
			. "|" gF "|" gB "|" gF "|  0   |0"
			. "|" bF "|" bF "|" bB "|  0   |0"
			. "|  0   |  0   |  0   |" aL "|0"
			. "|" G  "|" G  "|" G  "|  0   |1"
			; matrix adjusted for lisibility
		}
		matrix := StrReplace(mtrx, A_Space)
	} Else If (modus=0)   ; personalized hue, saturation and brightness
	{
		s1 := contrast   ; in this mode, contrast stands for hue
		s2 := saturation
		s3 := bright
		aL := alph

		s1 := s2*sin(s1)
		sc := 1-s2
		r := NTSCr*sc-s1
		g := NTSCg*sc-s1
		b := NTSCb*sc-s1

		rB := r+s2+3*s1
		gB := g+s2+3*s1
		bB := b+s2+3*s1
		mtrx :=   rB "|" r  "|" r  "|  0   |0"
			. "|" g  "|" gB "|" g  "|  0   |0"
			. "|" b  "|" b  "|" bB "|  0   |0"
			. "|  0   |  0   |  0   |" aL "|0"
			. "|" s3 "|" s3 "|" s3 "|  0   |1"
		matrix := StrReplace(mtrx, A_Space)
	} Else If (modus=7) ; alpha channel
	{
		matrix := "0|0|0|0|0"
				. "|0|0|0|0|0"
				. "|0|0|0|0|0"
				. "|1|1|1|25|0"
				. "|0|0|0|0|1"
		; matrix := StrReplace(mtrx, A_Space)
	} Else If (modus=8) ; sepia
	{
		matrix := "0.39|0.34|0.27|0|0"
				. "|0.76|0.58|0.33|0|0"
				. "|0.19|0.16|0.13|0|0"
				. "|0|0|0|" alph "|0"
				. "|0|0|0|0|1"
		; matrix := StrReplace(mtrx, A_Space)
	} Else If (modus=9) ; partial alpha channel remover
	{
		matrix := "1|0|0|0|0"
				. "|0|1|0|0|0"
				. "|0|0|1|0|0"
				. "|0|0|0|" alph "|0"
				. "|0|0|0|0|1"
		; matrix := StrReplace(mtrx, A_Space)
	}
	Return matrix
}

Gdip_CreateLinearGrBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode:=1, WrapMode:=1) {
	; WrapMode options [LinearGradientMode]:
	; Horizontal = 0
	; Vertical = 1
	; ForwardDiagonal = 2
	; BackwardDiagonal = 3
	CreateRectF(&RectF, x, y, w, h)
	DllCall("gdiplus\GdipCreateLineBrushFromRect", "UPtr", RectF.Ptr, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, "UPtr*", &pLinearGradientBrush:=0)
	return pLinearGradientBrush
}

Gdip_SetLinearGrBrushPresetBlend(pBrush, _positions, _colors, pathBrush:=0) {
	; function by TheArkive modified by Marius Șucan
	; the function accepts only arrays for _positions and _colors

	elements := _colors.Length
	If (elements>_positions.Length || elements<2)
		Return 2 ; invalid parameters

	_positions.InsertAt(1, 0.0), _positions.Push(1.0)
	_colors.Push(_colors[elements])
	_colors.InsertAt(1, _colors[1])
	elements := _colors.Length

	COLORS := Buffer(elements*4, 0)
	For i, _color in _colors
		NumPut("UInt", _color, COLORS, (i-1)*4)

	POSITIONS := Buffer(elements*4, 0)
	For i, _pos in _positions
		NumPut("Float", _pos, POSITIONS, (i-1)*4)

	func2exec := (pathBrush=1) ? "GdipSetPathGradientPresetBlend" : "GdipSetLinePresetBlend"
	Return DllCall("gdiplus\" func2exec, "UPtr", pBrush, "UPtr", COLORS.Ptr, "UPtr", POSITIONS.Ptr, "Int", elements)
}

Gdip_SetLinearGrBrushSigmaBlend(pBrush, nFocus, nScale) {
	return DllCall("gdiplus\GdipSetLineSigmaBlend", "UPtr", pBrush, "float", nFocus, "float", nScale)
}

Gdip_SetStringFormatTrimming(hStringFormat, TrimMode) {
	; TrimMode - The trimming style  to use:
	; 0 - Trim - No trimming is done
	; 1 - TrimChar - String is broken at the boundary of the last character that is inside the layout rectangle
	; 2 - TrimWord - String is broken at the boundary of the last word that is inside the layout rectangle
	; 3 - EllipsisChar - String is broken at the boundary of the last character that is inside the layout rectangle and an ellipsis (...) is inserted after the character
	; 4 - EllipsisWord - String is broken at the boundary of the last word that is inside the layout rectangle and an ellipsis (...) is inserted after the word
	; 5 - EllipsisMid - The center is removed from the string and replaced by an ellipsis. The algorithm keeps as much of the last portion of the string as possible

	return DllCall("gdiplus\GdipSetStringFormatTrimming", "UPtr", hStringFormat, "int", TrimMode)
}

Gdip_AddPathString(pPath, String, hFontFamily, Style, Size, hStringFormat, X, Y, W, H) {
	CreateRectF(&RectF, X, Y, W, H)
	Return DllCall("gdiplus\GdipAddPathString", "UPtr", pPath, "WStr", String, "int", -1, "UPtr", hFontFamily, "int", Style, "float", Size, "UPtr", RectF.Ptr, "UPtr", hStringFormat)
}

Gdip_DrawPath(pGraphics, pPen, pPath) {
	Return DllCall("gdiplus\GdipDrawPath", "UPtr", pGraphics, "UPtr", pPen, "UPtr", pPath)
}

Gdip_DrawOrientedString(pGraphics, String, FontName, Size, Style, X, Y, Width, Height, Angle:=0, pBrush:=0, pPen:=0, Align:=0) {
	; Size   - in em, in world units [font size]
	; Remarks: a high value might be required; over 60, 90... to see the text.
	; X, Y   - coordinates for the rectangle where the text will be drawn
	; W, H   - width and heigh for the rectangle where the text will be drawn
	; Angle  - the angle at which the text should be rotated (NOT ADDED)

	; pBrush - a pointer to a pBrush object to fill the text with
	; pPen   - a pointer to a pPen object to draw the outline [contour] of the text
	; Remarks: both are optional, but one at least must be given, otherwise
	; the function fails, returns -3.
	; For example, if you want only the contour of the text, pass only a pPen object.

	; Align options:
	; Near/left = 0
	; Center = 1
	; Far/right = 2

	; Style options:
	; Regular = 0
	; Bold = 1
	; Italic = 2
	; BoldItalic = 3
	; Underline = 4
	; Strikeout = 8

	; On success, the function returns an array:
	; PathBounds.x , PathBounds.y , PathBounds.w , PathBounds.h

	If (!pBrush && !pPen)
		Return -3

	hFontFamily := Gdip_FontFamilyCreate(FontName)
	FormatStyle := 0x4000
	hStringFormat := Gdip_StringFormatCreate(FormatStyle)

	Gdip_SetStringFormatTrimming(hStringFormat, 3)
	Gdip_SetStringFormatAlign(hStringFormat, Align)
	pPath := Gdip_CreatePath()

	E := Gdip_AddPathString(pPath, String, hFontFamily, Style, Size, hStringFormat, X, Y, Width, Height)

	If (!E && pPen)
		E := Gdip_DrawPath(pGraphics, pPen, pPath)
	If (!E && pBrush)
		E := Gdip_FillPath(pGraphics, pBrush, pPath)

	Gdip_DeleteStringFormat(hStringFormat)
	Gdip_DeleteFontFamily(hFontFamily)
	Gdip_DeletePath(pPath)

	Return E
}

Gdip_ResizeBitmap(pBitmap, ResizedW, ResizedH, InterpolationMode:=0, checkTooLarge:=0, bgrColor:=0) {
; The function returns a pointer to a new pBitmap.
; Default is 0 = 32-ARGB.
; For maximum speed, use 0xE200B - 32-PARGB pixel format.
; Set bgrColor to have a background colour painted.

	If (!pBitmap || !ResizedW || !ResizedH)
	Return

	Gdip_GetImageDimensions(pBitmap, &Width, &Height)
	PixelFormat := Gdip_GetImagePixelFormat(pBitmap)

	mpx := Round((ResizedW * ResizedH)/1000000, 1)

	If ((mpx>536.4 && (!PixelFormat || PixelFormat=0x22009 || PixelFormat=0xE200B)) || (mpx>715.3 && PixelFormat=0x21808) || max(ResizedW, ResizedH)>32750 && checkTooLarge=1)
		Return

	If (ResizedW=Width && ResizedH=Height)
		InterpolationMode := 5

	If (bgrColor!="")
		pBrush := Gdip_BrushCreateSolid(bgrColor)

	If (Format("{1:#x}", PixelFormat) ~= "^(0x30101|0x30402|0x30803)$")
	{
		hbm := CreateDIBSection(ResizedW, ResizedH,,24)
		If !hbm
			Return

		hDC := CreateCompatibleDC()
		If !hDC
		{
			DeleteDC(hdc)
			Return
		}

		obm := SelectObject(hDC, hbm)
		G := Gdip_GraphicsFromHDC(hDC)
		Gdip_SetInterpolationMode(G, InterpolationMode)
		Gdip_SetSmoothingMode(G, 4)
		Gdip_SetPixelOffsetMode(G, 2)
		If G
		{
			If pBrush
				Gdip_FillRectangle(G, pBrush, 0, 0, ResizedW, ResizedH)
			r := Gdip_DrawImage(G, pBitmap, 0, 0, ResizedW, ResizedH)
		}

		newBitmap := !r ? Gdip_CreateBitmapFromHBITMAP(hbm) : ""

		SelectObject(hdc, obm)
		DeleteObject(hbm)
		DeleteDC(hdc)
		Gdip_DeleteGraphics(G)
	} Else
	{
		newBitmap := Gdip_CreateBitmap(ResizedW, ResizedH, PixelFormat)
		If StrLen(newBitmap)>2
		{
			G := Gdip_GraphicsFromImage(newBitmap)
			Gdip_SetInterpolationMode(G, InterpolationMode)
			Gdip_SetSmoothingMode(G, 4)
			Gdip_SetPixelOffsetMode(G, 2)
			If G
			{
				If pBrush
					Gdip_FillRectangle(G, pBrush, 0, 0, ResizedW, ResizedH)
				r := Gdip_DrawImage(G, pBitmap, 0, 0, ResizedW, ResizedH)
			}

			Gdip_DeleteGraphics(G)
			If (r || !G)
			{
				Gdip_DisposeImage(newBitmap)
				newBitmap := ""
			}
		}
	}
	If pBrush
		Gdip_DeleteBrush(pBrush)

	Return newBitmap
}

Gdip_SetPixelOffsetMode(pGraphics, PixelOffsetMode) {
; Sets the pixel offset mode of a pGraphics object.
; PixelOffsetMode options:
; HighSpeed = QualityModeLow - Default
;             0, 1, 3 - Pixel centers have integer coordinates
; ModeHalf - ModeHighQuality
;             2, 4    - Pixel centers have coordinates that are half way between integer values (i.e. 0.5, 20, 105.5, etc...)
	If !pGraphics
		Return 2

	Return DllCall("gdiplus\GdipSetPixelOffsetMode", "UPtr", pGraphics, "int", PixelOffsetMode)
}

;#####################################################################################
; BitmapLockBits
;#####################################################################################

Gdip_LockBits(pBitmap, x, y, w, h, &Stride, &Scan0, &BitmapData, LockMode := 3, PixelFormat := 0x26200a)
{
	CreateRect(&_Rect:="", x, y, w, h)
	BitmapData := Buffer(16+2*(A_PtrSize ? A_PtrSize : 4), 0)
	_E := DllCall("Gdiplus\GdipBitmapLockBits", "UPtr", pBitmap, "UPtr", _Rect.Ptr, "UInt", LockMode, "Int", PixelFormat, "UPtr", BitmapData.Ptr)
	Stride := NumGet(BitmapData, 8, "Int")
	Scan0 := NumGet(BitmapData, 16, "UPtr")
	return _E
}

;#####################################################################################

Gdip_UnlockBits(pBitmap, &BitmapData)
{
	return DllCall("Gdiplus\GdipBitmapUnlockBits", "UPtr", pBitmap, "UPtr", BitmapData.Ptr)
}

;#####################################################################################

Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
{
	Numput("UInt", ARGB, Scan0+0, (x*4)+(y*Stride))
}

;#####################################################################################

Gdip_GetLockBitPixel(Scan0, x, y, Stride)
{
	return NumGet(Scan0+0, (x*4)+(y*Stride), "UInt")
}

;#####################################################################################

Gdip_PixelateBitmap(pBitmap, &pBitmapOut, BlockSize)
{
	static PixelateBitmap := ""

	if (!PixelateBitmap)
	{
		if A_PtrSize != 8 ; x86 machine code
		MCode_PixelateBitmap := "
		(LTrim Join
		558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
		397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
		8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
		4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
		C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
		8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
		148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
		B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
		F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
		038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
		1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
		FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
		D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
		45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
		89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
		0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
		75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
		8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
		B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
		451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
		75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
		8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
		)"
		else ; x64 machine code
		MCode_PixelateBitmap := "
		(LTrim Join
		4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
		448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
		4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
		C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
		24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
		004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
		0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
		DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
		024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
		99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
		8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
		4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
		000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
		ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
		4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
		99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
		8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
		2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
		FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
		83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
		F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
		0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
		413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
		)"

		PixelateBitmap := Buffer(StrLen(MCode_PixelateBitmap)//2)
		nCount := StrLen(MCode_PixelateBitmap)//2
		loop nCount {
			NumPut("UChar", "0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1)
		}
		DllCall("VirtualProtect", "UPtr", PixelateBitmap.Ptr, "UPtr", PixelateBitmap.Size, "UInt", 0x40, "UPtr*", 0)
	}

	Gdip_GetImageDimensions(pBitmap, &Width:="", &Height:="")

	if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
		return -1
	if (BlockSize > Width || BlockSize > Height)
		return -2

	E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, &Stride1:="", &Scan01:="", &BitmapData1:="")
	E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, &Stride2:="", &Scan02:="", &BitmapData2:="")
	if (E1 || E2)
		return -3

	; E := - unused exit code
	DllCall(PixelateBitmap.Ptr, "UPtr", Scan01, "UPtr", Scan02, "Int", Width, "Int", Height, "Int", Stride1, "Int", BlockSize)

	Gdip_UnlockBits(pBitmap, &BitmapData1), Gdip_UnlockBits(pBitmapOut, &BitmapData2)

	return 0
}

;#####################################################################################

Gdip_ToARGB(A, R, G, B)
{
	return (A << 24) | (R << 16) | (G << 8) | B
}

;#####################################################################################

Gdip_FromARGB(ARGB, &A, &R, &G, &B)
{
	A := (0xff000000 & ARGB) >> 24
	R := (0x00ff0000 & ARGB) >> 16
	G := (0x0000ff00 & ARGB) >> 8
	B := 0x000000ff & ARGB
}

;#####################################################################################

Gdip_AFromARGB(ARGB)
{
	return (0xff000000 & ARGB) >> 24
}

;#####################################################################################

Gdip_RFromARGB(ARGB)
{
	return (0x00ff0000 & ARGB) >> 16
}

;#####################################################################################

Gdip_GFromARGB(ARGB)
{
	return (0x0000ff00 & ARGB) >> 8
}

;#####################################################################################

Gdip_BFromARGB(ARGB)
{
	return 0x000000ff & ARGB
}

;#####################################################################################

StrGetB(Address, Length:=-1, Encoding:=0)
{
	; Flexible parameter handling:
	if !IsInteger(Length) {
		Encoding := Length,  Length := -1
	}

	; Check for obvious errors.
	if (Address+0 < 1024) {
		return
	}

	; Ensure 'Encoding' contains a numeric identifier.
	if (Encoding = "UTF-16") {
		Encoding := 1200
	} else if (Encoding = "UTF-8") {
		Encoding := 65001
	} else if SubStr(Encoding,1,2)="CP" {
		Encoding := SubStr(Encoding,3)
	}

	if !Encoding { 	; "" or 0
		; No conversion necessary, but we might not want the whole string.
		if (Length == -1)
			Length := DllCall("lstrlen", "UInt", Address)
		VarSetStrCapacity(myString, Length)
		DllCall("lstrcpyn", "str", myString, "UInt", Address, "Int", Length + 1)

	} else if (Encoding = 1200) { 	; UTF-16
		char_count := DllCall("WideCharToMultiByte", "UInt", 0, "UInt", 0x400, "UInt", Address, "Int", Length, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0)
		VarSetStrCapacity(myString, char_count)
		DllCall("WideCharToMultiByte", "UInt", 0, "UInt", 0x400, "UInt", Address, "Int", Length, "str", myString, "Int", char_count, "UInt", 0, "UInt", 0)

	} else if IsInteger(Encoding) {
		; Convert from target encoding to UTF-16 then to the active code page.
		char_count := DllCall("MultiByteToWideChar", "UInt", Encoding, "UInt", 0, "UInt", Address, "Int", Length, "UInt", 0, "Int", 0)
		VarSetStrCapacity(myString, char_count * 2)
		char_count := DllCall("MultiByteToWideChar", "UInt", Encoding, "UInt", 0, "UInt", Address, "Int", Length, "UInt", myString.Ptr, "Int", char_count * 2)
		myString := StrGetB(myString.Ptr, char_count, 1200)
	}

	return myString
}


; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx
; by 'just me'
; https://autohotkey.com/boards/viewtopic.php?f=6&t=4606
; ======================================================================================================================
GetMonitorCount()
{
	Monitors := MDMF_Enum()
	for k,v in Monitors {
		count := A_Index
	}
	return count
}

GetMonitorInfo(MonitorNum)
{
	Monitors := MDMF_Enum()
	for k,v in Monitors {
		if (v.Num = MonitorNum) {
			return v
		}
	}
}

GetPrimaryMonitor()
{
	Monitors := MDMF_Enum()
	for k,v in Monitors {
		if (v.Primary) {
			return v.Num
		}
	}
}
; ----------------------------------------------------------------------------------------------------------------------
; Name ..........: MDMF - Multiple Display Monitor Functions
; Description ...: Various functions for multiple display monitor environments
; Tested with ...: AHK 1.1.32.00 (A32/U32/U64) and 2.0-a108-a2fa0498 (U32/U64)
; Original Author: just me (https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4606)
; Mod Authors ...: iPhilip, guest3456
; Changes .......: Modified to work with v2.0-a108 and changed 'Count' key to 'TotalCount' to avoid conflicts
; ................ Modified MDMF_Enum() so that it works under both AHK v1 and v2.
; ................ Modified MDMF_EnumProc() to provide Count and Primary keys to the Monitors array.
; ................ Modified MDMF_FromHWND() to allow flag values that determine the function's return value if the
; ................    window does not intersect any display monitor.
; ................ Modified MDMF_FromPoint() to allow the cursor position to be returned ByRef if not specified and
; ................    allow flag values that determine the function's return value if the point is not contained within
; ................    any display monitor.
; ................ Modified MDMF_FromRect() to allow flag values that determine the function's return value if the
; ................    rectangle does not intersect any display monitor.
;................. Modified MDMF_GetInfo() with minor changes.
; ----------------------------------------------------------------------------------------------------------------------
;
; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx =======================
; ======================================================================================================================
; Enumerates display monitors and returns an object containing the properties of all monitors or the specified monitor.
; ======================================================================================================================
MDMF_Enum(HMON := "") {
	static EnumProc := CallbackCreate(MDMF_EnumProc)
	static Monitors := Map()

	if (HMON = "") { 	; new enumeration
		Monitors := Map("TotalCount", 0)
		if !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", ObjPtr(Monitors), "Int")
			return False
	}

	return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
}
; ======================================================================================================================
;  Callback function that is called by the MDMF_Enum function.
; ======================================================================================================================
MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
	Monitors := ObjFromPtrAddRef(ObjectAddr)

	Monitors[HMON] := MDMF_GetInfo(HMON)
	Monitors["TotalCount"]++
	if (Monitors[HMON].Primary) {
		Monitors["Primary"] := HMON
	}

	return true
}
; ======================================================================================================================
; Retrieves the display monitor that has the largest area of intersection with a specified window.
; The following flag values determine the function's return value if the window does not intersect any display monitor:
;    MONITOR_DEFAULTTONULL    = 0 - Returns NULL.
;    MONITOR_DEFAULTTOPRIMARY = 1 - Returns a handle to the primary display monitor.
;    MONITOR_DEFAULTTONEAREST = 2 - Returns a handle to the display monitor that is nearest to the window.
; ======================================================================================================================
MDMF_FromHWND(HWND, Flag := 0) {
	return DllCall("User32.dll\MonitorFromWindow", "Ptr", HWND, "UInt", Flag, "Ptr")
}
; ======================================================================================================================
; Retrieves the display monitor that contains a specified point.
; If either X or Y is empty, the function will use the current cursor position for this value and return it ByRef.
; The following flag values determine the function's return value if the point is not contained within any
; display monitor:
;    MONITOR_DEFAULTTONULL    = 0 - Returns NULL.
;    MONITOR_DEFAULTTOPRIMARY = 1 - Returns a handle to the primary display monitor.
;    MONITOR_DEFAULTTONEAREST = 2 - Returns a handle to the display monitor that is nearest to the point.
; ======================================================================================================================
MDMF_FromPoint(&X:="", &Y:="", Flag:=0) {
	if (X = "") || (Y = "") {
		PT := Buffer(8, 0)
		DllCall("User32.dll\GetCursorPos", "Ptr", PT.Ptr, "Int")

		if (X = "") {
			X := NumGet(PT, 0, "Int")
		}

		if (Y = "") {
			Y := NumGet(PT, 4, "Int")
		}
	}
	return DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", Flag, "Ptr")
}
; ======================================================================================================================
; Retrieves the display monitor that has the largest area of intersection with a specified rectangle.
; Parameters are consistent with the common AHK definition of a rectangle, which is X, Y, W, H instead of
; Left, Top, Right, Bottom.
; The following flag values determine the function's return value if the rectangle does not intersect any
; display monitor:
;    MONITOR_DEFAULTTONULL    = 0 - Returns NULL.
;    MONITOR_DEFAULTTOPRIMARY = 1 - Returns a handle to the primary display monitor.
;    MONITOR_DEFAULTTONEAREST = 2 - Returns a handle to the display monitor that is nearest to the rectangle.
; ======================================================================================================================
MDMF_FromRect(X, Y, W, H, Flag := 0) {
	RC := Buffer(16, 0)
	NumPut("Int", X, "Int", Y, "Int", X + W, "Int", Y + H, RC)
	return DllCall("User32.dll\MonitorFromRect", "Ptr", RC.Ptr, "UInt", Flag, "Ptr")
}
; ======================================================================================================================
; Retrieves information about a display monitor.
; ======================================================================================================================
MDMF_GetInfo(HMON) {
	MIEX := Buffer(40 + (32 << !!1))
	NumPut("UInt", MIEX.Size, MIEX)
	if DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX.Ptr, "Int") {
		return {Name:      (Name := StrGet(MIEX.Ptr + 40, 32))  ; CCHDEVICENAME = 32
		      , Num:       RegExReplace(Name, ".*(\d+)$", "$1")
		      , Left:      NumGet(MIEX, 4, "Int")    ; display rectangle
		      , Top:       NumGet(MIEX, 8, "Int")    ; "
		      , Right:     NumGet(MIEX, 12, "Int")   ; "
		      , Bottom:    NumGet(MIEX, 16, "Int")   ; "
		      , WALeft:    NumGet(MIEX, 20, "Int")   ; work area
		      , WATop:     NumGet(MIEX, 24, "Int")   ; "
		      , WARight:   NumGet(MIEX, 28, "Int")   ; "
		      , WABottom:  NumGet(MIEX, 32, "Int")   ; "
		      , Primary:   NumGet(MIEX, 36, "UInt")} ; contains a non-zero value for the primary monitor.
	}
	return False
}


; Based on WinGetClientPos by dd900 and Frosti - https://www.autohotkey.com/boards/viewtopic.php?t=484
WinGetRect( hwnd, &x:="", &y:="", &w:="", &h:="" ) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	CreateRect(&winRect, 0, 0, 0, 0) ;is 16 on both 32 and 64
	;VarSetCapacity( winRect, 16, 0 )	; Alternative of above two lines
	DllCall( "GetWindowRect", "Ptr", hwnd, "Ptr", winRect )
	x := NumGet(winRect,  0, "UInt")
	y := NumGet(winRect,  4, "UInt")
	w := NumGet(winRect,  8, "UInt") - x
	h := NumGet(winRect, 12, "UInt") - y
}
