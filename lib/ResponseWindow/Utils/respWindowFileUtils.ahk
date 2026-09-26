#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Deletes the files created by the main script
; ----------------------------------------------------

deleteTempFiles() {
    try FileDelete(requestParams["chatHistoryJsonFilePath"])
    try FileDelete(requestParams["cURLCommandFilePath"])
    try FileExist(requestParams["llmResponseJsonFilePath"]) ? FileDelete(requestParams["llmResponseJsonFilePath"]) : ""
    try FileDelete(A_Args[1])
}

