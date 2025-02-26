#Include <Configs_and_Classes>
#SingleInstance Off
#NoTrayIcon

; ----------------------------------------------------
; Read data from main script and start loading cursor
; ----------------------------------------------------

responseWindowDataFile := A_Args[1]
JSONStr := FileOpen(responseWindowDataFile, "r", "UTF-8").Read()
requestParams := jsongo.Parse(JSONStr)
startLoadingCursor(true)

; ----------------------------------------------------
; Change icon based on providerName
; ----------------------------------------------------

TraySetIcon(FileExist(icon := "icons\" requestParams["providerName"] ".ico") ? icon : "icons\IconOn.ico")

; ----------------------------------------------------
; Create new instance of OpenRouter class
; ----------------------------------------------------

router := OpenRouter(APIKey)

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

; Assign actions to click events
responseWindow.AddHostObjectToScript("ButtonClick", { func: buttonClickAction })
buttonClickAction(action) {
    static chatHistoryButtonText := "Chat History"

    switch action {
        case "Chat": chatInputWindow.showInputWindow()
        case "Copy": postWebMessage("responseWindowCopyButtonAction")
        case "Retry":
            manageState("model", "remove")
            postWebMessage("responseWindowButtonsEnabled", false)
            startLoadingCursor(true)
            chatHistoryJSONRequest := manageChatHistoryJSON("get")
            router.removeLastAssistantMessage(&chatHistoryJSONRequest)
            FileOpen(requestParams["chatHistoryJSONRequestFile"], "w", "UTF-8-RAW").Write(chatHistoryJSONRequest)
            manageChatHistoryJSON("set", chatHistoryJSONRequest)
            sendRequestToLLM(&chatHistoryJSONRequest)

        case "Chat History", "Latest Response":
            content := manageState("chat", "get")
            data := [(action = "Chat History") ? content.chatHistory : content.latestResponse]
            postWebMessage("renderMarkdown", data)
            chatHistoryButtonText := (chatHistoryButtonText = "Chat History" ? "Latest Response" : "Chat History")

        case "resetChatHistoryButtonText": chatHistoryButtonText := "Chat History"
        case "Close":
            if (MsgBox("End your chat session with " requestParams["responseWindowTitle"] "?", "Close " requestParams[
                "responseWindowTitle"], "308 Owner" responseWindow
                .hWnd) = "Yes") {

                if (ProcessExist(manageState("cURL", "get"))) {
                    manageState("cURL", "close")

                    ; Sometimes the cURLOutputFile is still being accessed
                    ; Sleep here to make sure the file is not opened anymore
                    Sleep 100
                }

                deleteTempFiles()
                startLoadingCursor(false)
                postWebMessage("toggleButtonText", [true])

                ; Sends a PostMessage to main script saying the
                ; Response Window has been closed, then terminates
                ; the Response Window script afterwards
                CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_CLOSED, requestParams[
                    "uniqueID"], responseWindow.hWnd, requestParams["mainScripthWnd"])
                ExitApp
            } else {
                return true
            }
    }
}

showResponseWindow(responseWindowTextContent, initialRequest, noActivate := false) {
    postWebMessage("renderMarkdown", [responseWindowTextContent, true])
    buttonClickAction("resetChatHistoryButtonText")
    if initialRequest {

        ; Response Window's width and height
        desiredW := 600
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

chatInputWindow := InputWindow("Send message to " requestParams["responseWindowTitle"])
chatInputWindow.sendButtonAction(chatSendButtonAction)

chatSendButtonAction(*) {
    if !chatInputWindow.validateInputAndHide() {
        return
    }

    startLoadingCursor(true)
    postWebMessage("responseWindowButtonsEnabled", false)
    chatHistoryJSONRequest := manageChatHistoryJSON("get")
    router.appendToChatHistory("user", chatInputWindow.EditControl.Value, &
        chatHistoryJSONRequest, requestParams["chatHistoryJSONRequestFile"])
    manageChatHistoryJSON("set", chatHistoryJSONRequest)
    sendRequestToLLM(&chatHistoryJSONRequest)
}

; ----------------------------------------------------
; Custom messages for detecting Response Windows
; and their open/close state, as well as detecting
; the "Send message to all models" feature
; ----------------------------------------------------

CustomMessages.registerHandlers("subScript", responseWindowSendToAllModels)
CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_OPENED, requestParams["uniqueID"],
    A_ScriptHwnd, requestParams["mainScripthWnd"])

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
; Handles request cancellation based on Response Window state:
; - Background window: Stop request, keep window open
; - Active window: Stop request, keep window open
; - Hidden window: Stop request only
; ----------------------------------------------------

~Esc:: cancelProcessOrCloseResponseWindow()
cancelProcessOrCloseResponseWindow() {
    switch {
        case WinExist(responseWindow.hWnd) && !(WinActive(responseWindow.hWnd)) && ProcessExist(manageState("cURL",
            "get")):
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
}

; ----------------------------------------------------
; Run cURL command and process response
; ----------------------------------------------------

chatHistoryJSONRequest := manageChatHistoryJSON("get")
sendRequestToLLM(&chatHistoryJSONRequest, true)
sendRequestToLLM(&chatHistoryJSONRequest, initialRequest := false) {

    ; Run the cURL command asynchronously and store the PID
    Run(FileOpen(requestParams["cURLCommandFile"], "r", "UTF-8").Read(), , "Hide", &cURLPID)
    manageState("cURL", "set", cURLPID)

    ; Waits for the process to complete or be aborted
    ; while allowing the script to process events
    while (ProcessExist(cURLPID)) {
        Sleep 250
    }

    ; If user cancels the process, exit
    if !manageState("cURL", "get") {
        manageState("cURL", "close")
        startLoadingCursor(false)
        if initialRequest {
            deleteTempFiles()

            ; Sends a message to main script saying the Response Window has been closed,
            ; then terminates the Response Window script
            CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_CLOSED, requestParams["uniqueID"
                ], responseWindow.hWnd, requestParams["mainScripthWnd"])
            ExitApp
        }
        Exit
    }

    ; Reset the PID as the process has completed
    cURLPID := 0
    manageState("cURL", "set", cURLPID)

    ; Read the output after the process has completed
    JSONResponseFromLLM := FileOpen(requestParams["cURLOutputFile"], "r", "UTF-8").Read()

    ; Process the JSON response from the LLM API
    try {
        JSONResponseVar := jsongo.Parse(JSONResponseFromLLM)
        responseFromLLM := router.extractJSONResponse(JSONResponseVar)

        ; Get text after forward slash as responseFromLLM.model and replace colon (:) with dash (-)
        responseFromLLM.model := StrReplace(SubStr(responseFromLLM.model, InStr(responseFromLLM.model, "/") + 1), ":",
        "-")

        manageState("model", "add", responseFromLLM.model)
        router.appendToChatHistory("assistant",
            responseFromLLM.response, &chatHistoryJSONRequest, requestParams["chatHistoryJSONRequestFile"])
    } catch as e {
        JSONResponseFromLLM := router.extractErrorResponse(JSONResponseVar)
        responseFromLLM :=
            "**⛔ Error parsing response**`n`n" e.Message
            . "`n`n---`n`n**⚠️ Response from the API**`n`n"
            . JSONResponseFromLLM.error
            . "`n`n---`n`n"
        errorCodes := {
            400: "Invalid request sent to the API. Please double-check your input parameters and ensure they are correctly formatted.",
            401: "Authentication failed. Your API key or session might be invalid or expired. Please verify your credentials and try again.",
            402: "Insufficient funds. Click [here](https://openrouter.ai/credits) to check your available credits.",
            403: "Content flagged as inappropriate. Your input triggered content moderation and was rejected. Please revise your request and try again with different content.",
            408: "Request timed out. The API request took too long to process. This might be due to network issues or server overload.",
            429: "You've hit the rate limit of **" requestParams["singleAPIModel"] "**. Try again after some time.",
            502: "Service temporarily unavailable. The chosen model is either down or returned an invalid response. Please try again later or select a different model.",
            503: "No suitable model available. There are no providers currently meeting your request requirements. Please try again later or adjust your routing settings."
        }

        responseFromLLM .= errorCodes.%JSONResponseFromLLM.code%
        showResponseWindow(responseFromLLM, initialRequest)
        postWebMessage("responseWindowButtonsEnabled", true)
        startLoadingCursor(false)
        Exit
    }

    ; Save Chat History and Latest Response so it can be viewed later
    ; Begin by parsing the JSON string into an object
    manageChatHistoryJSON("set", chatHistoryJSONRequest)
    obj := jsongo.Parse(chatHistoryJSONRequest)

    ; Get the messages array
    messages := router.getMessages(obj)
    totalMessages := messages.Length

    ; Chat History - Iterate over each message in the 'messages' array
    chatHistory := ""
    modelIndex := 1
    for index, message in messages {
        role := message.role
        content := message.content

        switch role {
            case "system": chatHistory .= "**🔧 System Prompt**`n`n" content
            case "user": chatHistory .= "`n`n---`n`n**🔵 You**`n`n" content
            case "assistant": chatHistory .= "`n`n---`n`n**🟡 " manageState("model", "get")[modelIndex++] "**`n`n" content
        }
    }

    ; Latest Response - Iterate backwards over each message in the 'messages' array to find the last assistant message
    ; and calculate the current index starting from the end
    loop totalMessages {
        currentIndex := totalMessages - A_Index + 1  ;
        msg := messages[currentIndex]
        if (msg.role = "assistant") {
            latestResponse := msg.content
            break
        }
    }

    manageState("chat", "add", { chatHistory: chatHistory, latestResponse: latestResponse })

    if requestParams["isAutoPaste"] {
        A_Clipboard := responseFromLLM.response
        Send("^v")
        startLoadingCursor(false)
        CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_CLOSED, requestParams["uniqueID"],
            responseWindow.hWnd, requestParams["mainScripthWnd"])
        deleteTempFiles()
        ExitApp
    } else {
        showResponseWindow(responseFromLLM.response, initialRequest, !initialRequest && !(WinActive(responseWindow.hWnd
        )))
        postWebMessage("responseWindowButtonsEnabled", true)
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
    FileDelete(requestParams["chatHistoryJSONRequestFile"])
    FileDelete(requestParams["cURLCommandFile"])
    FileExist(requestParams["cURLOutputFile"]) ? FileDelete(requestParams["cURLOutputFile"]) : ""
    FileDelete(responseWindowDataFile)
}

; ----------------------------------------------------
; Start or stop loading cursor
; ----------------------------------------------------

startLoadingCursor(status) {
    status ? CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_LOADING_START,
        requestParams["uniqueID"], , requestParams["mainScripthWnd"])
            : CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_LOADING_FINISH,
                requestParams["uniqueID"], , requestParams["mainScripthWnd"])
}
