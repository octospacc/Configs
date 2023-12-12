#Requires AutoHotkey v2.0
ScreenWidth := SysGet(78)
IsCompactDevice := (ScreenWidth < 640)
Run(A_ScriptDir . "\ArgSetTabletMode.ahk " . IsCompactDevice)
Run(A_ScriptDir . "\ArgMoveTaskbar.ahk " . (IsCompactDevice ? "Left" : "Bottom"))