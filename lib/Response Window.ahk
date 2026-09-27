#Include Shared\SharedRoot.ahk

#Include ResponseWindow\COTS\WebViewToo.ahk ; Allows for use of the WebView2 Framework within AHK to create Web-based GUIs

#Include ResponseWindow\Utils\respWindowUtils.ahk
#Include ResponseWindow\Utils\respWindowFileUtils.ahk
#Include ResponseWindow\Utils\respWindowWeb.ahk
#Include ResponseWindow\Gui\Handlers\respWindowHotkeyActions.ahk
#Include ResponseWindow\Gui\Handlers\respWindowButtonActions.ahk
#Include ResponseWindow\Gui\Handlers\respWindowInputWindowButtonActions.ahk
#Include ResponseWindow\LLM\LlmCall.ahk
#Include ResponseWindow\LLM\clsLlmResponse.ahk
#Include ResponseWindow\CallBack\respWindowCallBackFunctions.ahk

#SingleInstance Off
#NoTrayIcon

; ----------------------------------------------------
; Hotkeys (Context-sensitive to current response window)
; ----------------------------------------------------

#HotIf isCurrentResponseWindowActive()

!t:: respWindowHotkeyActions("chatButton")
!r:: respWindowHotkeyActions("retryButton")
!h:: 
!l:: respWindowHotkeyActions("chatHistoryButton")
!c:: respWindowHotkeyActions("copyButton")
!p:: respWindowHotkeyActions("pasteButton")

~Esc:: respWindowHotkeyActions("Esc")
~^w:: respWindowHotkeyActions("closeWindows")

#HotIf

#HotIf isOnlyResponseWindowActive()

PgUp:: respWindowHotkeyActions("PgUp")
PgDn:: respWindowHotkeyActions("PgDn")

#HotIf

; Chat history is not displayed (Latest Response is displayed) by default
global gIsChatHistoryDisplayed := false


; ----------------------------------------------------
; Read Params file created by Main Script
; ----------------------------------------------------

if (A_Args.Length < 1) {
    ; No args provided (case of debug)

    debugFile := getSessionDir() "\LLM_Ahk_DEBUG_LAST_SESSION.json"
    
    if FileExist(debugFile) {
        debugData := loadDebugState()
        if IsSet(debugData) {
            paramsForResponseWindowJsonFilePath := debugData["paramsForResponseWindowJsonFilePath"]
            mainScriptHiddenhWnd := debugData["mainScriptHiddenhWnd"]
            callingWindowHwnd := debugData["callingWindowHwnd"]
            isSession := debugData["isSession"]
        } else {
            ExitApp()
        }
    } else {
        ; Fallback to manual selection if no debug file
        paramsForResponseWindowJsonFilePath := FileSelect(3, getSessionDir(), "Open a file", "Text Documents (LLM_Ahk_*_paramsForResponseWindow.json)")
        if (paramsForResponseWindowJsonFilePath = "")
            ExitApp()
        
        isSession := (MsgBox("Is this a session?", "Debug Mode", "YesNo") = "Yes")
        mainScriptHiddenhWnd := WinExist("LLM AutoHotkey Assistant")
        callingWindowHwnd := WinActive("A")
    }

} else {

    ; Path to JSON file given as first argument
    paramsForResponseWindowJsonFilePath := A_Args[1]
    
    ; hwnd of MainScript (= LLM AutoHotkey Assistant)
    mainScriptHiddenhWnd := (A_Args.Length >= 2) ? A_Args[2] : 0
    
    ; hwnd of the Window from which, menu was triggered
    callingWindowHwnd := (A_Args.Length >= 3) ? A_Args[3] : 0
    
    if (A_Args.Length >= 4) {

        ; is a Response Window for a loaded Session
        isSession := A_Args[4]
    } else {
        ; 4th arg is not defined
        
        ; is a Response Window for a loaded Session
        isSession := false
    }
}

requestParams := jsongo.Parse(FileOpen(paramsForResponseWindowJsonFilePath, "r", "UTF-8").Read())

; ; Overwrite hwnd
requestParams["mainScriptHiddenhWnd"] := mainScriptHiddenhWnd
requestParams["callingWindowHwnd"] := callingWindowHwnd


; ----------------------------------------------------
; Change icon based on providerName
; ----------------------------------------------------

iconNb := getIconNb(requestParams["providerName"])

TraySetIconEmbed((iconNb > 0) ? iconNb : ICON_ON)

; ----------------------------------------------------
; Create Response Window
; ----------------------------------------------------

; Create the Webview Window
responseWindow := WebViewToo(, , ,)

responseWindow.OnEvent("Close", (*) => buttonClickAction("Close"))

; Apply theme to title bar and web document
applyResponseWindowTheme(targetTheme := unset) {
    if (IsSet(targetTheme)) {
        global gTHEME := targetTheme
    }
    effectiveTheme := getEffectiveTheme(targetTheme?)
    isDark := (effectiveTheme = "Dark")

    ; Update title bar dark mode attribute
    DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", responseWindow.hWnd, "int", 20, "int*", isDark, "int", 4)

    ; Update web document theme asynchronously to prevent blocking during page initialization
    try {
        responseWindow.ExecuteScriptAsync("if (window.applyTheme) window.applyTheme('" effectiveTheme "');")
    }
    try {
        callWebJavaScriptFunction("applyTheme", effectiveTheme)
    }
}

; Set initial title bar theme attribute
applyResponseWindowTheme()

;
; Assign actions to host objects BEFORE loading the page
; so they are immediately available on DOMContentLoaded
;

; Define the function that will handle the action when a button is clicked
responseWindow.AddHostObjectToScript("ButtonClick", { func: buttonClickAction })

; Define the function that will handle stream events from WebView2
responseWindow.AddHostObjectToScript("StreamEvent", { func: onStreamEvent })

; Pre-inject initial theme attribute on document creation
try {
    effectiveTheme := getEffectiveTheme()
    initialTheme := (effectiveTheme = "Light") ? "light" : "dark"
    themeScript := "document.documentElement.setAttribute('data-bs-theme', '" initialTheme "'); "
                 . "localStorage.setItem('theme', '" effectiveTheme "');"
    responseWindow.AddScriptToExecuteOnDocumentCreatedAsync(themeScript)
}

; Load HTML document
responseWindow.Load("Response Window resources\index.html")

; ----------------------------------------------------
; Create a Chat Input Window (but do not show it yet)
; ----------------------------------------------------

chatInputWindow := InputWindow("Send message to " requestParams["responseWindowTitle"], 
                               requestParams["skipConfirmation"])

chatInputWindow.registerSendButtonAction(chatSendButtonAction)

; ----------------------------------------------------
; Custom messages for detecting Response Windows
; and their open/close state, as well as detecting
; the "Send message to all models" feature
; ----------------------------------------------------

; CallBack function triggered when receiving WM_SEND_TO_ALL_MODELS message
CustomMessages.registerHandlers("subScript", onSentToAllModels)

; Register handler for WM_RESPONSE_WINDOW_PING
OnMessage(CustomMessages.WM_RESPONSE_WINDOW_PING, onResponseWindowPing)

; Register handler for WM_THEME_CHANGED
OnMessage(CustomMessages.WM_THEME_CHANGED, onThemeChanged)

; Tell MainScript that a Response Window just opened
CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_OPENED, 
                                         requestParams["uniqueID"],
                                         responseWindow.hWnd, 
                                         requestParams["mainScriptHiddenhWnd"])


; ----------------------------------------------------
; Run cURL command to LLM and process LLM response
; ----------------------------------------------------

chatHistoryAsJson := manageChatHistoryJSON("get")

sendRequestToLLM(&chatHistoryAsJson, true, isSession)

; ----------------------------------------------------
; Window hotkeys
; ----------------------------------------------------

#HotIf WinActive("ahk_id " responseWindow.hWnd)
F5:: {
    ; F5 pressed when Response Window is active

    ; Refresh WebView content
    renderWebView()
    callWebJavaScriptFunction("responseWindowButtonsEnabled", true)
}
#HotIf


