#Requires AutoHotkey v2.0

; Handler params are (wparam => uniqueID, lparam => emithWnd, msgNumber, targethWnd)
onSentToAllModels(wparam_uniqueID, lparam_emitterMainScriptHiddenhWnd, msgNumber, targetResponseWindowhWnd) {
    if (msgNumber != CustomMessages.WM_SEND_TO_ALL_MODELS) {
        return
    }

    if (ProcessExist(manageState("cURL", "get"))) {
        manageState("cURL", "close")
    }

    if (requestParams["uniqueID"] = wparam_uniqueID) {
        ; I am the Response Window handling this uniqueID
        
        ; Re-read the updated JSON file and call sendRequestToLLM() again
        chatHistoryAsJson := FileOpen(requestParams["chatHistoryJsonFilePath"], "r", "UTF-8-RAW").Read()
        manageChatHistoryJSON("set", chatHistoryAsJson)

        callWebJavaScriptFunction("responseWindowButtonsEnabled", false)

        sendRequestToLLM(&chatHistoryAsJson)

    } else {
        ; I am NOT the Response Window handling this uniqueID

    }
}

; Handler for WM_RESPONSE_WINDOW_PING (MainScript relaunched, notify us of new hWnd)
onResponseWindowPing(wparam_uniqueID, lparam_newMainScriptHWnd, msgNumber, targetResponseWindowhWnd) {

    if (lparam_newMainScriptHWnd = 0) {

        ; NTD
    } else {

        ; Store newMainScriptHWnd
        requestParams["mainScriptHiddenhWnd"] := lparam_newMainScriptHWnd

        ; Notify MainScript that we've been restored
        CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_RESTORED, 
                                                requestParams["uniqueID"],
                                                responseWindow.hWnd, 
                                                lparam_newMainScriptHWnd)
    }
}

; Handler for WM_THEME_CHANGED (Theme updated from Tray Menu or Preferences)
onThemeChanged(wparam_uniqueID, lparam_themeCode, msgNumber, targetResponseWindowhWnd) {
    ; Decode theme: 1 = Dark, 2 = Light, 3 = System
    themeFromCode := (lparam_themeCode = 2) ? "Light" : ((lparam_themeCode = 3) ? "System" : ((lparam_themeCode = 1) ? "Dark" : ""))
    if (themeFromCode = "") {
        themeFromCode := readThemePreferenceFromDisk()
    }
    global gTHEME := themeFromCode

    if (IsSet(responseWindow)) {
        ; Response window is set

        ; Apply updated theme to response window
        applyResponseWindowTheme(themeFromCode)

    } else {
        ; Response window is not set

        ; NTD
    }

    if (IsSet(chatInputWindow)) {
        ; Chat input window is set

        ; Apply updated theme to chat input window
        chatInputWindow.applyTheme()

    } else {
        ; Chat input window is not set

        ; NTD
    }
}
