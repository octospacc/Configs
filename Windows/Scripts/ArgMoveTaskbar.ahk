; <https://www.autohotkey.com/boards/viewtopic.php?t=62751>
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#SingleInstance force

TaskbarMove(A_Args[1])

TaskbarMove(p_pos) {
label:="TaskbarMove_" p_pos

WinExist("ahk_class Shell_TrayWnd")
SysGet, s, Monitor

if (IsLabel(label)) {
Goto, %label%
}
return

TaskbarMove_Top:
TaskbarMove_Bottom:
WinMove(sLeft, s%p_pos%, sRight, 0)
return

TaskbarMove_Left:
TaskbarMove_Right:
WinMove(s%p_pos%, sTop, 0, sBottom)
return
}

WinMove(p_x, p_y, p_w="", p_h="", p_hwnd="") {
WM_ENTERSIZEMOVE:=0x0231
WM_EXITSIZEMOVE :=0x0232

if (p_hwnd!="") {
WinExist("ahk_id " p_hwnd)
}

SendMessage, WM_ENTERSIZEMOVE
;//Tooltip WinMove(%p_x%`, %p_y%`, %p_w%`, %p_h%)
WinMove, , , p_x, p_y, p_w, p_h
SendMessage, WM_EXITSIZEMOVE
}