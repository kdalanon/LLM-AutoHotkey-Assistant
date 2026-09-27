#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Prompts.ahk Reload Notification
; Displays a MsgBox with timeout on script reload
; ----------------------------------------------------

getPromptsReloadFlagPath() {
    flagPath := A_Temp "\llm_assistant_prompts_reloaded.flag"

    return flagPath
}

setPromptsReloadedFlag() {
    flagPath := getPromptsReloadFlagPath()

    try {
        ; Create flag file to signal a reload event
        FileOpen(flagPath, "w", "UTF-8").Write("1")
    } catch {
        ; Ignore file write error if any
    }

    return
}

checkAndClearPromptsReloadedFlag() {
    flagPath := getPromptsReloadFlagPath()
    isReloaded := false

    if (FileExist(flagPath)) {
        ; Flag file exists indicating script was reloaded

        ; Delete flag file and record reload status
        try {
            FileDelete(flagPath)
        } catch {
            ; Ignore delete error if any
        }
        isReloaded := true

    } else {
        ; Flag file does not exist

        ; NTD
        isReloaded := false
    }

    return isReloaded
}

showPromptsReloadedMsgBox(timeoutSec := 2) {
    MsgBox("Prompts.ahk rechargé avec succès.", "LLM AutoHotkey Assistant", "T" timeoutSec " Iconi")

    return
}
