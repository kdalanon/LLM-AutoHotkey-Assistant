#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Sessions Management
; ----------------------------------------------------

/**
 * Scans the session directory for session parameter files and returns a list of session objects.
 * Each object contains:
 *   - uniqueID: The unique ID of the session
 *   - paramsForResponseWindowJsonFilePath: The full path to the paramsForResponseWindow.json file
 *   - responseWindowTitle: The title of the response window
 *   - isActive: Boolean, true if the window is currently open
 */
getSessions() {
    global jsongo
    global JSON_INDENT_SPACER
    
    sessions := []
    orderNb := 0

    ; Scan session directory for parameter files
    sessionDir := getSessionDir()
    loop files, sessionDir "\LLM_Ahk_*_paramsForResponseWindow.json" {

        paramsForResponseWindowJsonFilePath := A_LoopFileFullPath

        orderNb++
        
        try {
            paramsForResponseWindowAsJsonFile := FileOpen(paramsForResponseWindowJsonFilePath, "r", "UTF-8")
            paramsForResponseWindowAsJson := paramsForResponseWindowAsJsonFile.Read()
            paramsForResponseWindowAsJsonFile.Close()
            paramsForResponseWindow := jsongo.Parse(paramsForResponseWindowAsJson)
            
            ; Add session

            sessions.Push({
                uniqueID: paramsForResponseWindow["uniqueID"],
                paramsForResponseWindowJsonFilePath: paramsForResponseWindowJsonFilePath,
                promptName: paramsForResponseWindow["promptName"],
                userPrompt: paramsForResponseWindow["userPrompt"],
                isFavorite: paramsForResponseWindow.Has("isFavorite") ? paramsForResponseWindow["isFavorite"] : false,
                orderNb: orderNb
            })

        } catch {
            ; Skip files that can't be parsed

            continue
        }
    } ; loop

    return sessions
}

/**
 * Deletes all 4 files associated with a session.
 * @param paramsForResponseWindowJsonFilePath Full path to the paramsForResponseWindow.json file
 */
deleteSession(ItemName, ItemPos, MyMenu, paramsForResponseWindowJsonFilePath) {
    global jsongo
    try {
        paramsForResponseWindow := jsongo.Parse(FileOpen(paramsForResponseWindowJsonFilePath, "r", "UTF-8").Read())
        
        ; Use the existing deleteTempFiles logic if possible, 
        ; but we need to be careful with scope.
        ; We'll implement it here to be safe.
        
        try FileDelete(paramsForResponseWindow["chatHistoryJsonFilePath"])
        try FileDelete(paramsForResponseWindow["cURLCommandFilePath"])
        try FileExist(paramsForResponseWindow["llmResponseJsonFilePath"]) ? FileDelete(paramsForResponseWindow["llmResponseJsonFilePath"]) : ""
        try FileDelete(paramsForResponseWindowJsonFilePath)
        
        ; Display message during 1 second
        MsgBox("Session deleted", , "T1.5")
        return true
        
    } catch {
        MsgBox("Error deleting session")
        return false
    }
}

/**
 * Deletes a session and all older sessions.
 * @param paramsForResponseWindowJsonFilePath Full path to the paramsForResponseWindow.json file of the session to keep.
 */
deleteOldersSessions(ItemName, ItemPos, MyMenu, paramsForResponseWindowJsonFilePath) {
    global jsongo
    
    try {
        ; 1. Get current session params
        paramsForResponseWindow := jsongo.Parse(FileOpen(paramsForResponseWindowJsonFilePath, "r", "UTF-8").Read())
        currentUniqueID := paramsForResponseWindow["uniqueID"]
        
        ; 2. Get all sessions to identify olders
        allSessions := getSessions()
        
        ; 3. Find the current session's orderNb to compare
        currentOrderNb := 0
        for session in allSessions {
            if (session.uniqueID = currentUniqueID) {
                currentOrderNb := session.orderNb
                break
            }
        }
        
        if (currentOrderNb = 0) {
            MsgBox("Error: Could not determine order of the current session.")
            return false
        }

        ; 4. Identify sessions to delete (those with orderNb <= current currentOrderNb, not favorite, and not active)
        sessionsToDelete := []
        for session in allSessions {
            if (session.orderNb <= currentOrderNb && !session.isFavorite && !getMapId2ActiveResponseWindowParams().Has(session.uniqueID)) {
                sessionsToDelete.Push(session.paramsForResponseWindowJsonFilePath)
            }
        }

        if (sessionsToDelete.Length = 0) {

            MsgBox("No older sessions to delete.")

            return false

        } else {

            ; 4.5. Ask for confirmation

            confirmMsg := "Are you sure you want to delete " sessionsToDelete.Length " older session(s)?"
            confirmResult := MsgBox(confirmMsg, "Confirmation", "OKCancel Default2 Icon!")
            if (confirmResult != "OK") {

                return false

            } else {

                ; 5. Delete the old sessions
                for filePath in sessionsToDelete {
                    try {
                        params := jsongo.Parse(FileOpen(filePath, "r", "UTF-8").Read())
                        try FileDelete(params["chatHistoryJsonFilePath"])
                        try FileDelete(params["cURLCommandFilePath"])
                        try FileExist(params["llmResponseJsonFilePath"]) ? FileDelete(params["llmResponseJsonFilePath"]) : ""
                        try FileDelete(filePath)
                    } catch {
                        ; Continue even if one fails
                    }
                } ; for
        
                MsgBox(sessionsToDelete.Length " older session(s) deleted.", , "T1.5")
                return true
            }

        }
    } catch Error as err {
        MsgBox("Error deleting older sessions: " err.Message)
        return false
    }
}

/**
 * Toggles the isFavorite property in the session's paramsForResponseWindow.json file.
 * @param paramsForResponseWindowJsonFilePath Full path to the paramsForResponseWindow.json file
 */
toggleFavoriteSession(ItemName, ItemPos, MyMenu, paramsForResponseWindowJsonFilePath) {
    global jsongo
    try {
        paramsForResponseWindowAsJsonFile := FileOpen(paramsForResponseWindowJsonFilePath, "r", "UTF-8")
        paramsForResponseWindowAsJson := paramsForResponseWindowAsJsonFile.Read()
        paramsForResponseWindowAsJsonFile.Close()
        paramsForResponseWindow := jsongo.Parse(paramsForResponseWindowAsJson)
        
        ; Toggle isFavorite
        currentFavorite := paramsForResponseWindow.Has("isFavorite") ? paramsForResponseWindow["isFavorite"] : false
        paramsForResponseWindow["isFavorite"] := !currentFavorite
        
        ; Write back to file
        paramsForResponseWindowAsJson := jsongo.Stringify(paramsForResponseWindow, , JSON_INDENT_SPACER)
        FileOpen(paramsForResponseWindowJsonFilePath, "w", "UTF-8-RAW").Write(paramsForResponseWindowAsJson)
        
        ; Also update the in-memory map if the session is active
        uniqueID := paramsForResponseWindow["uniqueID"]
        if (getMapId2ActiveResponseWindowParams().Has(uniqueID)) {
            getMapId2ActiveResponseWindowParams()[uniqueID]["isFavorite"] := paramsForResponseWindow["isFavorite"]
        }
        
        return true
        
    } catch {
        MsgBox("Error toggling favorite status")
        return false
    }
}

/**
 * Opens a session by running the ResponseWindow script with the provided params file.
 * @param paramsForResponseWindowJsonFilePath Full path to the paramsForResponseWindow.json file
 */
openSession(ItemName, ItemPos, MyMenu, paramsForResponseWindowJsonFilePath) {

    try {
        mainScriptHiddenhWnd := A_ScriptHwnd
        callingWindowHwnd := WinActive("A")

        paramsForResponseWindowAsJson := FileOpen(paramsForResponseWindowJsonFilePath, "r", "UTF-8").Read()
        paramsForResponseWindow := jsongo.Parse(paramsForResponseWindowAsJson)
        
        uniqueID := paramsForResponseWindow["uniqueID"]

        ;
        ; If a Response Window with this uniqueID is already open, bring it to the foreground
        ;

        if (getMapId2ActiveResponseWindowParams().Has(uniqueID)) {
            ; The uniqueID is in the map

            ; Check that the hWnd is still valid

            existingHWnd := getMapId2ActiveResponseWindowParams()[uniqueID]["hWnd"]

            if (WinExist("ahk_id " existingHWnd)) {
                ; The hWnd exists

                ; Activate the window and do not launch a new window

                WinActivate("ahk_id " existingHWnd)
                shouldLaunch := false

            } else {
                ; The hWnd no longer exists (window force-closed)

                ; Clean the map and launch a new window

                getMapId2ActiveResponseWindowParams().Delete(uniqueID)
                shouldLaunch := true

            }

        } else {
            ; The uniqueID is not in the map

            ; Add the session and launch a new window

            shouldLaunch := true

            paramsForResponseWindow["mainScriptHiddenhWnd"] := mainScriptHiddenhWnd
            paramsForResponseWindow["callingWindowHwnd"] := callingWindowHwnd

            getMapId2ActiveResponseWindowParams()[uniqueID] := paramsForResponseWindow
        }

        ;
        ; Launch ResponseWindow.ahk with the parameters as arguments and indicate it is a loaded session
        ;

        if (!shouldLaunch) {
            ; shouldLaunch is false

            ; No action needed

        } else {
            ; shouldLaunch is true

            ; We need to find the path to ResponseWindow.ahk. It is in lib\Response Window.ahk
            
            if (gIsDebugMode) {
                ; Debug mode

                ; Show the message only

                saveDebugState(paramsForResponseWindowJsonFilePath, true, mainScriptHiddenhWnd, callingWindowHwnd)

                MsgBox("Parameters prepared.`n`nLaunch the Response Window in Debug mode in VSCode.", "Debug Mode", "Iconi T3")

            } else {
                ; Normal mode

                ; Launch the Response Window
                Run(A_AhkPath . " " . "`"lib\Response Window.ahk`"" . " " . "`"" . paramsForResponseWindowJsonFilePath . "`"" . " " . mainScriptHiddenhWnd . " " . callingWindowHwnd . " " . true)

            }
        }

        return true
        
    } catch {
        return false
    }
}
