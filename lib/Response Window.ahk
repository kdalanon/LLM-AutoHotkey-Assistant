#Include Config.ahk

#SingleInstance Off
#NoTrayIcon

; ----------------------------------------------------
; Hotkeys
; ----------------------------------------------------

!t:: respWindowHotkeyActions("chatButton")
!r:: respWindowHotkeyActions("retryButton")
!h:: 
!l:: respWindowHotkeyActions("chatHistoryButton")
!c:: respWindowHotkeyActions("copyButton")
!p:: respWindowHotkeyActions("pasteButton")

~Esc:: respWindowHotkeyActions("Esc")
~^w:: respWindowHotkeyActions("closeWindows")

global gChatHistoryButtonState := "ChatHistory"

respWindowHotkeyActions(action) {
    switch action {

        case "chatButton":
            switch WinActive("A") {
                case responseWindow.hWnd: buttonClickAction("chatButton")
            }

            case "retryButton":
                switch WinActive("A") {
                    case responseWindow.hWnd: buttonClickAction("retryButton")
                }
                
        case "chatHistoryButton":
            switch WinActive("A") {
                case responseWindow.hWnd: 
                    buttonClickAction("chatHistoryButton")
            }

        case "copyButton":    
            switch WinActive("A") {
                case responseWindow.hWnd: buttonClickAction("copyButton")
            }        

        case "pasteButton":
            switch WinActive("A") {
                case responseWindow.hWnd: buttonClickAction("pasteButton")
            }        
        
        ; Handles request cancellation based on Response Window state:
        ;
        ; Background window: Stop request, keep window open
        ; Active window: Stop request, keep window open
        ; Hidden window: Stop request only
        case "Esc":
            switch {
                case WinExist(responseWindow.hWnd) && !(WinActive(responseWindow.hWnd))
                && ProcessExist(manageState("cURL", "get")):
                    manageState("cURL", "close")
                    postWebMessage("responseWindowButtonsEnabled", true)

                case WinActive(responseWindow.hWnd):
                    switch {
                        case ProcessExist(manageState("cURL", "get")):
                            manageState("cURL", "close")
                            postWebMessage("responseWindowButtonsEnabled", true)

                        Default:
                            buttonClickAction("Close")
                    }

                case ProcessExist(manageState("cURL", "get")):
                    manageState("cURL", "close")
            }

        case "closeWindows":
            switch WinActive("A") {
                case responseWindow.hWnd: buttonClickAction("Close")
                case chatInputWindow.guiObj.hWnd: chatInputWindow.closeButtonAction()
            }
        
        Default:
            MsgBox("Unhandled key : (" action ")", "Error", 0x30)
    }
}

; ----------------------------------------------------
; Read data created by main script
; ----------------------------------------------------

if (A_Args.Length < 1) {
    ; No args provided (case of debug)

    ; Ask user to select an 2_responseWindowData.json file
    responseWindowDataFilePath := FileSelect(3, A_Temp , "Open a file", "Text Documents (LLM_Ahk_*_responseWindowData.json)")

} else {

    ; Path to JSON file given as first argument
    responseWindowDataFilePath := A_Args[1]
}

requestParams := jsongo.Parse(FileOpen(responseWindowDataFilePath, "r", "UTF-8").Read())
startLoadingCursor(true)

; ----------------------------------------------------
; Change icon based on providerName
; ----------------------------------------------------

iconNb := getIconNb(requestParams["providerName"])

; TraySetIcon(FileExist(icon) ? icon : iconDefault)
TraySetIconEmbed((iconNb > 0) ? iconNb : ICON_ON)

; ----------------------------------------------------
; Create new instance of OpenRouter class
; ----------------------------------------------------

router := OpenRouter(gLLM_BASE_URL, APIKey)

; ----------------------------------------------------
; Create Response Window
; ----------------------------------------------------

; Create the Webview Window
responseWindow := WebViewToo(, , ,)
responseWindow.OnEvent("Close", (*) => buttonClickAction("Close"))
responseWindow.Load("Response Window resources\index.html")

; Apply dark mode to title bar
; Reference: https://www.autohotkey.com/boards/viewtopic.php?p=422034#p422034
DllCall("Dwmapi\DwmSetWindowAttribute", "ptr", responseWindow.hWnd, "int", 20, "int*", true, "int", 4)

;
; Assign actions to click events
;

; Define the function that will handle the action when a button is clicked
responseWindow.AddHostObjectToScript("ButtonClick", { func: buttonClickAction })

; Function that perform action when button is clicked
;
;   action : buttonId or button Name
;
buttonClickAction(action) {

    global gChatHistoryButtonState

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

            postWebMessage("responseWindowButtonsEnabled", false)

            startLoadingCursor(true)

            chatHistoryJSONRequest := manageChatHistoryJSON("get")
            router.removeLastAssistantMessage(&chatHistoryJSONRequest)
            FileOpen(requestParams["chatHistoryJSONRequestFile"], "w", "UTF-8-RAW").Write(chatHistoryJSONRequest)
            manageChatHistoryJSON("set", chatHistoryJSONRequest)

            sendRequestToLLM(&chatHistoryJSONRequest)

        case "chatHistoryButton":
            ; Render ChatHistory or LatestResponse as Markdown
            content := manageState("chat", "get")
            contentToDisplay := (gChatHistoryButtonState = "ChatHistory") ? content.chatHistory : content.latestResponse

            ; Toggle gChatHistoryButtonState
            gChatHistoryButtonState := (gChatHistoryButtonState = "ChatHistory" ? "LatestResponse" : "ChatHistory")

            postWebMessage("renderMarkdown", Map("content", contentToDisplay, "shallSetChatHistoryText", gChatHistoryButtonState = "ChatHistory"))

        case "resetChatHistoryButtonState": gChatHistoryButtonState := "ChatHistory"

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

    global gChatHistoryButtonState

    if requestParams["copyAsMarkdown"] {
        ; Shall copy as Markdown

        chatState := manageState("chat", "get")

        ; Last response and Chathistory are encoded as Markdown
        ; Put it to clipboard
        A_Clipboard := (gChatHistoryButtonState = "ChatHistory") ? chatState.latestResponse : chatState.chatHistory

    } else {
        ; Shall copy as HTML and Plain Text

        ; Nothing to do here. It must be done in the web page
    }

    ; Set Focus
    responseWindow.MoveFocus(0)
    ; ControlFocus responseWindow.Gui["WebViewTooContainer"].Hwnd

    ; Call JavaScript function in the web page to toggle button for few seconds
    ; and copy the response to the clipboard as HTML and Plain Text (if not copyAsMarkdown)
    postWebMessage("responseWindowCopyButtonAction", requestParams["copyAsMarkdown"])
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

        ; Sometimes the cURLOutputFile is still being accessed
        ; Sleep here to make sure the file is not opened anymore
        Sleep 400
    }

    deleteTempFiles()
    startLoadingCursor(false)

    postWebMessage("toggleButtonText", [true])

    ; Sends a PostMessage to main script saying the
    ; Response Window has been closed, then terminates
    ; the Response Window script afterwards
    CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_CLOSED,
        requestParams["uniqueID"],
        responseWindow.hWnd,
        requestParams["mainScriptHiddenhWnd"])

    ; Stop the Response Window script
    ExitApp
}

;
; Function to show the Response Window using WebView
; (This method does not block execution)
;
showResponseWindow(responseWindowTextContent, initialRequest, noActivate := false) {

    buttonClickAction("resetChatHistoryButtonState")

    postWebMessage("renderMarkdown", Map("content", responseWindowTextContent, "shallSetChatHistoryText", gChatHistoryButtonState = "ChatHistory"))


    if initialRequest {

        ; Response Window's width and height
        desiredW := 750
        desiredH := 600

        ; Calculate screen center
        screenW := A_ScreenWidth
        screenH := A_ScreenHeight

        ; Define an X and Y coordinate variables
        X := (screenW - desiredW) // 2
        Y := (screenH - desiredH) // 4

        ; Compute the arrangement of Response Windows based on the number of models:
        ; If there is one Response Window, it will be in the center
        ; If there are two, they will be side by side in the center
        ; If there are three, they will be arranged in the center
        ; If there are more than three, it will be the same as three for the first three,
        ; then additional windows will be in the center as a stack and have a slight downward offset
        switch requestParams["numberOfAPIModels"] {
            case 1:
                pos := Format("x{} y{} w{} h{}", X - 100, Y, desiredW, desiredH)

            case 2:
                X := (requestParams["APIModelsIndex"] = 1) ? (screenW // 2) - (desiredW * 1.3) : (screenW // 2)
                pos := Format("x{} y{} w{} h{}", X, Y, desiredW, desiredH)

            case 3:
                switch requestParams["APIModelsIndex"] {
                    case 1:
                        ; Left
                        X := (screenW // 2) - (desiredW * 1.6)

                    case 2:
                        ; Center
                        X := (screenW - desiredW) // 2

                    default:
                        ; Right
                        X := (screenW // 2) + (desiredW * 0.4)
                }

                pos := Format("x{} y{} w{} h{}", X, Y, desiredW, desiredH)

            default:
                if (requestParams["APIModelsIndex"] < 4) {
                    switch requestParams["APIModelsIndex"] {
                        case 1: X := (screenW // 2) - (desiredW * 1.6)
                        case 2: X := (screenW - desiredW) // 2
                        case 3: X := (screenW // 2) + (desiredW * 0.4)
                    }
                } else {
                    X := (screenW - desiredW) // 2
                    Y := Y + (requestParams["APIModelsIndex"] - 3) * 30
                }

                pos := Format("x{} y{} w{} h{}", X, Y, desiredW, desiredH)
        }

        responseWindow.Show(pos, requestParams["responseWindowTitle"])
    }

    ; Flash the Response Window if it is minimized or not active
    (WinGetMinMax(responseWindow.hWnd) = -1) || noActivate ? responseWindow.Flash() : ""
}

; ----------------------------------------------------
; Create Chat Input Window
; ----------------------------------------------------

chatInputWindow := InputWindow("Send message to " requestParams["responseWindowTitle"], 
                               requestParams["skipConfirmation"])

chatInputWindow.registerSendButtonAction(chatSendButtonAction)

chatSendButtonAction(*) {
    if !chatInputWindow.validateInputAndHide() {
        return
    }

    ; Activate Loading Mouse Cursor
    startLoadingCursor(true)

    ; Disable Response Window Buttons while waiting for LLM response
    postWebMessage("responseWindowButtonsEnabled", false)

    ; Append User Prompt message to chat history
    ; and get the JSON request for sending to the LLM
    chatHistoryJSONRequest := manageChatHistoryJSON("get")
    router.appendToChatHistory("user", 
                               chatInputWindow.EditControl.Value, 
                               &chatHistoryJSONRequest, 
                               requestParams["chatHistoryJSONRequestFile"])
    manageChatHistoryJSON("set", chatHistoryJSONRequest)

    ; Send the request to the LLM
    sendRequestToLLM(&chatHistoryJSONRequest)
}

; ----------------------------------------------------
; Custom messages for detecting Response Windows
; and their open/close state, as well as detecting
; the "Send message to all models" feature
; ----------------------------------------------------

CustomMessages.registerHandlers("subScript", responseWindowSendToAllModels)
CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_OPENED, requestParams["uniqueID"],
    responseWindow.hWnd, requestParams["mainScriptHiddenhWnd"])

responseWindowSendToAllModels(uniqueID, lParam, msg, responseWindowhWnd) {
    if (ProcessExist(manageState("cURL", "get"))) {
        manageState("cURL", "close")
    }

    ; Re-read the updated JSON file and call sendRequestToLLM() again
    chatHistoryJSONRequest := FileOpen(requestParams["chatHistoryJSONRequestFile"], "r", "UTF-8-RAW").Read()
    startLoadingCursor(true)
    manageChatHistoryJSON("set", chatHistoryJSONRequest)
    postWebMessage("responseWindowButtonsEnabled", false)
    sendRequestToLLM(&chatHistoryJSONRequest)
}

; ----------------------------------------------------
; Run cURL command and process LLM response
; ----------------------------------------------------

chatHistoryJSONRequest := manageChatHistoryJSON("get")
sendRequestToLLM(&chatHistoryJSONRequest, true)

sendRequestToLLM(&chatHistoryJSONRequest, initialRequest := false) {

    ;
    ; Launch the cURL command and run it asynchronously
    ;
    
    ; Run the cURL command asynchronously and store the PID
    Run(FileOpen(requestParams["cURLCommandFile"], "r", "UTF-8").Read(), , "Hide", &cURLPID)
    manageState("cURL", "set", cURLPID)

    ; Waits for the cURL process to complete or be aborted
    ; while allowing the script to process events
    while (ProcessExist(cURLPID)) {
        Sleep 250
    }

    if !manageState("cURL", "get") {
        ; User canceled the process
        
        ; Perform Exit

        manageState("cURL", "close")

        startLoadingCursor(false)

        if initialRequest {
            deleteTempFiles()

            ; Sends a message to main script saying the Response Window has been closed,
            ; then terminates the Response Window script
            CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_CLOSED,
                requestParams["uniqueID"], responseWindow.hWnd, requestParams["mainScriptHiddenhWnd"])
            ExitApp
        }
        Exit
    }

    ; Reset the PID as the process has completed
    cURLPID := 0
    manageState("cURL", "set", cURLPID)


    ;
    ; Process the JSON response from the LLM API
    ;
    
    errorMsg := ""

    try {
        ; Read the LLM Response File
        JSONResponseFromLLM := FileOpen(requestParams["cURLOutputFile"], "r", "UTF-8").Read()

    } catch as e {

        errorMsg :=
            "**⛔ ERROR**"
            . "`n`n"
            . "LLM Response File not found :"
            . "`n`n"
            . requestParams["cURLOutputFile"]
            . "`n`n---`n`n"
            . "**POSSIBLE REASONS**"
            . "`n`n"
            . "- **LLM** did **not respond**."
            . "`n`n"
            . "- Your disk is **full**."

    } else {
        ; LLM Response File found

        try {
            ; Parse JSON response from LLM
            JSONResponseVar := jsongo.Parse(JSONResponseFromLLM)
            responseFromLLM := router.extractJSONResponse(JSONResponseVar)
            
            ; Get text after forward slash as responseFromLLM.model and replace colon (:) with dash (-)
            responseFromLLM.model := StrReplace(SubStr(responseFromLLM.model, InStr(responseFromLLM.model, "/") + 1), ":", "-")
            
            manageState("model", "add", responseFromLLM.model)
            
            ; Append assistant's (LLM's) response to chat history
            router.appendToChatHistory("assistant",
                                    responseFromLLM.response, 
                                    &chatHistoryJSONRequest, 
                                    requestParams["chatHistoryJSONRequestFile"])
                                    
        } catch as e {
            
            try {
                JSONResponseFromLLM := router.extractErrorResponse(JSONResponseVar)

            } catch as e2 {
                ; Can not extract error message from JSON response

                errorMsg :=
                    "**⛔ ERROR**"
                    . "`n`n"
                    . "Error **parsing** LLM Response"
                    
            } else {
                ; Can extract error message from JSON response

                errorMsg :=
                    "**⛔ ERROR**"
                    . "`n`n"
                    . "Error **parsing** LLM Response"
                    . "`n`n"
                    . e.Message
                    . "`n`n---`n`n"
                    . "**REASON**"
                    . "`n`n"
                    . "**⚠️ Response from the API** : "
                    . "`n`n"
                    . JSONResponseFromLLM.error
            
                ; Map of error codes
                errorCodes := {
                    400: "You may have specified an invalid API model. See [this guide](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/blob/main/README.md#apimodels) on how to get the correct API models.",
                    401: "Authentication failed. Your API key or session might be invalid or expired. Check your keys [here](https://openrouter.ai/settings/keys), re-add it to the app, and try again.",
                    402: "Insufficient funds. Click [here](https://openrouter.ai/credits) to check your available credits.",
                    403: "Content flagged as inappropriate. Your input triggered content moderation and was rejected. Please revise your request and try again with different content.",
                    408: "Request timed out. The API request took too long to process. This might be due to network issues or server overload.",
                    429: "You've hit the rate limit of **" requestParams["singleAPIModelName"] "**. Try again after some time.",
                    502: "Service temporarily unavailable. The chosen model is either down or returned an invalid response. Please try again later or select a different model.",
                    503: "No suitable model available. There are no providers currently meeting your request requirements. Please try again later or adjust your routing settings."
                }
        
                ; Concat Error message according to error code
                errorMsg .= errorCodes.%JSONResponseFromLLM.code%

            } finally {

                ; NTD
            }
        } ; catch

    } finally {

        ; NTD
    }

    ;
    ; Save Chat History and Latest Response so it can be viewed later
    ;

    manageChatHistoryJSON("set", chatHistoryJSONRequest)

    ; Begin by parsing the Chat History JSON string into an object
    obj := jsongo.Parse(chatHistoryJSONRequest)

    ; Get the messages array
    messages := router.getChatHistoryMessages(obj)
    totalMessages := messages.Length

    ; Chat History - Iterate over each message in the 'messages' array
    modelIndex := 1
    for index, message in messages {
        role := message.role
        content := message.content

        switch role {
            case "system": chatHistory .= "**🔧 System Prompt**`n`n" content
            case "user": chatHistory .= "`n`n---`n`n**🔵 You**`n`n" content
            case "assistant": chatHistory .= "`n`n---`n`n**🟡 " manageState("model", "get")[modelIndex++] "**`n`n" content
        }
    } ; for

    ; Latest Response - Iterate backwards over each message in the 'messages' array to find the last assistant message
    ; and calculate the current index starting from the end
    latestResponse := "⚠️ No LLM Response yet."
    loop totalMessages {
        currentIndex := totalMessages - A_Index + 1  ;
        msg := messages[currentIndex]
        if (msg.role = "assistant") {
            latestResponse := msg.content
            break
        }
    }

    manageState("chat", "add", { chatHistory: chatHistory, latestResponse: latestResponse })


    ;
    ; Display or Paste
    ;

    if (errorMsg = "") {
        ; No error

        if requestParams["isAutoPaste"] {
            ; Auto-paste the response into the active window

            ; TODO M 2025_06_26 : Should Activate the calling Window because another window could have been activated since the call

            A_Clipboard := responseFromLLM.response
            Send("^v")

            ; TODO m 2025_06_26 : Should factorize (See closeAndStop() )

            startLoadingCursor(false)

            CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_CLOSED, requestParams["uniqueID"],
                responseWindow.hWnd, requestParams["mainScriptHiddenhWnd"])
            deleteTempFiles()

            ; Stop Response Window.ahk script
            ExitApp

        } else {
            ; Not Auto-paste mode

            ; Display the response in the Response Window
            showResponseWindow(responseFromLLM.response, initialRequest, !initialRequest && !(WinActive(responseWindow.hWnd)))

            ; Enable buttons in the response window
            postWebMessage("responseWindowButtonsEnabled", true)

            ; Stop loading mouse cursor
            startLoadingCursor(false)
        }
    } else {
        ; There is an error message to display
        
        ; Show Response Window
        showResponseWindow(errorMsg, initialRequest)

        ; Enable Response Window buttons
        postWebMessage("responseWindowButtonsEnabled", true)

        ; Stop loading Cursor
        startLoadingCursor(false)
    }
}

; ----------------------------------------------------
; Manage Chat History requests
; ----------------------------------------------------

manageChatHistoryJSON(action, data := unset) {
    static JSONRequest := FileOpen(requestParams["chatHistoryJSONRequestFile"], "r", "UTF-8-RAW").Read()

    switch action {
        case "get": return JSONRequest
        case "set": JSONRequest := data
    }
}

;--------------------------------------------------
; Combined state management for model history,
; chat history, and cURL process
;--------------------------------------------------

manageState(component, action, data := {}) {

    static state := {
        modelHistory: [],
        chatHistory: { chatHistory: "", latestResponse: "" },
        cURLPID: 0
    }

    switch component {
        case "model":
            switch action {
                case "get": return state.modelHistory
                case "add": state.modelHistory.Push(data)
                case "remove": (state.modelHistory.Length) ? state.modelHistory.Pop() : ""
            }

        case "chat":
            switch action {
                case "get": return state.chatHistory
                case "add":
                    state.chatHistory.chatHistory := data.chatHistory
                    state.chatHistory.latestResponse := data.latestResponse
            }

        case "cURL":
            switch action {
                case "get": return state.cURLPID
                case "set": state.cURLPID := data
                case "close": ProcessClose(state.cURLPID), state.cURLPID := 0
            }
    }
}

; ----------------------------------------------------
; Call main.js functions
; ----------------------------------------------------

postWebMessage(target, data := unset) {
    msgObj := { target: target }

    ; If data is provided, add it to the message object
    msgObj.data := IsSet(data) ? data : unset

    jsonStr := jsongo.Stringify(msgObj)
    responseWindow.PostWebMessageAsJSON(jsonStr)
}

; ----------------------------------------------------
; Deletes the files created by the main script
; ----------------------------------------------------

deleteTempFiles() {
    try FileDelete(requestParams["chatHistoryJSONRequestFile"])
    try FileDelete(requestParams["cURLCommandFile"])
    try FileExist(requestParams["cURLOutputFile"]) ? FileDelete(requestParams["cURLOutputFile"]) : ""
    try FileDelete(A_Args[1])
}

; ----------------------------------------------------
; Start or stop loading cursor
; ----------------------------------------------------

; TODO m 2025_06_26 : Rename startLoadingCursor to setLoadingCursor
startLoadingCursor(status) {
    status ? CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_LOADING_START,
        requestParams["uniqueID"], , requestParams["mainScriptHiddenhWnd"])
            : CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_LOADING_FINISH,
                requestParams["uniqueID"], , requestParams["mainScriptHiddenhWnd"])
}
