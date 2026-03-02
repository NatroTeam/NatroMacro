HideErrors := IniRead("..\settings\nm_config.ini", "Settings", "HideErrors", 1)
if HideErrors
    OnError (e, mode) => (mode = "Return") ? -1 : 0
