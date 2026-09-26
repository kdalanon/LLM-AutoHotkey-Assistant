#Requires AutoHotkey v2.0.18+

;******************************************************************************
;
; ATTENTION : Ce fichier est #Include dans deux Process distincts : 
;               - LLM AutoHotkey Assistant.ahk
;               - Response Window.ahk
;
;******************************************************************************

; ----------------------------------------------------
; clsLlmResponse : Handle an LLM Response
;
; ----------------------------------------------------

class clsLlmResponse {

    __New(llmResponseAsJson) {

        this.llmResponseAsJson := llmResponseAsJson

        ; Parse JSON LLM response
        this.llmResponse := jsongo.Parse(this.llmResponseAsJson)
    }

    getLlmResponseSimplified() {

        choiceMessage := this.llmResponse.Get("choices")[1].Get("message")
        msgContent := ""
        reasoningContent := ""

        if (choiceMessage.Has("content")) {
            ; Content key present

            ; Read content string
            msgContent := choiceMessage.Get("content")

        } else {
            ; Content key not present

            ; Set empty content
            msgContent := ""
        }

        if (choiceMessage.Has("reasoning_content")) {
            ; Has reasoning_content property

            ; Read reasoning_content
            reasoningContent := choiceMessage.Get("reasoning_content")

        } else if (choiceMessage.Has("reasoning")) {
            ; Has reasoning property

            ; Read reasoning
            reasoningContent := choiceMessage.Get("reasoning")

        } else {
            ; Neither reasoning_content nor reasoning present

            ; No reasoning content
            reasoningContent := ""
        }

        if (reasoningContent != "") {
            ; Reasoning content exists

            ; Format reasoning into collapsible block and prepend to content
            msgContent := "<details class=`"reasoning-block`">`n<summary class=`"reasoning-summary`">💭 Réflexion</summary>`n`n" . Trim(reasoningContent) . "`n`n</details>`n`n" . msgContent

        } else {
            ; No reasoning content exists

            ; Keep message content unchanged
        }

        model := this.llmResponse.Get("model")

        simplifiedResult := {
            response: msgContent,
            model: model
        }

        return simplifiedResult
    }

    getLlmResponseError() {

        error := this.llmResponse.Get("error").Get("message")
        code := this.llmResponse.Get("error").Get("code")

        return {
            errorMsg: error,
            errorCode: code
        }
    }

}
