bitmaps["tunnelbearconfirm"] := Map()
bitmaps["tunnelbearconfirm"][1] := Gdip_CreateBitmap(25, 25), G := Gdip_GraphicsFromImage(bitmaps["tunnelbearconfirm"][1]), Gdip_GraphicsClear(G, 0xff858e8f) Gdip_DeleteGraphics(G) ;current color
bitmaps["tunnelbearconfirm"][2] := Gdip_CreateBitmap(25, 25), G := Gdip_GraphicsFromImage(bitmaps["tunnelbearconfirm"][2]), Gdip_GraphicsClear(G, 0xff2d5e0b) Gdip_DeleteGraphics(G) ;green color; before map color changes
bitmaps["tunnelbearconfirm"][3] := Gdip_CreateBitmap(25, 25), G := Gdip_GraphicsFromImage(bitmaps["tunnelbearconfirm"][3]), Gdip_GraphicsClear(G, 0xffb4c1c3) Gdip_DeleteGraphics(G) ;original color; before roblox shading issues
