#Requires AutoHotkey v2.0

chatSendButtonAction(*) {

    if chatInputWindow.validateInputAndHide() {
        ; Input Window has been hidden

        ; Disable Response Window Buttons while waiting for LLM response
        callWebJavaScriptFunction("responseWindowButtonsEnabled", false)

        ;
        ; Append UserPrompt (from InputWindow) to Chat History
        ;

        chatHistoryAsJson := manageChatHistoryJSON("get")

        chatHistorySingleton.appendToChatHistoryJsonFile(   "user",
                                                            chatInputWindow.EditControl.Value,
                                                            &chatHistoryAsJson,
                                                            requestParams["chatHistoryJsonFilePath"])

        manageChatHistoryJSON("set", chatHistoryAsJson)

        ;
        ; Send the request to the LLM
        ;

        sendRequestToLLM(&chatHistoryAsJson)
        
    } else {
        ; Input Window has NOT been hidden
        
        ; NTD
    }
}