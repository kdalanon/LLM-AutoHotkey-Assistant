#Requires AutoHotkey v2.0

; Dispatch hotkey actions
mainScriptHotkeyActions(action) {

    switch action {

        case "showPromptMenu":
            promptMenu := Menu()

            ; Build menu (from Prompts.ahk)
            buildMenu(promptMenu)

            ;
            ; Display Menu
            ;

            ; Start a process that will wait for menu to pop-up and then select first item
            startSelectFirstMenuItemProcess()

            promptMenu.Show()

        case "suspendHotkey":
            KeyWait "CapsLock", "L"
            SetCapsLockState "Off"
            toggleSuspend(A_IsSuspended)

        case "saveAndReloadScript":
            SetTitleMatchMode 2
            if !WinActive("Prompts.ahk") {
                ; Active window title does not contain Prompts.ahk

                ; Do nothing
                return

            } else {
                ; Active window title contains Prompts.ahk

                ; Briefly inform user that save was detected
                ToolTip("Rechargement de Prompts.ahk...")
                SetTimer(() => ToolTip(), -1500)

                ; Small delay to ensure file operations are complete
                Sleep 1000

                if (getMapId2ActiveResponseWindowParams().Count > 0) {
                    ; Active response windows are still open

                    MsgBox("Script will automatically reload once all Response Windows are closed.",
                           "LLM AutoHotkey Assistant", 64)

                    setPromptsReloadedFlag()
                    onResponseWindowStateChanged(0, 0, "reloadScript", 0)

                } else {
                    ; No active response window is open

                    setPromptsReloadedFlag()
                    Reload()
                }
            }

        case "closeWindows":
            switch WinActive("A") {
                case customPromptInputWindow.guiObj.hWnd: customPromptInputWindow.closeButtonAction()
                case sendToPromptNameInputWindow.guiObj.hWnd: sendToPromptNameInputWindow.closeButtonAction()
                case sendToAllModelsInputWindow.guiObj.hWnd: sendToAllModelsInputWindow.closeButtonAction()
            }
    }
}

; ----------------------------------------------------
; Toggle Debug Mode
; ----------------------------------------------------

toggleDebugMode(*) {
    global gIsDebugMode := !gIsDebugMode
    
    status := gIsDebugMode ? "ENABLED" : "DISABLED"
    icon := gIsDebugMode ? "ON" : "OFF"
    
    ; Show info pop-up for 3 seconds
    MsgBox("Debug Mode " status, "LLM AutoHotkey Assistant", "Iconi T2")
}


; ----------------------------------------------------
; Toggle Suspend
; ----------------------------------------------------

toggleSuspend(*) {

    ; Toggle suspend state
    Suspend -1

    if (A_IsSuspended) {
        ; Is suspended
        
        TraySetIconEmbed(ICON_OFF)
        A_IconTip := "LLM AutoHotkey Assistant - (Suspended)"
        A_TrayMenu.Rename("&Suspend Assistant" , "&Resume Assistant")
        
        ; Show GUI at the bottom, centered
        scriptSuspendStatus.Show("AutoSize x" (A_ScreenWidth - scriptSuspendStatusWidth) / 2.3 " y" (A_ScreenHeight * 90/100) " NA")
        
    } else {
        ; Is NOT suspended
        
        TraySetIconEmbed(ICON_ON)
        A_IconTip := "LLM AutoHotkey Assistant"
        A_TrayMenu.Rename("&Resume Assistant", "&Suspend Assistant")
        
        scriptSuspendStatus.Hide()
    }
}
