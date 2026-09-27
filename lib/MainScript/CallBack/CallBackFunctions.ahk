#Requires AutoHotkey v2.0

; Callback (= Handler) called when Response Window sends OPENED, CLOSED, ... events to MainScript
; Handler params are (wparam => wparam_uniqueID, lparam => emitterhWnd, msgNumber, targethWnd)
onResponseWindowStateChanged(wparam_uniqueID, lparam_emitterResponseWindowhWnd, msgNumber, targetMainScriptHiddenhWnd) {

    static responseWindowLoadingCount := 0
    static reloadScript := false

    switch msgNumber {
        case CustomMessages.WM_RESPONSE_WINDOW_OPENED:
            if getMapId2ActiveResponseWindowParams().Has(wparam_uniqueID) {

                ; Store Response Window's hWnd in map
                getMapId2ActiveResponseWindowParams()[wparam_uniqueID]["hWnd"] := lparam_emitterResponseWindowhWnd

            } else {
                ; Response Window UniqueID is not known by MainScript

                MsgBox("WARNING : WM_RESPONSE_WINDOW_OPENED : Response Window UniqueID (" wparam_uniqueID ") is not known by MainScript", , "T2")

            }

        case CustomMessages.WM_RESPONSE_WINDOW_CLOSED:
            if getMapId2ActiveResponseWindowParams().Has(wparam_uniqueID) {

                ; Remove from map
                getMapId2ActiveResponseWindowParams().Delete(wparam_uniqueID)
                
                ; Update cursor and tooltip
                manageCursorAndToolTip("Update")

            }

            if (getMapId2ActiveResponseWindowParams().Count = 0) && reloadScript {
                ; All Response Windows are closed and reload is pending

                setPromptsReloadedFlag()
                Reload()

            } else {
                ; No reload needed
            }

        case CustomMessages.WM_RESPONSE_WINDOW_RESTORED:
            ; Response Window replied to our PING, rebuild its entry in the map
            if !getMapId2ActiveResponseWindowParams().Has(wparam_uniqueID) {
                ; Entry does not exist, rebuild from params file

                ; Find and read the params file for this uniqueID

                sessionDir := getSessionDir()
                paramsFile := findParamsFileByUniqueID(sessionDir, wparam_uniqueID)
                
                if (paramsFile != "") {
                    ; Params file found

                    ; Read the params file

                    paramsContent := FileOpen(paramsFile, "r", "UTF-8").Read()
                    paramsMap := jsongo.Parse(paramsContent)
                    
                    ; Update mainScriptHiddenhWnd and hWnd

                    paramsMap["mainScriptHiddenhWnd"] := targetMainScriptHiddenhWnd
                    paramsMap["hWnd"] := lparam_emitterResponseWindowhWnd
                    
                    ; Convert Map to inner Map (already a Map from jsongo.Parse)
                    getMapId2ActiveResponseWindowParams()[wparam_uniqueID] := paramsMap

                } else {
                    ; Params file not found

                    ; NTD
                }

            } else {
                ; Entry already exists, just update hWnd

                getMapId2ActiveResponseWindowParams()[wparam_uniqueID]["hWnd"] := lparam_emitterResponseWindowhWnd

            }

        case CustomMessages.WM_RESPONSE_WINDOW_LOADING_START:
            if getMapId2ActiveResponseWindowParams().Has(wparam_uniqueID) {

                ; Mark as loading
                getMapId2ActiveResponseWindowParams()[wparam_uniqueID]["isLoading"] := true
                
                ; Increment loading counter
                responseWindowLoadingCount++

                if (responseWindowLoadingCount = 1) {
                    ; First loading window

                    manageCursorAndToolTip("Loading")

                } else {
                    ; Additional loading windows

                }
    
                ; Update cursor and tooltip
                manageCursorAndToolTip("Update")

            } else {
                ; Response Window UniqueID is not known by MainScript

                MsgBox("WARNING : WM_RESPONSE_WINDOW_LOADING_START : Response Window UniqueID (" wparam_uniqueID ") is not known by MainScript", , "T2")

            }

        case CustomMessages.WM_RESPONSE_WINDOW_LOADING_FINISH:
            if (responseWindowLoadingCount > 0 && getMapId2ActiveResponseWindowParams().Has(wparam_uniqueID)) {

                ; Decrement loading counter
                responseWindowLoadingCount--

                ; Mark as not loading
                getMapId2ActiveResponseWindowParams()[wparam_uniqueID]["isLoading"] := false

                if (responseWindowLoadingCount = 0) {
                    ; Last loading window finished

                    manageCursorAndToolTip("Reset")

                } else {
                    ; Other loading windows still active

                    manageCursorAndToolTip("Update")
                }
            } else {
                ; No active loading or uniqueID not found

            }

        case "reloadScript": reloadScript := true
    }
}

