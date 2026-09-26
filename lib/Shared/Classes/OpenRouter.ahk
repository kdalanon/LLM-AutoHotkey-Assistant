#Requires AutoHotkey v2.0.18+

;******************************************************************************
;
; ATTENTION : Ce fichier est #Include dans deux Process distincts : 
;               - LLM AutoHotkey Assistant.ahk
;               - Response Window.ahk
;
;******************************************************************************

; ----------------------------------------------------
; OpenRouter : LLM Request Builder
;
; Build (but do not run) a Curl command to call LLM
; ----------------------------------------------------

class OpenRouter {

    __New(llmBaseUrl, APIKey) {

        this.APIKey := APIKey

        this.cURLCommand :=
        'cURL.exe ' llmBaseUrl '/v1/chat/completions'
        . ' --silent'
        . ' --request POST'
        . ' -H "Authorization: Bearer {1}"'
        . ' -H "X-Title: LLM AutoHotkey Assistant"'
        . ' -H "Content-Type: application/json"'
        . ' --data @"{2}"'
        . ' --output "{3}"' 
    }

    buildcURLCommand(chatHistoryJsonFilePath, llmResponseJsonFilePath) {

        return Format(this.cURLCommand, 
                      this.APIKey, 
                      chatHistoryJsonFilePath, 
                      llmResponseJsonFilePath)
    }
}
