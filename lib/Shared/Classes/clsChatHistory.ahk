#Requires AutoHotkey v2.0.18+

;******************************************************************************
;
; ATTENTION : Ce fichier est #Include dans deux Process distincts : 
;               - LLM AutoHotkey Assistant.ahk
;               - Response Window.ahk
;
;******************************************************************************

; ----------------------------------------------------
; clsChatHistory : Method to handle Chat History file
;
; Build (but do not run) a Curl command to call LLM
; ----------------------------------------------------

class clsChatHistory {

    ; __New(chatHistoryJsonFilePath) {

    ;     this.chatHistoryJsonFilePath := chatHistoryJsonFilePath
    ; }

    createChatHistoryJsonFile(modelFullName, systemPrompt, userPrompt, chatHistoryJsonFilePath) {

        global JSON_INDENT_SPACER

        initialChatHistory := {}

        initialChatHistory.model := modelFullName

        initialChatHistory.messages := [
            {
                role: "system",
                content: systemPrompt
            }, {
                role: "user",
                content: userPrompt
            }
        ]
        
        ; Create the chatHistoryAsJson
        chatHistoryAsJson := jsongo.Stringify(initialChatHistory, , JSON_INDENT_SPACER)
    
        FileOpen(chatHistoryJsonFilePath, "w", "UTF-8-RAW").Write(chatHistoryAsJson)
    }

    appendToChatHistoryJsonFile(role, message, &chatHistoryAsJson, chatHistoryJsonFilePath) {
    
        global JSON_INDENT_SPACER

        chatHistory := jsongo.Parse(chatHistoryAsJson)
        
        chatHistory["messages"].Push(
            {
                role: role,
                content: message
            }
        )

        chatHistoryAsJson := jsongo.Stringify(chatHistory, , JSON_INDENT_SPACER)
        
        ; Write to file
        FileOpen(chatHistoryJsonFilePath, "w", "UTF-8-RAW").Write(chatHistoryAsJson)
    }

    ; Response Window
    
    getChatHistoryMessages(chatHistory) {
        messages := []
        for msg in chatHistory["messages"] {
            messages.Push(
                {
                    role: msg["role"],
                    content: msg["content"]
                }
            )
        }
        return messages
    }
    
    removeLastAssistantMessage(&chatHistoryAsJson) {
        
        global JSON_INDENT_SPACER

        chatHistory := jsongo.Parse(chatHistoryAsJson)

        messagesArray := chatHistory["messages"]
        lastIndex := messagesArray.Length
        if (messagesArray[lastIndex]["role"] = "assistant") {
            messagesArray.RemoveAt(lastIndex)
        }

        chatHistoryAsJson := jsongo.Stringify(chatHistory, , JSON_INDENT_SPACER)
    }
}
