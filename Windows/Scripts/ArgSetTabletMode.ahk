#NoEnv
SetBatchLines -1
ListLines Off
#NoTrayIcon

TabletModeController_SetMode(TabletModeController, _TABLETMODESTATE, _TMCTRIGGER := 4) {
	return DllCall(NumGet(NumGet(TabletModeController+0),4*A_PtrSize), "Ptr", TabletModeController, "UInt", _TABLETMODESTATE, "UInt", _TMCTRIGGER)  
}

ImmersiveShell := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
TabletModeController := ComObjQuery(ImmersiveShell, "{4fda780a-acd2-41f7-b4f2-ebe674c9bf2a}", "{4fda780a-acd2-41f7-b4f2-ebe674c9bf2a}")

TabletModeController_SetMode(TabletModeController, A_Args[1])

ObjRelease(TabletModeController), TabletModeController := 0
ObjRelease(ImmersiveShell), ImmersiveShell := 0