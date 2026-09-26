#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Input Window actions
; ----------------------------------------------------

customPromptSendButtonAction(inputWindow, *) {

    if !customPromptInputWindow.validateInputAndHide() {
        return
    }

    selectedPrompt := managePromptState("selectedPrompt", "get")

    makeParamFilesAndStartResponseWindow( selectedPrompt.promptName
                                        , selectedPrompt.menuText
                                        , selectedPrompt.systemPrompt
                                        , selectedPrompt.APIModels
                                        , selectedPrompt.HasProp("copyAsMarkdown") && selectedPrompt.copyAsMarkdown
                                        , selectedPrompt.HasProp("isAutoPaste") && selectedPrompt.isAutoPaste
                                        , selectedPrompt.HasProp("skipConfirmation") && selectedPrompt.skipConfirmation
                                        , customPromptInputWindow.EditControl.Value
                                        , customPromptInputWindow.selectedText
    )
    customPromptInputWindow.EditControl.Value := ""
}

sendToUniqueIDSendButtonAction(inputWindow, *) {

    if (getMapId2ActiveResponseWindowParams().Count = 0) {
        MsgBox "No Response Windows found. Message not sent.", "Send message to session", "IconX"
        sendToUniqueIDInputWindow.guiObj.Hide
        return
    }

    if !sendToUniqueIDInputWindow.validateInputAndHide() {
        return
    }

    if (!targetUniqueID := managePromptState("uniqueIDToSendMessageTo", "get")) {
        return
    }

    if !getMapId2ActiveResponseWindowParams().Has(targetUniqueID) {
        MsgBox "Session not found. Message not sent.", "Send message to session", "IconX"
        sendToUniqueIDInputWindow.guiObj.Hide
        return
    }

    activeResponseWindowParams := getMapId2ActiveResponseWindowParams()[targetUniqueID]

    chatHistoryAsJson := FileOpen(activeResponseWindowParams["chatHistoryJsonFilePath"], "r", "UTF-8").Read()

    userPrompt := sendToUniqueIDInputWindow.EditControl.Value

    if (sendToUniqueIDInputWindow.selectedText != "") {
        userPrompt .= "`n`n" sendToUniqueIDInputWindow.selectedText
    }

    chatHistorySingleton.appendToChatHistoryJsonFile(   "user", 
                                                        userPrompt, 
                                                        &chatHistoryAsJson, 
                                                        activeResponseWindowParams["chatHistoryJsonFilePath"]
                                                    )

    responseWindowhWnd := activeResponseWindowParams["hWnd"]

    CustomMessages.notifyResponseWindowState(CustomMessages.WM_SEND_TO_ALL_MODELS, targetUniqueID, , responseWindowhWnd)

    ; WinActivate("ahk_id " responseWindowhWnd)

    sendToUniqueIDInputWindow.EditControl.Value := ""
}

;
; Send UserPrompt to all open windows whith same prompt name
;
sendToAllOpenWithSamePromptNameSendButtonAction(inputWindow, *) {

    if (getMapId2ActiveResponseWindowParams().Count = 0) {
        MsgBox "No Response Windows found. Message not sent.", "Send message to all windows with same prompt name", "IconX"
        sendToAllModelsInputWindow.guiObj.Hide
        return
    }

    if !sendToPromptNameInputWindow.validateInputAndHide() {
        return
    }

    if (!targetPromptName := managePromptState("promptNameToSendMessageTo", "get")) {
        return
    }

    ; Send message only to active models that belong to this prompt
    for uniqueID, activeResponseWindowParams in getMapId2ActiveResponseWindowParams() {

        ; Check if this model belongs to the selected prompt
        if (activeResponseWindowParams["promptName"] != targetPromptName) {
            ; Not the searched PromptName

            ; Continue to search

        } else {
            ; We are on the searched PromptName

            ; Add user's prompt to chat history

            chatHistoryAsJson := FileOpen(activeResponseWindowParams["chatHistoryJsonFilePath"], "r", "UTF-8").Read()

            userPrompt := sendToPromptNameInputWindow.EditControl.Value

            if (sendToPromptNameInputWindow.selectedText != "") {
                userPrompt .= "`n`n" sendToPromptNameInputWindow.selectedText
            }

            chatHistorySingleton.appendToChatHistoryJsonFile(   "user", 
                                                                userPrompt, 
                                                                &chatHistoryAsJson, 
                                                                activeResponseWindowParams["chatHistoryJsonFilePath"]
                                                            )
    
            responseWindowhWnd := activeResponseWindowParams["hWnd"]

            ; Notify the Response Window to re-read the JSON file and call sendRequestToLLM() again
            CustomMessages.notifyResponseWindowState(CustomMessages.WM_SEND_TO_ALL_MODELS, uniqueID, , responseWindowhWnd)

            ; Bring the Response Window to the foreground
            WinActivate("ahk_id " responseWindowhWnd)
        }
    }

    sendToPromptNameInputWindow.EditControl.Value := ""
}


;
; Send UserPrompt to all open windows
;
sendToAllModelsSendButtonAction(inputWindow, *) {

    if (getMapId2ActiveResponseWindowParams().Count = 0) {
        MsgBox "No Response Windows found. Message not sent.", "Send message to all models", "IconX"
        sendToAllModelsInputWindow.guiObj.Hide
        return
    }

    if !sendToAllModelsInputWindow.validateInputAndHide() {
        return
    }

    ; The main script must know each Response Window's JSON file
    ; so it can read it, parse it, append the new
    ; user message, then write it back
    for uniqueID, activeResponseWindowParams in getMapId2ActiveResponseWindowParams() {

        chatHistoryAsJson := FileOpen(activeResponseWindowParams["chatHistoryJsonFilePath"], "r", "UTF-8").Read()

        chatHistorySingleton.appendToChatHistoryJsonFile(   "user", 
                                                            sendToAllModelsInputWindow.EditControl.Value, 
                                                            &chatHistoryAsJson, 
                                                            activeResponseWindowParams["chatHistoryJsonFilePath"])

        ; Notify the Response Window to re-read the JSON file and call sendRequestToLLM() again
        CustomMessages.notifyResponseWindowState(CustomMessages.WM_SEND_TO_ALL_MODELS, uniqueID, , activeResponseWindowParams["hWnd"])
    }
}