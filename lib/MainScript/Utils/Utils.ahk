#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Function to get selected text
; ----------------------------------------------------
getSelectedText() {

    ; Backup clipboard before copying
    ClipSaved := ClipboardAll()   ; Save the entire clipboard to a variable of your choice.

    ; Empty clipboard before requesting copy
    A_Clipboard := ""
    Sleep(30)

    Send("^c")

    if !ClipWait(0.35, 0) {
        ; Clipboard did not receive any text within timeout (nothing selected)
        selectedText := ""

        ; Restore clipboard immediately without waiting
        A_Clipboard := ClipSaved

    } else {
        ; Text successfully copied to clipboard
        selectedText := Trim(A_Clipboard, OmitChars := " `t`r`n")

        ; Brief delay to allow clipboard history tools to capture the text before restoring
        Sleep(50)

        ; Restore clipboard
        A_Clipboard := ClipSaved
    }

    ClipSaved := ""             ; Free the memory in case the clipboard was very large.
    
    ; Return the selected text
    return selectedText
}

; ----------------------------------------------------
; Cursor and Tooltip management
; ----------------------------------------------------

manageCursorAndToolTip(action) {
    switch action {
        case "Update":
            ; ToolTip disabled - Response Window is displayed immediately
            return

        case "Loading":
            ; Cursor change disabled - Response Window is displayed immediately
            return

        case "Reset":
            ToolTip
            DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)
    }
}

; ----------------------------------------------------
; Manage prompt states (store global variable)
; ----------------------------------------------------

managePromptState(component, action, data := {}) {
    static state := {
        prompts: prompts,                        ; Array of ALL user's prompts (in Prompts.ahk)
        selectedPrompt: {},                      ; Prompt associated to selected menu
        promptNameToSendMessageTo: {},           ; Prompt Name for "Send to all open with same prompt name"
        uniqueIDToSendMessageTo: {}              ; uniqueID of Window for "Send to"
    }

    switch component {
        case "prompts":
            switch action {
                case "get": return state.prompts
                case "set": state.prompts := data                   ; Never used
            }

        case "selectedPrompt":
            switch action {
                case "get": return state.selectedPrompt
                case "set": state.selectedPrompt := data
            }

        case "promptNameToSendMessageTo":
            switch action {
                case "get": return state.promptNameToSendMessageTo
                case "set": state.promptNameToSendMessageTo := data
            }

        case "uniqueIDToSendMessageTo":
            switch action {
                case "get": return state.uniqueIDToSendMessageTo
                case "set": state.uniqueIDToSendMessageTo := data
            }
    }
}

;******************************************************************************
; Debugging utilities
;******************************************************************************

; ----------------------------------------------------
; Function to save debug state
; ----------------------------------------------------

saveDebugState(paramsFilePath, isSession, mainHwnd, callingHwnd) {
    global jsongo
    debugFilePath := getSessionDir() "\LLM_Ahk_DEBUG_LAST_SESSION.json"
    
    debugData := {
        paramsForResponseWindowJsonFilePath: paramsFilePath,
        isSession: isSession,
        mainScriptHiddenhWnd: mainHwnd,
        callingWindowHwnd: callingHwnd
    }
    
    try {
        FileOpen(debugFilePath, "w", "UTF-8-RAW").Write(jsongo.Stringify(debugData, , JSON_INDENT_SPACER))
    } catch {
        ; Silently fail if debug file cannot be written
    }
}


