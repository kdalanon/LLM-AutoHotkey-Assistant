#Requires AutoHotkey v2.0

; Function that perform action when button is clicked
;
;   action : buttonId or button Name
;
buttonClickAction(action) {

    global gIsChatHistoryDisplayed

    switch action {
        case "chatButton": 
            chatInputWindow.showInputWindow()

        case "copyButton":
            doWebCopy()

        case "pasteButton":
            ; Perform a Copy Button Action
            doWebCopy()

            ; Activate the calling window
            WinActivate("ahk_id " requestParams["callingWindowHwnd"])

            ; Paste the Clipboard to the calling window
            Send("^v")

            ; Close and stop the Response Window
            closeAndStop()

        case "retryButton":
            manageState("model", "remove")

            callWebJavaScriptFunction("responseWindowButtonsEnabled", false)

            ; setLoadingCursor(true)

            chatHistoryAsJson := manageChatHistoryJSON("get")
            chatHistorySingleton.removeLastAssistantMessage(&chatHistoryAsJson)
            FileOpen(requestParams["chatHistoryJsonFilePath"], "w", "UTF-8-RAW").Write(chatHistoryAsJson)
            manageChatHistoryJSON("set", chatHistoryAsJson)

            sendRequestToLLM(&chatHistoryAsJson)

        case "chatHistoryButton":
            ; Toggle and Render ChatHistory or LatestResponse as Markdown

            ; Toggle display
            gIsChatHistoryDisplayed := !gIsChatHistoryDisplayed

            renderWebView()

        case "Close":
            ; Close and stop the response window
            closeAndStop()
        
        Default:
            MsgBox("Unhandled action: (" action ")", "Error", 0x30)
    }
}

; Call JavaScript function in the web page to toggle copy button for few seconds
; and copy the response to the clipboard as HTML and Plain Text (if not copyAsMarkdown)
doWebCopy() {

    global gIsChatHistoryDisplayed

    if requestParams["copyAsMarkdown"] {
        ; Shall copy as Markdown

        chatState := manageState("chat", "get")

        ; Last response and Chathistory are encoded as Markdown
        ; Put it to clipboard
        A_Clipboard := gIsChatHistoryDisplayed ? chatState.chatHistory : chatState.latestResponse

    } else {
        ; Shall copy as HTML and Plain Text

        ; Nothing to do here. It must be done in the web page
    }

    ; Set Focus
    responseWindow.MoveFocus(0)
    ; ControlFocus responseWindow.Gui["WebViewTooContainer"].Hwnd

    ; Call JavaScript function in the web page to toggle button for few seconds
    ; and copy the response to the clipboard as HTML and Plain Text (if not copyAsMarkdown)
    callWebJavaScriptFunction("responseWindowCopyButtonAction", requestParams["copyAsMarkdown"])
}

; Close and stop the response window
closeAndStop() {
    if (!requestParams["skipConfirmation"]) {
        if (MsgBox("End your chat session with " requestParams["responseWindowTitle"] "?",
            "Close " requestParams["responseWindowTitle"],
            InputWindow.cMSGBOX_WARNING . " Owner" responseWindow.hWnd) != "Yes") {
            return true
        }
    }

    ; Proceed with closing (either no warning needed or user clicked "Yes")
    if (ProcessExist(manageState("cURL", "get"))) {
        manageState("cURL", "close")

        ; Sometimes the llmResponseJsonFilePath is still being accessed
        ; Sleep here to make sure the file is not opened anymore
        Sleep 400
    }

    ;     ; deleteTempFiles()
    setLoadingCursor(false)

    callWebJavaScriptFunction("toggleButtonText", [true])

    ; Sends a PostMessage to main script saying the
    ; Response Window has been closed, then terminates
    ; the Response Window script afterwards
    CustomMessages.notifyResponseWindowState(   CustomMessages.WM_RESPONSE_WINDOW_CLOSED,
                                                requestParams["uniqueID"],
                                                responseWindow.hWnd,
                                                requestParams["mainScriptHiddenhWnd"])

    ; Stop the Response Window script
    ExitApp
}

