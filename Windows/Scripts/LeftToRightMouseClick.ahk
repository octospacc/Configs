#Requires AutoHotkey v2.0
Persistent
; <https://www.autohotkey.com/boards/viewtopic.php?t=38761>

HotKey("LButton", LeftClickActions)
LeftClickActions(key)
{
	Send "{Click Right}"
	InfoTooltip(false)
	HotKey("LButton", "Off")
}
HotKey("LButton", "Off")

OnMessage(0x404, AHK_NOTIFYICON)
AHK_NOTIFYICON(wParam, lParam, uMsg, hWnd)
{
	if (lParam = 0x201) ; WM_LBUTTONDOWN
	{
		HotKey("LButton", "On")
		InfoTooltip(true)
	}
}

InfoTooltip(status)
{
	ToolTip (status ? "Right click action is temporarily active." : "Right cick action is now disabled.")
	SetTimer () => ToolTip(), -1000
}