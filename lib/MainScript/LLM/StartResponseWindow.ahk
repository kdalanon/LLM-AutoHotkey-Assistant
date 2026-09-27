#Requires AutoHotkey v2.0

; ----------------------------------------------------
; Prepare data in files and start Response Window.ahk (which will connect to LLM API and process request)
; ----------------------------------------------------

; ----------------------------------------------------
; Tracks active models (i.e. Opened Response Windows)
; ----------------------------------------------------

getMapId2ActiveResponseWindowParams() {

    static mapId2ActiveResponseWindowParams := Map()
    
    return mapId2ActiveResponseWindowParams
}

/**
 * Scan existing Response Window windows and notify them of the new MainScript hWnd.
 * Rebuilds getMapId2ActiveResponseWindowParams() from the existing session files.
 */
reconnectToExistingResponseWindows() {

    ; Get the new MainScript hWnd
    newMainScriptHWnd := A_ScriptHwnd

    ; Get session directory
    sessionDir := getSessionDir()

    ; Scan all windows of class AutoHotkeyGUI containing ": LLM AutoHotkey Assistant"
    windowList := WinGetList("ahk_class AutoHotkeyGUI")
    
    for hWnd in windowList {
        ; Get window title
        windowTitle := WinGetTitle("ahk_id " hWnd)
        
        ; Check if this is a Response Window
        if (InStr(windowTitle, ": LLM AutoHotkey Assistant") > 0) {
            
            ; Extract uniqueID from title (14-digit number pattern like 2026070715393201)
            if RegExMatch(windowTitle, "^(\d+) : ", &match) {
                
                uniqueID := Integer(match[1])
                
                CustomMessages.notifyResponseWindowState(CustomMessages.WM_RESPONSE_WINDOW_PING, 
                                                            uniqueID,
                                                            newMainScriptHWnd, 
                                                            hWnd)
            }
        }
    }
}


; ----------------------------------------------------
; Make parameter files and start ResponseWindow
; ----------------------------------------------------
makeParamFilesAndStartResponseWindow(   promptName, 
                                        menuText, 
                                        systemPrompt, 
                                        APIModels, 
                                        copyAsMarkdown, 
                                        isAutoPaste, 
                                        skipConfirmation, 
                                        customPromptMessage := unset,
                                        selectedText := "") {

    global JSON_INDENT_SPACER

    if (selectedText == "") {
        ; No selected text

        if IsSet(customPromptMessage) {
            ; There is a custom prompt

            ; Use custom prompt message without copied text
            userPrompt := customPromptMessage

        } else {
            ; Copy failed and there is no custom prompt

            ; Reset Tooltip
            manageCursorAndToolTip("Reset")

            MsgBox "The attempt to copy text onto the clipboard failed.", "No text copied", "IconX"
            return
        }
    } else if IsSet(customPromptMessage) {
        ; Copy succeeded and there is a custom prompt

        ; Use custom prompt message with copied text
        userPrompt := customPromptMessage "`n`n" selectedText

    } else {
        ; Copy succeeded and there is no custom prompt

        ; Use copied text as prompt without any additional message
        userPrompt := selectedText
    }

    ; Removes newlines, spaces, and splits by comma
    APIModels := StrSplit(RegExReplace(APIModels, "\s+", ""), ",")

    ; Automatically disables isAutoPaste if more than one model is present
    isAutoPaste := (APIModels.Length > 1) ? false : isAutoPaste

    ; Loop to call all Models in APIModels list
    for modelIndex, fullAPIModelName in APIModels {

        if (fullAPIModelName != "") {
            ; There is a valid API Model Name

            ;
            ; Generate sanitized filenames for chat history, cURL command, and cURL output files
            ;
            
            ; Get text before forward slash as providerName
            providerName := SubStr(fullAPIModelName, 1, InStr(fullAPIModelName, "/") - 1)
            
            ; Get text after forward slash as shortModelName
            shortModelName := SubStr(fullAPIModelName, InStr(fullAPIModelName, "/") + 1)
            
            ; Create a prefix for filenames        

            static lastTimestamp := ""
            static counter := 0

            if (timestamp := A_Now) != lastTimestamp {
                lastTimestamp := timestamp
                counter := 0
            }
            counter++

            ; uniqueID MUST be an integer because it is used as wparam_uniqueID in PostMessage()
            uniqueID := Integer(timestamp Format("{:02d}", counter))

            prefix := "LLM_Ahk_" uniqueID "_" promptName "_" shortModelName
            
            ; Define forbidden characters for filenames that must be replaced with underscores
            forbiddenChars := "[\/\\:*?`"<>| ]"
            
            ; Use prefix ans number in order to easily sort files
            sessionDir := getSessionDir()
            paramsForResponseWindowJsonFilePath :=  sessionDir "\" RegExReplace(prefix "_" "1_paramsForResponseWindow.json",  forbiddenChars, "_")
            chatHistoryJsonFilePath :=              sessionDir "\" RegExReplace(prefix "_" "2_chatHistory.json", forbiddenChars, "_")
            cURLCommandFilePath :=                  sessionDir "\" RegExReplace(prefix "_" "3_cURLCommandToLLM.bat", forbiddenChars, "_")
            llmResponseJsonFilePath :=              sessionDir "\" RegExReplace(prefix "_" "4_llmResponse.json",    forbiddenChars, "_")
            
            ;
            ; Write Chat History JSON request to files
            ;
            
            chatHistorySingleton.createChatHistoryJsonFile(fullAPIModelName, systemPrompt, userPrompt, chatHistoryJsonFilePath)
    
            ;
            ; Write cURL command to file
            ;
            
            cURLCommand := router.buildcURLCommand(chatHistoryJsonFilePath, llmResponseJsonFilePath)
    
		    ; Write cURL command to file
		    ; Before running manually this bat file for debug in a cmd.exe window,
		    ; change the code page of the cmd.exe to UTF-8 with the following command : chcp 65001
		    FileOpen(cURLCommandFilePath, "w", "UTF-8").Write(cURLCommand)
            
            ;
            ; Create an object containing all Parameters to provide to the Response Window
            ;
    
            paramsForResponseWindow := {

                uniqueID: uniqueID,

                chatHistoryJsonFilePath: chatHistoryJsonFilePath,
                cURLCommandFilePath: cURLCommandFilePath,
                llmResponseJsonFilePath: llmResponseJsonFilePath,
                
                providerName: providerName,
                modelName: shortModelName,
                fullModelName: fullAPIModelName,
                numberOfAPIModels: APIModels.Length,
                APIModelsIndex: modelIndex,
                
                llmBaseUrl: gLLM_BASE_URL,
                apiKey: APIKey,
                
                promptName: promptName,
                menuText: menuText,
                userPrompt: userPrompt,
                ; systemPrompt: systemPrompt,
                
                responseWindowTitle: uniqueID " : " promptName " [" shortModelName "]" " : " gVersionStringSuffix,
                
                copyAsMarkdown: copyAsMarkdown,
                isAutoPaste: isAutoPaste,
                skipConfirmation: skipConfirmation,
                isFavorite: false,
                
                mainScriptHiddenhWnd: A_ScriptHwnd,

                ; Window in which menu was triggered
                callingWindowHwnd: WinActive("A"),

                ; Response Window hWnd (will be set in onResponseWindowStateChanged on WM_RESPONSE_WINDOW_OPENED)
                hWnd: 0,
                
                isLoading: false
            }
    
            ;
            ; Maintain it in the global map
            ;

            mapParamName2ParamValue := Map()

            ; Conversion Object to Map
            for paramName in paramsForResponseWindow.OwnProps() {
                mapParamName2ParamValue[paramName] := paramsForResponseWindow.%paramName%
            }

            ; Add it to map of Active Response Windows
            getMapId2ActiveResponseWindowParams()[uniqueID] := mapParamName2ParamValue
            
            ;
            ; Write the paramsForResponseWindow to a file named paramsForResponseWindowJsonFilePath
            ;
            
            ;
            ; Write the paramsForResponseWindow to a file named paramsForResponseWindowJsonFilePath
            ;
            paramsForResponseWindowAsJson := jsongo.Stringify(paramsForResponseWindow, , JSON_INDENT_SPACER)
            
            FileOpen(paramsForResponseWindowJsonFilePath, "w", "UTF-8-RAW").Write(paramsForResponseWindowAsJson)
            
            ;
            ; Check if we are in debug mode
            ;
            if (gIsDebugMode) {
                ; Save debug state

                saveDebugState(paramsForResponseWindowJsonFilePath, false, A_ScriptHwnd, WinActive("A"))

                ; Show debug message
                MsgBox("Parameters prepared.`n`nLaunch the Response Window in Debug mode in VSCode.", "Debug Mode", "Iconi T3")

            } else {

                ; getMapId2ActiveResponseWindowParams()[uniqueID].chatHistoryJsonFilePath := chatHistoryJsonFilePath
                
                ; Run Response Window.ahk while passing the location of that file
                ; through paramsForResponseWindowJsonFilePath as the first argument
                ;
                if (!A_IsCompiled) {
                    ; Running in script mode
                    ; A_AhkPath points to AutoHotkeyU64.exe

                    ; Launch Response Window.ahk in a separate Process
                    Run(A_AhkPath . " " . "`"lib\Response Window.ahk`"" . " " . "`"" . paramsForResponseWindowJsonFilePath . "`"" . " " . A_ScriptHwnd . " " . WinActive("A"))

                } else {
                    ; Running in compiled mode
                    ; A_AhkPath points to the compiled main script executable

                    ; If source file exists on disk (development environment), run from disk so changes take effect
                    ; Otherwise fallback to the embedded resource (*lib\Response Window.ahk)
                    targetScript := FileExist("lib\Response Window.ahk") ? "`"lib\Response Window.ahk`"" : "`"*lib\Response Window.ahk`""

                    ; Launch Response Window.ahk in a separate Process
                    Run(A_AhkPath . " /script " . targetScript . " " . "`"" . paramsForResponseWindowJsonFilePath . "`"" . " " . A_ScriptHwnd . " " . WinActive("A"))
                }
            }    
        } else {
            ; There is NO API Model Name

            ; Eventually, I think it's better to simply ignore it
            ; ; Display error message
            ; MsgBox("SYNTAX ERROR : In Prompt [" promptName "] on API Model n° " i)
        }
    }
}

