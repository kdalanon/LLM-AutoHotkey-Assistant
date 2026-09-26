onStreamEvent(eventType, args*) {
    global gIsChatHistoryDisplayed, chatHistoryAsJson

    text := (args.Length >= 1) ? args[1] : ""
    modelName := (args.Length >= 2) ? args[2] : ""

    switch eventType {
        case "debugLog":
            logStreamDebug("[JS] " text)

        case "pageReady":
            logStreamDebug("[AHK] Received pageReady from JS")
            manageState("webPageReady", "set", true)

            ; Ensure theme is synchronized across window and document
            applyResponseWindowTheme()

            pendingConfig := manageState("pendingStreamConfig", "get")
            if (pendingConfig != "") {
                ; Pending stream config exists

                ; Launch stream
                manageState("pendingStreamConfig", "set", "")
                logStreamDebug("[AHK] Launching pending streamConfig via startStream")
                callWebJavaScriptFunction("responseWindowButtonsEnabled", false)
                callWebJavaScriptFunction("startStream", pendingConfig)

            } else {
                ; No pending stream config

                ; NTD
            }

            if (manageState("pendingRender", "get")) {
                ; Pending session render exists

                ; Render markdown to WebView
                manageState("pendingRender", "set", false)
                logStreamDebug("[AHK] Rendering pending session markdown")
                renderWebView()
                callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

            } else {
                ; No pending session render

                ; Check if chat content already exists in state to re-render after page reload
                content := manageState("chat", "get")
                contentToDisplay := gIsChatHistoryDisplayed ? content.chatHistory : content.latestResponse
                if (contentToDisplay != "") {
                    ; Existing content found in state

                    ; Re-render content
                    logStreamDebug("[AHK] Page reloaded: re-rendering existing chat content")
                    renderWebView()
                    callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

                } else {
                    ; No existing content in state

                    ; NTD
                }
            }

        case "refreshRequest":
            logStreamDebug("[AHK] Received refreshRequest from JS")
            renderWebView()
            callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

        case "complete", "aborted":
            manageState("streaming", "set", false)
            logStreamDebug("[AHK] Stream " eventType " - text length=" StrLen(text))

            if (text != "") {
                ; Response text is not empty

                ; Append the LLM's response to Chat History file
                chatHistoryAsJson := manageChatHistoryJSON("get")
                chatHistorySingleton.appendToChatHistoryJsonFile(
                    "assistant",
                    text,
                    &chatHistoryAsJson,
                    requestParams["chatHistoryJsonFilePath"]
                )
                manageChatHistoryJSON("set", chatHistoryAsJson)

                ; Update model history
                shortModel := requestParams["modelName"]
                manageState("model", "add", shortModel)

                ; Rebuild chat history markdown
                chatData := buildChatHistoryMarkdown(&chatHistoryAsJson)
                manageState("chat", "set", chatData)

                ; ==============================================================================
                ; BACKWARD COMPATIBILITY NOTE:
                ; Ce fichier (*_4_llmResponse.json) n'est créé que pour assurer la
                ; rétrocompatibilité avec les versions antérieures (et la branche master).
                ; Il n'est plus utilisé depuis l'introduction du streaming en temps réel
                ; directement via WebView2.
                ;
                ; This file (*_4_llmResponse.json) is generated exclusively to maintain 100%
                ; backward compatibility with earlier versions (and master branch).
                ; It is no longer consumed since the introduction of real-time streaming
                ; directly via WebView2.
                ; ==============================================================================
                if (requestParams.Has("llmResponseJsonFilePath") && (requestParams["llmResponseJsonFilePath"] != "")) {
                    ; llmResponseJsonFilePath parameter exists AND is not empty

                    ; Build synthetic LLM response object compatible with clsLlmResponse
                    rawResponseObj := Map(
                        "id", "chatcmpl-stream-" A_NowUTC,
                        "created", A_NowUTC,
                        "model", shortModel,
                        "choices", [
                            Map(
                                "finish_reason", "stop",
                                "index", 0,
                                "message", Map(
                                    "role", "assistant",
                                    "content", text
                                )
                            )
                        ]
                    )

                    ; Write synthetic response file for backward compatibility with earlier versions
                    FileOpen(requestParams["llmResponseJsonFilePath"], "w", "UTF-8").Write(jsongo.Stringify(rawResponseObj, , 4))

                } else {
                    ; llmResponseJsonFilePath parameter does not exist OU is empty

                    ; NTD
                }

            } else {
                ; Response text is empty

                ; NTD
            }

            gIsChatHistoryDisplayed := false
            callWebJavaScriptFunction("updateChatHistoryButton", false)
            callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

        case "error":
            manageState("streaming", "set", false)
            logStreamDebug("[AHK] Stream error: " text)
            callWebJavaScriptFunction("responseWindowButtonsEnabled", true)
    }
}

checkPageReadyFallback() {
    static attempts := 0
    attempts++

    hasPendingWork := manageState("pendingRender", "get") || (manageState("pendingStreamConfig", "get") != "")

    if (!hasPendingWork) {
        ; No pending render or stream work

        ; Stop fallback timer
        SetTimer(checkPageReadyFallback, 0)
        attempts := 0

    } else {
        ; There is pending render or stream work

        if (manageState("webPageReady", "get")) {
            ; Web page is ready and pending work exists

            ; Process pending work and stop fallback timer
            SetTimer(checkPageReadyFallback, 0)
            attempts := 0

            pendingConfig := manageState("pendingStreamConfig", "get")
            if (pendingConfig != "") {
                ; Pending stream config exists

                ; Launch stream
                manageState("pendingStreamConfig", "set", "")
                logStreamDebug("[AHK] checkPageReadyFallback: Launching pending streamConfig")
                callWebJavaScriptFunction("responseWindowButtonsEnabled", false)
                callWebJavaScriptFunction("startStream", pendingConfig)

            } else {
                ; No pending stream config

                ; NTD
            }

            if (manageState("pendingRender", "get")) {
                ; Pending session render exists

                ; Render markdown to WebView
                manageState("pendingRender", "set", false)
                logStreamDebug("[AHK] checkPageReadyFallback: Rendering pending session markdown")
                renderWebView()
                callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

            } else {
                ; No pending session render

                ; NTD
            }

        } else {
            ; Web page is not yet ready

            if (attempts > 120) {
                ; Max attempts reached (6 seconds)

                ; Force stop fallback timer and attempt render if pending
                SetTimer(checkPageReadyFallback, 0)
                attempts := 0
                logStreamDebug("[AHK] checkPageReadyFallback: Max attempts reached")

                if (manageState("pendingRender", "get")) {
                    ; Pending session render exists on timeout

                    ; Render markdown to WebView
                    manageState("pendingRender", "set", false)
                    renderWebView()
                    callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

                } else {
                    ; No pending session render

                    ; NTD
                }

            } else {
                ; Within attempt limit

                ; Check if JS is responsive
                try {
                    res := responseWindow.ExecuteScript("typeof window.startStream === 'function'")
                    if (res = "true") {
                        ; JS functions are available

                        ; Mark page ready so pending work executes on next check
                        manageState("webPageReady", "set", true)

                    } else {
                        ; JS functions are not yet available

                        ; Wait for next timer tick
                    }
                }
            }
        }
    }
}

sendRequestToLLM(&chatHistoryAsJson, isInitialRequest := false, isSession := false) {

    global gIsChatHistoryDisplayed

    if (isSession) {
        ; Loading an existing session

        ; Initialize model state from session parameters if empty
        sessionModel := (requestParams.Has("modelName") && (requestParams["modelName"] != "")) ? requestParams["modelName"] : ""
        if ((sessionModel != "") && (manageState("model", "get").Length = 0)) {
            ; Session model name exists AND model history is empty

            ; Store model name in state
            manageState("model", "add", sessionModel)

        } else {
            ; Session model name is empty OU model history is not empty

            ; NTD
        }

        ; Show the window and render the existing chat history
        gIsChatHistoryDisplayed := true
        chatData := buildChatHistoryMarkdown(&chatHistoryAsJson)
        manageState("chat", "set", chatData)

        ; Mark pending render BEFORE showResponseWindow so if pageReady arrives during Show, it renders immediately
        manageState("pendingRender", "set", true)

        showResponseWindow("", isInitialRequest)

        if (manageState("webPageReady", "get")) {
            ; Web page is ready

            if (manageState("pendingRender", "get")) {
                ; Pending render still needed

                ; Render markdown content immediately
                manageState("pendingRender", "set", false)
                logStreamDebug("[AHK] Session: webPageReady is true, calling renderWebView immediately")
                renderWebView()
                callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

            } else {
                ; Render was already performed by pageReady handler during showResponseWindow

                ; NTD
            }

        } else {
            ; Web page is not yet ready

            ; Start safety fallback timer
            logStreamDebug("[AHK] Session: webPageReady is false, waiting for pageReady or fallback")
            SetTimer(checkPageReadyFallback, 50)
        }

        return

    } else {
        ; Not loading an existing session

        ; Continue to standard request processing
    }

    if (requestParams["isAutoPaste"]) {
        ; Silent auto-paste mode without showing Response Window
        executeCurlRequest(isInitialRequest, isSession)
        errorMsg := ""
        processLlmResponse(&chatHistoryAsJson, isSession, &errorMsg)
        manageChatHistoryJSON("set", chatHistoryAsJson)
        chatData := buildChatHistoryMarkdown(&chatHistoryAsJson)
        manageState("chat", "set", chatData)
        content := manageState("chat", "get")
        displayOrPasteResponse(content, errorMsg, isInitialRequest, isSession)
        return
    }

    ; Normal streaming mode:
    ; 1. Show the Response Window immediately!
    gIsChatHistoryDisplayed := false
    showResponseWindow("", isInitialRequest)

    ; Apply theme to title bar and web document
    applyResponseWindowTheme()

    ; 2. Prepare streaming payload
    manageState("streaming", "set", true)

    baseUrl := requestParams.Has("llmBaseUrl") ? requestParams["llmBaseUrl"] : gLLM_BASE_URL
    apiKeyVal := requestParams.Has("apiKey") ? requestParams["apiKey"] : APIKey
    completionsUrl := baseUrl "/v1/chat/completions"

    chatHistoryObj := jsongo.Parse(chatHistoryAsJson)

    streamConfig := {
        url: completionsUrl,
        apiKey: apiKeyVal,
        shortModelName: requestParams["modelName"],
        theme: getEffectiveTheme(),
        payload: {
            model: chatHistoryObj["model"],
            messages: chatHistoryObj["messages"],
            stream: true
        }
    }

    logStreamDebug("[AHK] sendRequestToLLM - webPageReady=" (manageState("webPageReady", "get") ? "true" : "false"))

    if (manageState("webPageReady", "get")) {
        ; Web page is ready

        ; Disable buttons, set button label to Chat History, and start stream
        callWebJavaScriptFunction("responseWindowButtonsEnabled", false)
        callWebJavaScriptFunction("updateChatHistoryButton", false)
        callWebJavaScriptFunction("startStream", streamConfig)

    } else {
        ; Web page is not yet ready

        ; Store pending stream config and start safety fallback timer
        manageState("pendingStreamConfig", "set", streamConfig)
        SetTimer(checkPageReadyFallback, 50)
    }
}

executeCurlRequest(isInitialRequest, isSession) {
    if (isSession) {
        ; Session case

        ; NTD
        return
    }

    ; Not a Session (normal case)

    ; Activate loading mouse cursor

    setLoadingCursor(true)

    ;
    ; Launch the cURL command and run it asynchronously
    ;

    ; Run the cURL command to request the LLM (asynchronously, in hidden window) and store the PID
    Run(FileOpen(requestParams["cURLCommandFilePath"], "r", "UTF-8").Read(), , "Hide", &cURLPID)

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

        setLoadingCursor(false)

        if isInitialRequest {
            ; This is the Initial Request

            ; deleteTempFiles()

            ; Notify MainScript that Response Window is closed
            CustomMessages.notifyResponseWindowState(   CustomMessages.WM_RESPONSE_WINDOW_CLOSED,
                                                                requestParams["uniqueID"], 
                                                                responseWindow.hWnd, 
                                                                requestParams["mainScriptHiddenhWnd"])

            ; Then terminates the Response Window script
            ExitApp

        } else {
            ; Not the initial request

            Exit
        }
    }

    ; Reset the PID as the process has completed
    cURLPID := 0
    manageState("cURL", "set", cURLPID)
}

processLlmResponse(&chatHistoryAsJson, isSession, &errorMsg) {
    try {
        ; Read the LLM Response JSON File
        llmResponseAsJson := FileOpen(requestParams["llmResponseJsonFilePath"], "r", "UTF-8").Read()

    } catch as e {
        ; LLM Response File NOT found

        errorMsg :=
            "**⛔ ERROR**"
            . "`n`n"
            . "LLM Response File not found :"
            . "`n`n"
            . requestParams["llmResponseJsonFilePath"]
            . "`n`n---`n`n"
            . "**POSSIBLE REASONS**"
            . "`n`n"
            . "- **LLM** did **not respond**."
            . "`n`n"
            . "- Your disk is **full**."

    } else {
        ; LLM Response File found

        ;
        ; Parse LLM Response and append to Chat History file
        ;

        try {
            ; Parse LLM Response and append to Chat History file
            llmResponse := clsLlmResponse(llmResponseAsJson)

            ; Simplify LLM response, by extracting only some data
            llmResponseSimplified := llmResponse.getLlmResponseSimplified()

            ; Get text after forward slash as llmResponseSimplified.model and replace colon (:) with dash (-)
            llmResponseSimplified.model := StrReplace(SubStr(llmResponseSimplified.model, InStr(llmResponseSimplified.model, "/") + 1), ":", "-")

            manageState("model", "add", llmResponseSimplified.model)

            if (!isSession) {

                ; Append assistant's (LLM's) response to chat history
                chatHistorySingleton.appendToChatHistoryJsonFile(   "assistant",
                                                                     llmResponseSimplified.response, 
                                                                     &chatHistoryAsJson, 
                                                                     requestParams["chatHistoryJsonFilePath"])
            } else {
                ; Loading an existing session

                ; NTD
            }
        } catch as e {
            ; Exception when parsing LLM response OR writing into chatHistoryJsonFilePath

            try {
                llmResponseError := llmResponse.getLlmResponseError()

            } catch as e2 {
                ; Can not extract error message from JSON response

                errorMsg :=
                    "**⛔ ERROR**"
                    . "`n`n"
                    . "Error **parsing** LLM Response to get Error Code"
                    . "`n`n---`n`n"
                    . "**JSON RECEIVED RESPONSE**"
                    . llmResponseAsJson

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
                    . llmResponseError.errorMsg

                ; Map of error codes
                errorCodes := {
                    400: "You may have specified an invalid API model. See [this guide](https://github.com/kdalanon/LLM-AutoHotkey-Assistant/blob/main/README.md#apimodels) on how to get the correct API models.",
                    401: "Authentication failed. Your API key or session might be invalid or expired. Check your keys [here](https://openrouter.ai/settings/keys), re-add it to the app, and try again.",
                    402: "Insufficient funds. Click [here](https://openrouter.ai/credits) to check your available credits.",
                    403: "Content flagged as inappropriate. Your input triggered content moderation and was rejected. Please revise your request and try again with different content.",
                    408: "Request timed out. The API request took too long to process. This might be due to network issues or server overload.",
                    429: "You've hit the rate limit of **" requestParams["modelName"] "**. Try again after some time.",
                    502: "Service temporarily unavailable. The chosen model is either down or returned an invalid response. Please try again later or select a different model.",
                    503: "No suitable model available. There are no providers currently meeting your request requirements. Please try again later or adjust your routing settings."
                }

                ; Concat Error message according to error code
                errorMsg .= errorCodes.%llmResponseError.errorCode%

            } finally {

                ; NTD
            }
        } ; catch

    } finally {

        ; NTD
    }
}

buildChatHistoryMarkdown(&chatHistoryAsJson) {
    ; Begin by parsing the Chat History JSON string into an object
    chatHistory := jsongo.Parse(chatHistoryAsJson)

    ; Get the messages array
    messages := chatHistorySingleton.getChatHistoryMessages(chatHistory)
    totalMessages := messages.Length
    chatHistoryAsMarkdown := ""
    assistantCount := 0
    modelList := manageState("model", "get")
    defaultModel := (requestParams.Has("modelName") && (requestParams["modelName"] != "")) ? requestParams["modelName"] : "Assistant"

    ; Chat History - Iterate over each message in the 'messages' array
    for index, message in messages {
        role := message.role
        content := message.content

        switch role {
            case "system": chatHistoryAsMarkdown .= "**🔧 System Prompt**`n`n" content
            case "user": chatHistoryAsMarkdown .= "`n`n---`n`n**🔵 You**`n`n" content
            case "assistant":
                assistantCount++
                if (assistantCount <= modelList.Length) {
                    ; Model is recorded in the model list for this assistant turn

                    ; Use the recorded model name
                    modelLabel := modelList[assistantCount]

                } else {
                    ; Model is not in model list (e.g. reopened session or fewer recorded turns)

                    ; Fall back to default model from request parameters
                    modelLabel := defaultModel

                }
                chatHistoryAsMarkdown .= "`n`n---`n`n**🟡 " modelLabel "**`n`n" content
        }
    } ; for

    ; Latest Response - Iterate backwards over each message in the 'messages' array to find the last assistant message
    ; and calculate the current index starting from the end
    
    latestResponseAsMarkdown := "⚠️ No LLM Response yet."
    loop totalMessages {
        currentIndex := totalMessages - A_Index + 1  ;
        msg := messages[currentIndex]
        if (msg.role = "assistant") {
            ; Role is assistant

            ; Extract latest response content and exit loop
            latestResponseAsMarkdown := msg.content
            break

        } else {
            ; Role is not assistant

            ; NTD
        }
    }

    return { chatHistory: chatHistoryAsMarkdown, latestResponse: latestResponseAsMarkdown }
}

displayOrPasteResponse(content, errorMsg, isInitialRequest, isSession) {
    if (errorMsg = "") {
        ; No error

        if !isSession && requestParams["isAutoPaste"] {
            ; Auto-paste the response into the active window

            ; TODO M 2025_06_26 : Should Activate the calling Window because another window could have been activated since the call

            A_Clipboard := content.latestResponse

            Send("^v")

            ; TODO m 2025_06_26 : Should factorize (See closeAndStop() )

            setLoadingCursor(false)

            CustomMessages.notifyResponseWindowState(   CustomMessages.WM_RESPONSE_WINDOW_CLOSED, 
                                                                requestParams["uniqueID"],
                                                                responseWindow.hWnd, 
                                                                requestParams["mainScriptHiddenhWnd"]
                                                            )

            ; deleteTempFiles()

            ; Stop Response Window.ahk script
            ExitApp

        } else {
            ; Session or Not Auto-paste mode

            ; Display Mode "Full Chat History" if is existing Session, "Latest response" otherwise
            gIsChatHistoryDisplayed := isSession

            ; Display the response in the Response Window
            showResponseWindow(""
                             , isInitialRequest
                             , !isInitialRequest && !(WinActive(responseWindow.hWnd)))

            ; Enable buttons in the response window
            callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

            ; Stop loading mouse cursor
            setLoadingCursor(false)
        }
    } else {
        ; There is an error message to display

        ; Show Response Window
        showResponseWindow(errorMsg, isInitialRequest)

        ; Enable Response Window buttons
        callWebJavaScriptFunction("responseWindowButtonsEnabled", true)

        ; Stop loading Cursor
        setLoadingCursor(false)
    }
}

;
; Function to show the Response Window using WebView
; (This method does not block execution)
;
showResponseWindow(responseWindowTextContent := "", isInitialRequest := false, noActivate := false) {

    if isInitialRequest {
        pos := calculateResponseWindowPosition(requestParams["numberOfAPIModels"], requestParams["APIModelsIndex"])

        ; Display the Response Window immediately
        responseWindow.Show(pos, requestParams["responseWindowTitle"])

        ; Focus the WebView2 controller so keyboard events work immediately
        try {
            responseWindow.MoveFocus(0)
        }
    }
    
    if (responseWindowTextContent != "") {
        renderWebView(responseWindowTextContent)
    }
    
    responseWindow.IsVisible := true
    
    ; Flash the Response Window if it is minimized or not active
    (WinGetMinMax(responseWindow.hWnd) = -1) || noActivate ? responseWindow.Flash() : ""
}

; Render the provided Markdown or the one obtained by manageState("chat", "get") according to gIsChatHistoryDisplayed
; Update button accordingly
renderWebView(responseWindowTextContent := "") {
    
    ; MsgBox("buttonClickAction() 1 : gIsChatHistoryDisplayed : " gIsChatHistoryDisplayed)
    
    if (responseWindowTextContent = "") {
        
        content := manageState("chat", "get")

        contentToDisplay := gIsChatHistoryDisplayed ? content.chatHistory : content.latestResponse

    } else {

        contentToDisplay := responseWindowTextContent
    }

    ; MsgBox("buttonClickAction() 2 : gIsChatHistoryDisplayed : " gIsChatHistoryDisplayed "`n`n" contentToDisplay)

    ; Ensure current theme is applied to DOM and title bar
    applyResponseWindowTheme()

    callWebJavaScriptFunction("renderMarkdown", 
                               Map("content", contentToDisplay, 
                                   "isChatHistoryDisplayed", gIsChatHistoryDisplayed))

    ; Focus the WebView2 controller so keyboard events work immediately
    try {
        responseWindow.MoveFocus(0)
    }
}
